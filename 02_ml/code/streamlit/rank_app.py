import time
import socket
import mlflow
import streamlit as st
from sklearn.datasets import load_iris, load_wine, load_diabetes
from sklearn.svm import SVC
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, log_loss
from collections import namedtuple
import lightgbm as lgb
import seaborn as sns

# to start mlflow
#   poetrySetEnvMlToolsMacEbay
#   cd /Users/thchang/Documents/dev/git/ml-tools/tools/streamlit
#   streamlit run ran_app.py --server.port 8503 &
#   mlflow ui &
#
class RankingApp():
    TrainingRun = namedtuple("TrainingRun", ['experiment', 'run_id', 'artifact_uri'])

    def __init__(self):
        self.DATA = {
            "iris": load_iris,
            "wine": load_wine,
            "diabetes": load_diabetes
        }

        self.PROBLEMS = {
            "iris": "classification",
            "wine": "classification",
            "diabetes": "regression"
        }

        self.MODELS = {
            "classification": {
                "LightGBM": lgb,
                "SVM": SVC
            },
            "regression": {
                "LightGBM": lgb,
                "LR": LinearRegression,
                "RFR": RandomForestRegressor
            }
        }
        return

    def run(self):
        st.title('Ranking App')

        st.sidebar.header('Select Dataset')
        data_options = list(self.DATA.keys())
        data_choice = self.selectbox_without_default("", data_options)
        if not data_choice:
            st.stop() # abort script until data is selected
        else:
            st.header("")
            st.header("Data Analysis")
            df = self.load_data(data_choice)
            st.write(df)
            if (st.sidebar.button('Show pairplot')):
                fig = sns.pairplot(df)
                st.pyplot(fig)

        st.sidebar.header('Select Model')
        problem_type = self.PROBLEMS[data_choice]
        model_options = list(self.MODELS[problem_type].keys())
        model_choice = self.selectbox_without_default("", model_options)

        st.sidebar.header('Select Features')
        feature_options = df.columns.drop('target').tolist()
        feature_choice = st.sidebar.multiselect("", feature_options)

        st.sidebar.header('Train Model')
        if st.sidebar.checkbox("Track with mlflow?"):
            mlflow.lightgbm.autolog()
        learning_rate = st.sidebar.text_input("learning_rate", 0.1)
        colsample_bytree = st.sidebar.text_input("colsample_bytree", 1.0)
        subsample = st.sidebar.text_input("subsample", 1.0)
        train_to_test_ratio = st.sidebar.text_input('train to test ratio', 0.2)
        if st.sidebar.button("Start training"):
            X = df[feature_choice].copy()
            y = df['target'].copy()
            X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=float(train_to_test_ratio))
            train_set = lgb.Dataset(X_train, label=y_train)

            with mlflow.start_run() as run:
                params = {
                    "objective": "multiclass",
                    "num_class": 3,
                    "learning_rate": learning_rate,
                    "metric": "multi_logloss",
                    "colsample_bytree": colsample_bytree,
                    "subsample": subsample,
                    "seed": 42,
                }
                model = lgb.train(
                    params, train_set, num_boost_round=10, valid_sets=[train_set], valid_names=["train"]
                )

                y_proba = model.predict(X_test)
                y_pred = y_proba.argmax(axis=1)
                loss = log_loss(y_test, y_proba)
                acc = accuracy_score(y_test, y_pred)

                st.header("")
                st.header("Train Results")
                st.text(f'log loss={loss} accuracy={acc}')

                # log metrics
                mlflow.log_metrics({"log_loss": loss, "accuracy": acc})

                artifact_loc = '/'.join(run.info.artifact_uri.replace('file://', '').split("/")[0:-1])
                run: RankingApp.TrainingRun = RankingApp.TrainingRun(run.info.experiment_id, run.info.run_id, artifact_loc)
                st.text(f'Train artifact={run}')
                st.balloons()
                st.success('Finished training')

                self.load_feature_importance(f'{artifact_loc}/artifacts/feature_importance_split.png')

                st.header("")
                st.header("Deploy Model")
                with st.spinner('Start deployment'):
                        ports_available = [p for p in range(5000, 5020, 1) if self.check_port_available(p)]
                        if not ports_available:
                            st.text('No available port; abort deployment')

                        port = ports_available[0]
                        st.text(f'Deploy model to available port={port}')

                        deploy_model_cmd = f'mlflow models serve --no-conda -m {run.artifact_uri}/artifacts/model -p {port}'
                        st.text(f'Deploy: {deploy_model_cmd}')

                        curl_check = """curl -X POST -H "Content-Type:application/json; format=pandas-split" --data '{"columns":["sepal length (cm)", "sepal width (cm)", "petal length (cm)", "petal width (cm)"],"data":[[6.2, 3.4, 5.4, 2.3]]}' http://127.0.0.1:{}/invocations"""
                        st.text(f'curl: {curl_check.replace("{}", str(port))}')

                        cmd_kill = f'lsof -t -i tcp:{port} | xargs kill'
                        st.text(f'Teardown: {cmd_kill}')

        st.text(f'timestamp@{int(time.time())}')
        return

    def selectbox_without_default(self, label, options):
        options = [''] + options
        format_func = lambda x: 'Select one option' if x == '' else x
        return st.sidebar.selectbox(label, options, format_func=format_func)

    def load_feature_importance(self, file):
        import base64
        file_ = open(file, "rb")
        contents = file_.read()
        data_url = base64.b64encode(contents).decode("utf-8")
        file_.close()

        st.markdown(
            f'<img src="data:image/gif;base64,{data_url}" alt="cat gif">',
            unsafe_allow_html=True,
        )

    @st.cache
    def load_data(self, key):
        data = self.DATA[key](as_frame=True)
        df = data['data']
        df['target'] = data['target']
        return df

    def check_port_available(self, check_port):
        location = ("127.0.0.1", int(check_port))
        a_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        return a_socket.connect_ex(location) != 0  # 0-> port is current used

if __name__ == '__main__':
    RankingApp().run()