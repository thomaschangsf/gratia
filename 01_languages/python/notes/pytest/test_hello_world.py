# To run:
#   cd examples/pytest
#   pytest
#       note: test files need to start with test_*.py. Without the prefix, one needs to manually type: pytest file.py

def inc(x):
    return x + 1


def test_answer():
    assert inc(4) == 5