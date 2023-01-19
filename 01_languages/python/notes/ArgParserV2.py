#!/usr/bin/env python3
"""
Module for ArgParserV2 with Union; which enables how to support multiple commands

Union enables a type that returns one of X types
    Ex1: myVar: Union[int, str] 
        myVar = 5
        myVar = "Hi"
"""
from typing import List, Union
from dataclasses import dataclass
from simple_parsing import ArgumentParser
import sys


# To setup
#    pip3 install simple-parsing
# To Test,
#   cd /Users/chang/Documents/dev/git/ml-tools/tools/python_language
#   either:
#       - python3 ./ArgParserV2.py --help
#       - python3 ./ArgParserV2.py createappcmd --help
#       - python3 ./ArgParserV2.py createappcmd --namespace n1  # --> Execute CreateAppCmd for n1
#       - python3 ./ArgParserV2.py createnamespacecmd --namespace n1  # --> Execute CreateNamespaceCmd for n1


@dataclass
class CreateAppCmd:
    """ Cmd to create app"""
    namespace: str
    def run(self):
        print(f'Execute CreateAppCmd for {self.namespace}')


@dataclass
class CreateNamespaceCmd:
    namespace: str
    def run(self):
        print(f'Execute CreateNamespaceCmd for {self.namespace}')


@dataclass
class Main:
    template: Union[CreateAppCmd, CreateNamespaceCmd]


def main(argv: List[str]) -> int:
    print(f"TWC1: Input parameters to script: {argv}\n")

    parser = ArgumentParser(argv[0], description=__doc__)

    parser.add_arguments(Main, dest="main")

    args = parser.parse_args(argv[1:])

    args.main.template.run()


if __name__ == '__main__':
    main(sys.argv)