#!/usr/bin/env python3

from typing import List
from dataclasses import dataclass
from simple_parsing import ArgumentParser
import sys

# To setup
#    pip3 install simple-parsing
# To Test,
#   cd /Users/chang/Documents/dev/git/ml-tools/tools/python_language
#   either:
#       - python3 ./ArgParser.py --command test --app_config="pybay_app.yaml" --output_dir="/tmp
#       - ./ArgParser.py --command test --app_config="pybay_app.yaml" --output_dir="/tmp

# Method1: Basic
class TessToolArgs():
    @dataclass
    class CreateManifestArgs:
        app_config: str
        output_dir: str

    def parse_args(self, argv):
        # simple_parsing.ArgumentParser takes parameters of key value
        # https://pypi.org/project/simple-parsing/
        parser = ArgumentParser("TessToolArgs")
        parser.add_arguments(TessToolArgs.CreateManifestArgs, dest="input_params", default=None)
        parser.add_argument("--command", type=str, default=None, help="command")
        args = parser.parse_args(argv)
        return args



def main(argv: List[str]) -> int:
    print(f"TWC1: Input parameters to script: {argv}\n")
    args = TessToolArgs().parse_args(argv[1:])
    print(f"TWC2: type(args)={type(args)} args={args}\n")
    print(args.input_params.app_config)
    print("TWC3: SUCCESS. \n")
    return 0


if __name__ == '__main__':
    main(sys.argv)