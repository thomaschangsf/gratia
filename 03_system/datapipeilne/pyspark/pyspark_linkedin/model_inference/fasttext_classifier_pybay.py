import fasttext
from pybay_model_tokenizer import *
import traceback

#model = fasttext.load_model('/Users/thchang/Documents/dev/git/nlp/m2m/m2m_model/projects/offensive_content_detection/insult/model/model-insult-base.bin')
#model = None


def predict_works(msg):
	assert model, "Model is NOT defined"


	pred = model.predict([msg])[0][0][0]
	pred = pred.replace('__label__', '')
	
	return str(pred)


model_path = None
classifer = None

def load_model(path):
	model_path = path
	
	print(f'fasttext_classifier_pybay.load_model: model_path={model_path}')

	tokenizer = SpacyTokenizer(name="en_core_web_sm") #configuration["spacy_model"])
	
	global classifier

	classifier = FastTextClassifier(
	    model_path=model_path, \
	    tokenizer= tokenizer, \
	    lowercase=True)



def predict(msg):
	#assert tokenizer and classifier, "Please instantiate tokenizer and classifier"
	assert model_path, "Model path is not defined"

	assert classifier, "Model is NOT defined"

	response = "DEFAULT"

	try:
		response = classifier.classify(msg).tags[0]
	except Exception as ex:
		response = str(traceback.format_exc())
		print(ex)


	return  response
	