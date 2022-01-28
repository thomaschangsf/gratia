# ---------------------
# typehints: typing
# ---------------------

# ---------------------
# inner function and lambda
#   Lambda are anonymous functions
# ---------------------
# Ex1
(lambda x: x + 1)(2) # output 3

# Ex2: assign lambda to a variable
add_one = lambda x: x + 1
add_one(2)  # output 3

# Ex3: Multiple input parameter
(lambda first, last: first + ' ' + last)('Tom', 'Chang')


# ---------------------
# dataclasses
# - python take on scala's case classes
# ---------------------
from dataclasses import dataclass
@dataclass
class Shape:
    name: str



# ---------------------
# collections.namedtuples
#   - tuples: refer to a value via an index.
#   - namedTuples: refer to a value via a key, like a dict. But it is more efficient than a dict because each nameTuple is represent by its own class. It appears to be a way to create a class.
# ---------------------
from collections import namedtuple
Person = namedtuple(typename='Person',  field_names='name age gender') # nameTuple(
bob = Person(name='Bob', age=30, gender='male')

Status = namedtuple('Status', ('num_target_nodes', 'ancestor'))
s = Status(num_target_nodes=1, ancestor=2)

# ---------------------
# list comprehension
#   - succinct way to create lists (and dictionaries and sets!)
# ---------------------
# l = [ i*2 for i in iterable ]
# d = { k:v for k, v in zip(kList, vList) }


# ---------------------
# Tuple: find number of occurrences in list of tuples
# ---------------------
vowels = ('a', 'e', 'i', 'o', 'i', 'u')
# count element 'i'
count = vowels.count('i')


# ---------------------
# How to create 2D matrix
# ---------------------
numRows, numCols = 3, 4
grid_wrong = [[0] * numCols] * numRows # * numRows will create 3 shallow copies; when I update one row, it will update all 3 rows!!!
grid_correct = [[0]*numCols for _ in range(numRows)]



# ---------------------
# all/any,
# ---------------------
# any function returns True if any element of an iterable is True. If not, any() returns False.
any(True, False, False) # returns True:

# all() method returns True when all elements in the given iterable are true. If not, it returns False
all(True, False, False) # returns False



# ---------------------
# itertools: groupby, accumulate, product, combinations# ---------------------
#   Module for creating iterator, for efficient looping
#   Any iterator is an object that can be used to loop through collection
# ---------------------
import itertools, operator

# accumulate: returns a list of accumulated sum
itertools.accumulate([1,2,3,4], operator.add) # returns a iterator of [1,3,6,19]
list(itertools.accumulate([1,2,3,4], operator.add)) #-> [1, 3, 6, ,10]

# Combinatric Iterator
# product: cartesian product of the input variables
itertools.product('ABCD', 'xy') # --> Ax Ay Bx By Cx Cy Dx Dy
itertools.product(range(2), repeat=3) #--> 000 001 010 011 100 101 110 111
itertools.product('ABCD', 2)        # -> AA AB AC AD BA BB BC BD CA CB CC CD DA DB DC DD
itertools.permutations('ABCD', 2)   # -> AB AC AD BA BC BD CA CB CD DA DB DC
# return r length subsequences of elements, in sorted order
itertools.combinations('ABCD', 2)   # -> AB AC AD BC BD CD
itertools.chain([1,3,5], [2,4,6])   # -> 1,3,5,2,4,6



# Python yield
# Yield suspends function execution to send value back to caller, but function can resume where it left off. Used in generators.
# A generator function that yields 1 for the first time,
# 2 second time and 3 third time
def simpleGeneratorFun(): # a generator is a function that contains yield
    yield 1
    yield 2
    yield 3
# output 1, then 2, then 3
for value in simpleGeneratorFun():
    print(value)

# groupby: returns an iterator that returns (consecutive keys, and groups) from the iterable
# [k for k, g in itertools.groupby('AAAABBBCCDAABBB')] --> A B C D A B
# [list(g) for k, g in itertools.groupby('AAAABBBCCD')] --> AAAA BBB CC D



# ---------------------
# functools
# Module for higher order functions; function whose input is function, and output are function. Like scala!!
# ---------------------
# partial: returns a partial function.
# Partial functions allow one to derive a function with x parameters to a function with fewer parameters and fixed values set for the more limited function.
from functools import partial
def multiply(x,y):
        return x * y
# create a new function that multiplies by 2
dbl = partial(multiply,2)
print(dbl(4))

# reduce
# apply a particular function passed in its argument to all of the list elements
# This is just scala's fold function

lis = [ 1 , 3, 5, 6, 2, ]
functools.reduce(lambda a,b : a+b,lis) # The function here is a lambda function. Output = 17
print (functools.reduce(lambda a,b : a if a > b else b,lis)) # returns the max element



# all

# any


# ---------------------
# decorator
# https://realpython.com/primer-on-python-decorators/
# ---------------------
def my_decorator(func):
    def wrapper():
        print("Something is happening before the function is called.")
        status = func() 
        print(f"Something is happening after the function is called. status={status}")
    return wrapper

def say_whee():
    print("Whee!")
    return 1

say_whee = my_decorator(say_whee)
say_whee()
#Something is happening before the function is called.
#Whee!
#Something is happening after the function is called. status=1


def my_decorator(func):
    def wrapper_do_twice(*args, **kwargs):
        func(*args, **kwargs)   # function I am decorating can pass in multiple parameters
        return func(*args, **kwargs)    # my decorator will use the result of func

    return wrapper_do_twice

@my_decorator
def return_greeting(name):
    print("Creating greeting")
    return f"Hi {name}"

return_greeting("Tom")
#Creating greeting
#Creating greeting
#'Hi Tom'


def return_greeting_wo_sugar(name):
    print("Creating greeting")
    return f"Hi {name}"
my_decorator(return_greeting_wo_sugar("Caryse"))
