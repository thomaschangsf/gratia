import streamlit as st
import mlflow
from sklearn.datasets import load_iris, load_wine, load_diabetes
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, log_loss
import lightgbm as lgb

from sklearn.metrics import f1_score, r2_score

# to start mlflow
#   poetrySetEnvMlToolsMacEbay
#   cd /Users/thchang/Documents/dev/git/ml-tools/tools/streamlit
#   streamlit run st_with_lightgbm.py --server.port 8503 &
#   mlflow ui &
#

def selectbox_without_default(label, options):
    options = [''] + options
    format_func = lambda x: 'Select one option' if x == '' else x
    return st.selectbox(label, options, format_func=format_func)


def load_feature_importance(file):
    import base64
    file_ = open(file, "rb")
    contents = file_.read()
    data_url = base64.b64encode(contents).decode("utf-8")
    file_.close()

    st.markdown(
        f'<img src="data:image/gif;base64,{data_url}" alt="cat gif">',
        unsafe_allow_html=True,
    )

from collections import namedtuple
TrainingRun = namedtuple("TrainingRun", ['experiment', 'run_id', 'artifact_uri'])

def train_workflow() -> TrainingRun:
    DATA = {
        "iris": load_iris,
        "wine": load_wine,
        "diabetes": load_diabetes
    }

    PROBLEMS = {
        "iris": "classification",
        "wine": "classification",
        "diabetes": "regression"
    }

    MODELS = {
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

    # Title
    st.title("NLP Ranking App")

    # --------------------------------------
    # Training
    # --------------------------------------
    st.header("Part1: Train Model")

    # Choose dataset
    data_options = list(DATA.keys())
    data_choice = selectbox_without_default("Choose a dataset", data_options)


    @st.cache
    def load_data(key, input):
        data = DATA[key](as_frame=True)
        df = data['data']
        df['target'] = data['target']
        return df

    if not data_choice:
        st.stop()
    else:
        df = load_data(data_choice, DATA)
        st.write(df)

    if (st.button('Show pairplot')):
        import seaborn as sns
        fig = sns.pairplot(df)
        st.pyplot(fig)

    # Model selection
    problem_type = PROBLEMS[data_choice]
    model_options = list(MODELS[problem_type].keys())
    model_choice = selectbox_without_default("Select an algorithm", model_options)
    if not model_choice:
        st.stop()

    # Feature selection
    feature_options = df.columns.drop('target').tolist()
    feature_choice = st.multiselect("Select features", feature_options)

    # Model training
    st.subheader("Model Training")

    #TrainParams = namedtuple('TrainParams', ('user_input', 'default'))
    #LGB_PARAMS = {'learning_rate': TrainParams(None, 0.1), 'colsample_bytree': TrainParams(None, 1.0), 'subsample':TrainParams(None, 1.0) }
    #for key, val in LGB_PARAMS:
    #    LGB_PARAMS[key] = val
    learning_rate = st.text_input("learning_rate", 0.1)
    colsample_bytree = st.text_input("colsample_bytree", 1.0)
    subsample = st.text_input("subsample", 1.0)

    if st.checkbox("Track with mlflow?"):
        mlflow.lightgbm.autolog()
        # mlflow.set_experiment(data_choice)
        # mlflow.start_run()
        # mlflow.log_param('model', model_choice)
        # mlflow.log_param('features', feature_choice)

    run = None

    if st.button("Start training"):
        X = df[feature_choice].copy()
        y = df['target'].copy()
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
        train_set = lgb.Dataset(X_train, label=y_train)

        with mlflow.start_run() as run:
            # train model
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

            # evaluate model
            y_proba = model.predict(X_test)
            y_pred = y_proba.argmax(axis=1)
            loss = log_loss(y_test, y_proba)
            acc = accuracy_score(y_test, y_pred)

            st.text(f'loss={loss} acc={acc}')

            # log metrics
            mlflow.log_metrics({"log_loss": loss, "accuracy": acc})

            artifact_loc='/'.join(run.info.artifact_uri.replace('file://', '').split("/")[0:-1])
            run : TrainingRun = TrainingRun(run.info.experiment_id, run.info.run_id, artifact_loc)
            st.text(f'Train artifact={run}')
            st.success('Finished training')

            #if (st.button('Show feature importance')):
            load_feature_importance(f'{artifact_loc}/artifacts/feature_importance_split.png')

            # Deploy Model
            st.header("Part2: Deploy Model as Web Endpoint")
            #deploy_choice = st.text_input('Type deploy to deploy')

            #deploy = len(deploy_choice) >0

            #st.text(f'run={run} deploy={deploy}')
            st.balloons()

            with st.spinner('Start deployment'):
                ports_available = [p for p in range(5000, 5020, 1) if check_port_available(p)]
                if not ports_available:
                    st.text('No available port; abort deployment')
                    st.stop()

                port = ports_available[-1]
                st.text(f'Deploy model to available port={port}')

                deploy_model_cmd = f'mlflow models serve --no-conda -m {run.artifact_uri}/artifacts/model -p {port}'
                st.text(f'Deploy: {deploy_model_cmd}')
                if (st.button('Deploy model?')):
                    import os
                    #os.system(deploy_model_cmd)

                    curl_check = """curl -X POST -H "Content-Type:application/json; format=pandas-split" --data '{"columns":["sepal length (cm)", "sepal width (cm)", "petal length (cm)", "petal width (cm)"],"data":[[6.2, 3.4, 5.4, 2.3]]}' http://127.0.0.1:{}/invocations"""
                    st.text(f'curl: {curl_check.replace("{}", str(port))}')

                    cmd_kill = f'lsof -t -i tcp:{port} | xargs kill'
                    st.text(f'Teardown: {cmd_kill}')
                    # Does not work from python, but ok from terminal. TODO: look at subprocess
                    # os.system(f'lsof -t -i tcp:{port} | xargs kill')


    return run


def check_port_available(check_port):
    import socket
    #st.text(f'check_port_available({check_port}): 1')
    location = ("127.0.0.1", int(check_port))
    a_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    return a_socket.connect_ex(location) != 0  # 0-> port is current used

def deploy_workflow(train_result: TrainingRun):
    st.header("Part2: Deploy Model as Endpoint")
    st.text(f'train_result={train_result}')

    #if st.button("Deploy Model"):
    with st.spinner('Start deployment'):
        st.text('Looking for open port')
        ports_available = [ p for p in range(5000, 5020, 1) if check_port_available(p)]
        if not ports_available:
            st.text('No available port; abort deployment')
            #st.stop()

        port = ports_available[-1]
        st.text(f'Deploy model to port={port}')

        deploy_model_cmd = f'mlflow models serve --no-conda -m {train_result.artifact_uri}/artifacts/model -p {port}'
        st.text('To deploy model, type:')
        st.text(f'{deploy_model_cmd}')

        st.text('To check model, type')
        curl_check="""curl -X POST -H "Content-Type:application/json; format=pandas-split" --data '{"columns":["sepal length (cm)", "sepal width (cm)", "petal length (cm)", "petal width (cm)"],"data":[[6.2, 3.4, 5.4, 2.3]]}' http://127.0.0.1:{}/invocations"""
        st.text(curl_check.replace("{}", str(port)))

        st.text('To deactivate model, type:')
        cmd_kill=f'lsof -t -i tcp:{port} | xargs kill'
        st.text(cmd_kill)
        #os.system(f'lsof -t -i tcp:{port} | xargs kill')


def main():
    try:
        run_result = train_workflow()
        #run_result = TrainingRun('0', 'c17b03e3d4b14472b9762900ecfe0eec', '/Users/thchang/Documents/dev/git/ml-tools/tools/streamlit/mlruns/0/c17b03e3d4b14472b9762900ecfe0eec')

        #deploy_workflow(run_result)

    except Exception as ex:
        st.text(f'Exception: {ex}')
    #finally:
    #    st.stop()

if __name__ == '__main__':
    main()
