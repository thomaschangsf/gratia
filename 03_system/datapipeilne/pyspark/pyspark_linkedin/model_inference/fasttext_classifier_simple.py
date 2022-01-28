import fasttext

model = fasttext.load_model('/Users/thchang/Documents/dev/git/nlp/m2m/m2m_model/projects/offensive_content_detection/insult/model/model-insult-base.bin')

def predict(msg):
	pred = model.predict([msg])[0][0][0]
	pred = pred.replace('__label__', '')
	return str(pred)
