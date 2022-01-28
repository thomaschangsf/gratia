from typing import Optional, Iterable, Mapping, List, Union
from pathlib import Path

import fasttext

#Cannot serialize SPACY!!! https://futurice.com/blog/classifying-text-with-fasttext-in-pyspark
#import spacy  
#from spacy import load

from pybay.types.nlp.tokenizer import Tokenizer, Tokenization
from pybay.types.nlp.tagger import TextClassifier, TextClassificationResult


class SpacyTokenizer(Tokenizer):
    """
    Simple tokenizer based on Spacy
    """

    #nlp: spacy.language.Language   
    name: str

    def __init__(self, name: str):
        """
        Ctor
        :param name: Spacy Name of tokenizer (e.g. ``en_core_web_sm``)
        """
        #TWC self.nlp = spacy.load(name, disable=['ner', 'tagger', 'parser', 'textcat'])
        self.name = name

    def tokenize(self, sentence: str) -> Tokenization:
        #return Tokenization(tokens=[token.text for token in self.nlp(sentence)])
        return Tokenization(tokens=[token for token in sentence.lower().split(' ')])

    def tokenize_batch(self, sentences: Iterable[str]) -> Iterable[Tokenization]:
        #yield from (self.tokenize(sentence) for sentence in sentences)
        yield from ( sentence.lower() for sentence in sentences)

    def __str__(self):
        return f"SpacyTokenizer({self.name})"


class FastTextClassifier(TextClassifier):
    """
    Wrapping a Fasttext classifier for pybay.types
    """

    model: fasttext.FastText
    """ Loaded fasttext model """

    tokenizer: Tokenizer
    """ Tokenizer to use """

    lowercase: bool
    """ whether to lowercase the input """

    name: str
    """ Name of tokenizer in __str__ """

    def __init__(self, model_path: str, tokenizer: Tokenizer, lowercase: bool = True):
        """
        Ctor
        :param model_path: Path to fasttext model.bin file
        :param tokenizer:  PyBay Tokenizer object to use for tokenization
        :param lowercase:  Whether to lowercase the input before sending it to the model
        """

        self.model = fasttext.load_model(model_path)
        #self.model = fasttext.load_model(str(Path(model_path)))
        self.tokenizer = tokenizer
        self.lowercase =  lowercase
        self.name = Path(model_path).name

    def __str__(self):
        return f"FastTextClassifier({self.name})"

    def classify(self, sentence: str, *, k: int = 0, context: Optional[Mapping[str, str]] = None) \
            -> TextClassificationResult:
        preprocessed_sentence = self._preprocess_input(sentence)
        prediction = self.model.predict(preprocessed_sentence, k=max(k, 1))  # default value for k is 0 in PyBay, but 1 in FastText
        tags = [self._postprocess_tagname(tagname) for tagname in prediction[0]]
        result = TextClassificationResult(sentence=preprocessed_sentence,
                                          tags=tags,
                                          probs=dict(zip(tags, prediction[1])))
        return result

    def classify_batch(self, sentences: Iterable[str], *,
                       k: int = 0,
                       contexts: Optional[Iterable[Mapping[str, str]]] = None) -> Iterable[TextClassificationResult]:
        yield from (self.classify(sentence) for sentence in sentences)

    def get_tagset(self) -> List[str]:
        return [self._postprocess_tagname(tagname) for tagname in self.model.get_labels()]

    def _preprocess_input(self, sentence):
        """
        Preprocess the input -- tokenize, and put to lower case if required
        :param sentence:
        :return:
        """
        tokenized = self.tokenizer.tokenize(sentence)
        result = " ".join(tokenized.tokens).replace("\n", " ")
        if self.lowercase:
            return result.lower()
        return result

    def _postprocess_tagname(self, tagname: str):
        """
        Postprocess tag names -- remove __label__ prefix if present
        :param tagname: Fasttext tag name
        :return: Tagname without __label__ prefix
        """
        if tagname.startswith("__label__"):
            return tagname[9:]
        return tagname