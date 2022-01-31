import typing
import collections

# Also refer to LeetCode notes: https://docs.google.com/document/d/1UacbaJq1a8otPTVKW35IRYSxigRiInJ0IMeJ7Px3mNY/edit#
def chap5_array() -> None:
    # -----------------------------
    """
    Key Point:
        Fast access for element at an index; slow lookups unless sorted. Be comfortable with iterations, resizing, partitioning, and merging

    Arrays are represented by python lists [].  Consecutive elements are represented by continuous memory, giving it its efficiency characteristics.

    Efficiency
        - Arrays operate efficiently from both ends
        - Brute force solutions with array requires O(n) space; but one can use array itself to reduce space complexity to O(1)
        - Adding arrays from front is slow; see if one can add arrays from the back
        - Instead of deleting, which may cause moving all entries to the right, consider over-writing an element

    Others
        - Be careful for off by 1 errors, reading past the last element of an array
        - Be comfortable writing code that operates on subarrays

    Compared to LinkedList
        - Compared to an array
        * Same: Both represents a sequence of objects
        * Difference: LL have O(1) insert & delete; Arrays have O(1) lookup, provided you know the index

    """

    # -----------------------------
    # Know you libraries
    # -----------------------------
    # - instantiate lists
    l1 = list(range(5))                 # range returns a range object
    l2 = [i for i in range(0, 6, 2)]    # [0, 2, 4]
    numRows, numCols = 3, 2
    grid = [ [0] * numCols ] * numRows

    l1.append(5)                        # [0, 1, 2, 3, 4, 5]    O(n)=1 or worst case n
    l1.remove(2)                        # [0, 1, 3, 4, 5]       O(n-indexToRemove)

    # deep copy vs shallow copy
    import copy
    lShallow = copy.copy(l1)            # [0, 1, 3, 4, 5]
    l1.append(6)                        # [0, 1, 3, 4, 5, 6]
    lShallow                            # [0, 1, 3, 4, 5]   Why? A shallow copy constructs a new compound object and then inserts references into it to the objects. Here, we do not have a compund object.

    l3 = [1, 2, [3,5], 4]
    l3Shallow = copy.copy(l3)
    l3Deep = copy.deepcopy(l3)
    l3.append(5)
    l3Shallow               # [1, 2, [3, 5], 4]  BC we are not changing the compound object reference, ie l3's element 2
    l3[2][0] = 100          # [1, 2, [100, 5], 4]
    l3Shallow               # [1, 2, [100, 5], 4] !!! L3Shallow 2nd index changed.
    l3Deep                  # [1, 2, [3, 5], 4]


    # key method
    min(l1)                 # returns the min VALUE of array; 0
    max(l1)                 # returns the max VALUE of array: 6

    # binary search
    lSorted = list(range(10, 100, 20))  # [10, 30, 50, 70, 90]
    import bisect
    bisect.bisect(lSorted, 15, lo=0, hi=len(lSorted))     # 1 ; returns index of lSorted to insert for the value 15 to maintain sorted order
    arr = list(range(-3, 2)) # [-3, -1, 1]
    index_first_pos = bisect.bisect_left(arr, 0) #2

    # max index of array
    l6 = [10, -20, 30]
    sorted([ (i, j) for i, j in enumerate(l6)], key=lambda t: t[1])[0][-1] #
    min(enumerate(l6), key=lambda t: t[1]) # (1, -20)

    # sorting
    lUnsorted = [('for', 24), ('Geeks', 8), ('Geeks', 30)]
    lUnsortedNewObj = sorted(lUnsorted, key=lambda x: x[1]) # returns a copy, [('Geeks', 8), ('for', 24), ('Geeks', 30)]
    lUnsorted.sort(key=lambda x:x[1])   # in place; [('Geeks', 8), ('for', 24), ('Geeks', 30)]

    # slicing: [startIndex: endIndex (not included): stepSize]
    A = [1,6, 3, 4, 5, 2, 7]
    A[1 : 2]        # [6]
    A[: -1]         # [1,6, 3, 4, 5, 2] ; -1 means start counting from the end
    A[::-1]         # [7, 2, 5, 4, 3, 6, 1] reversed

    del(A[2])       # delete the element at index2 [1, 6, 4, 5, 2, 7]
    del(A[1:3])     # delete elements from index 1 to 3, not including 3: [1, 5, 2, 7]

    # list comprehension: Use cases for  multiple levels of list comprehension. Do not use list comprehension for more than 2 levels of loops
    A = [1, 3, 5]
    B = ['A', 'B']
    [ (a, b) for a in A for b in B] # product of sets : [(1, 'A'), (1, 'B'), (3, 'A'), (3, 'B'), (5, 'A'), (5, 'B')]
    M = [list(range(0,4))] * 2      # convert 2d to 1 d : [[0, 1, 2, 3], [0, 1, 2, 3]]
    [c for row in M for c in row]   # [0, 1, 2, 3, 0, 1, 2, 3]

    all( [True if x%%2==0 else False for x in range(10)] )
        # ternary operatior in assignment
        a = 1 if True else 2 #a=

        # ternary oeprator in list comprehension
        [ True if i%2==0 else False for i in range(10)]

    return

def chap6_ds_strings() -> None:
    """
    Key Point:
        Know how strings are represented in memory; know how to copy, match, join, and split.

    strings can be viewed as a special type of array
    """

    # ----------------------------
    # Know you libraries
    # ----------------------------
    s = "Hi Tom"
    s.startswidth("T")          # False
    s.endswith("m")             # True
    s.split(" ")                # ["Hi", "Tom"]
    ", ".join(s)                # 'h, i,  , T, o, m'
    ", ".join(["Tom", "Chang"]) # 'Tom, Chang'

    return

def chap7_ds_linked_list() -> None:
    """
   - Key Point:
        * Understand how LL tradeoffs with arrays. Be comfortable with iteration, insertion, and deletion with single/double LL.

    - A singly linked list is a data structure that contains a SEQUENCE of nodes
    - Each node contains an OBJECT and a REFERENCE to the next node
    - Compared to an array
        * Same: Both represents a sequence of objects
        * Difference: LL have O(1) insert & delete; Arrays have O(1) lookup, provided you know the index
    - Interview problems often requires you write your own LL class
    - Python does not have standard type for linked list; python list type is a dynamic sized ARRAY

    - Pointers & Patterns
        * Brute force LL problems uses O(n) space; reuse EXISTING NODES to reduce space complexity to O(1)
        * LL problem is often about coding cleanly
            - Don't forget to update next for the head and tail
        * LL problems often benefit from having 2 iterators; one iterating quicker than the other
    """

    # ----------------------------
    # Know you libraries & some own functions
    # ----------------------------
    class ListNode:
        def __init__(self, data=0, next=None):
            self.data = data
            self.next = next

    def search_list(L: ListNode, key: int) -> ListNode:
        while L and L.data != key:
            L = L.next
        # If key is not present, L will be null
        return L

    def insert_node_after(node: ListNode, new_node: ListNode) -> None:
        new_node.next = node.next
        node.next = new_node

    def delete_after(node: ListNode) -> None:
        node.next = node.next.next

    return

def chap8_ds_stacks_queues() -> None:
    """
    pg 100

    Key Points:
        Recognize when LIFO (stack) and FIFO (queue) are applicable. Know both array and LL implementations.

    Stacks & Queues
        - Used as building block to more complex problems
        - Data structure optimized to access the first/last element
    """

    """
    Stacks: (a cup)
        - LIFO: Useful to create reverse iterators for sequences hard to step back from current element
            * This property is useful for parsing, ie valid paranthesises
            * Methods: push & pop
            * Consider augmenting stack to: find max elements
                push/pop operates on top of the stack

               |   | <- push/pop
               | 1 | [top of stack]
               | 2 |

        - Can be implemented as an array or LL
            * LL: O(1) for push and pops
            * array (aka dynamically resized array) : AMORTIZED to O(1)

        - PROBLEMS
            * stacks are often used in conjunction with a lookup map (RPN, is_valid_paranthesis.py)
    """
    # ----------------------------
    # Know you libraries: Stacks
    # ----------------------------
    stack = [11, 2, 5]
    stack.append(6)         # # add to the end; [11, 2, 5, 6]
    stack[-1]               # Retrieves, but does not remove top element of stack, 6
    top = stack.pop()       # top=6 stack=[11, 2, 5]
    len(stack) == 0         # check if empty stack. can also use if stack.
                            # s[-1] and s.pop() will raise IndexError exception if empty stack.

    """
    Queue: (pushing a sausage)
        - FIFO: Useful where data access pattern where ORDER needs to be preserved
            popLeft -->  [ | | | | ]   <-- append
        - Main methods: enqueue & dequeue
            enqueue: adds element to the FRONT of the LL/array
            dequeue: removes element from the BACK of the LL/array

        - Deque: subclass of queues where we can enqueue/deque from both FRONT and END of DS. Deque can be used as a stack OR queue.
    """
    # ----------------------------
    # Know you libraries: Queues
    # ----------------------------
    # Either use an array, implement own class, or use collections.deque
    # Deques are generalizations of stacks and queues. Deques are
    #   - thread safe
    #   - append and pops from EITHER end are O(1). In comparison arrays's append and appendLeft(especially), being a resizable array, 
    #     can call realloc, which takes significant time.  

    queueArr = [11,2,5]

    from collections import deque
    queueDeque = deque(queueArr)
    queueArr.append(6)      # add to the end of array; [11, 2, 5, 6]. dequeArr is still the orig values, since we did a deep copy
    top = queueArr[0]       # retrieves but does not remove; top=11; queueArr=[11, 2, 5, 6]
    queueArr.popLeft()      # queueArr=[2, 5, 6]

    queueDeque.append(1)    # add to the end of ds; default queue insert behavior
    queueDeque.popLeft()    # pops the FRONT of the ds; default queue pop behavior
    queueDeque.extend([range(10)])


    queueDeque.appendLeft(1)# add to the front of ds;
    queueDeque.pop()        # pops the BACK of the element

    # Problems
    #   Queue can be implemented via an array. P8.6 pg 108 tree_level_order.py - print node at same depth. Iterate via list comprehension (nested)

    return

def chap9_ds_binary_trees() -> None:
    """
    Key Points:
        - Good for representing hierarchical data. Know about depth, height, leaves, search path, traversal sequences, successor/predecessor operations.

    Binary trees
        - is a DS consisting of (i) root node r or empty (ii) left binary tree (iii) right binary tree
        - is NOT a binary search tree (BST).  Binary tree has not variant that leftNode.value < rightNode.value
        - appropriate for dealing with structures

    Depth & Height:
        - Depth of a node n is the num of nodes from root to n, not including n
        - Height of BT is the MAXIMUM depth of the binary tree

    Traversing:
        - Inorder: leftNode -> RootNode -> RightNode
        - Preorder: RootNode -> LeftNode -> RightNode
        - PostOrder: LeftNode -> RightNode -> RootNode

    Pointers:
        - BT is appropriate for recursive algorithm. Remember to account for space complexity due to function call stacks.
          This implies solutions to BT trees uses function calls
        - Consider the skewedness of trees. Tree with O(h) complexity with N total nodes:
            balanced -> O(logN)
            unbalanced -> O(N)
        - Some tree problems with brute force allocated O(n) ADDITIONAL spaces; more elegant solution uses O(1) space
        - Simplify each node to have a parent node, to reduce time and space complexity

    """

    # ----------------------------
    # Know you libraries
    # ----------------------------
    class BinaryTreeNode:
        def __init__(self, data, leftNode, rightNode=None):
            self.data = data
            self.leftNode = leftNode
            self.rightNode = rightNode


    # Pattern1: Via Recursion
    def outer(tree, input: Optional[int]):
        def recurse(node, state: Optional[int]):
            if not node:
                print('Insert logic for base logic: node CALLING this function has a child that is a LEAF')

            if not node.left and not node.right:
                print('Insert logic for CURRENT node being a LEAF')

            state = state # update with node

            stateRight = recurse(node.right, state)
            stateLeft = recurse(node.left, state)

            return (state, stateRight, stateLeft, recurse)

        return recurse(tree)

    # Pattern2: Via Iteration
    def chap10_ds_heaps() -> None:
    """
    - Key Points:
        lookup for find-max|find-min -> O(1)
        insertion | deletion -> O(log n)

    - Heap is a Binary Tree which has the variant: root.value > allChild.value
        By default, heap refers to max-heap BUT Python heapq implements a min-heap
        min-heap : root.value <= child.value
        
    - Use heap when
        One cares about the smallest/largest elements but don't care about slow random element lookup, delete

    - Performance: N = total number of nodes
        insertions: O(log(N))
        lookup:
            max/min: O(1)
            arbitrary: O(N)
        delete max/min element: O(log(N))
    """

    # ----------------------------
    # Know you libraries
    # ----------------------------
    h = [1, 100, 4, -100]
    import heapq                # implements min heap. For max-heap, multiply each element in h by -1
    heapq.heapify(h)            # O(N)!! in place, ie don't need to assign, like l.sort. [-100, 1, 4, 100]
    heapq.heappush(h, -110)     # O(log(K)) [-110, -100, 4, 100, 1]
    smallest = heapq.heappop(h) # O(log(K)) smallest=-110 h=[-100, 1, 4, 100]
    heapq.heappushpop(h, 200)   # first pushes and pop
    smallestWithoutPop = h[0]
    largest = heapq.nlargest(2, h)[0]    # this does NOT pop, just for peeking.
    smallest = heapq.nsmallest(2, h)[0]  # this does NOT pop, just for peeking.
    largest_k_elemnts = minheap[-k:]

    return

def chap11_searching() -> None:
    """
    Search classifications:
        - Collection is static: there are no data inserts between queries. This will be the focus of this section: binary search and general search.
            For search with updates, consider using heap(Chap10), hashTable(Chap12), and BST(Chap14)
        - Trade computation (ie pre-compute) to speed up query
        - Use statistical properties of the data
    """

    """
    Binary Search
        - Binary search is typically applied to return the index of element of value t from n SORTED sequence
            However, we can also use it for unsorted, like searching an interval of real numbers
        - Performance:
            Runtime: O(log(N))
            Space: O(1)
        - May think about make time/space trade offs, like making multiple passes through the data
    """
    # ----------------------------
    # Know you libraries: Binary Search
    # ----------------------------
    def bSearch(t: int, A: list[int] ) -> int:
        L, U = 0, len(A)-1
        while L <= U:
            M = L + (U-L)/2
            if A[M] < t:
                L = M+1
            elif A[M] == t:
                return M
            else:
                U = M-1

    import bisect
    lSorted = list(range(10, 100, 20))  # [10, 30, 50, 70, 90]
    import bisect
    bisect.bisect(lSorted, 15, lo=0, hi=len(lSorted))     # 1 ; returns index of lSorted to insert for the value 15 to maintain sorted order


    """
    General Search: [Static collections]
        - Search problems can be classified by these attributes:
            * trade off between RAM and computation time
            * avoid wasted comparisons when searching for min and max element simultaneously
            * use randomization to perform elimination efficiently
            * use bit-level manipulations to identify missing elements
    """
    # ----------------------------
    # Know you libraries
    # ----------------------------


    return

def chap12_ds_hash_tables() -> None:
    """
    pg 163
    - Key Points:
      * insertion | deletion | lookup -> O(1)
      * Disadvantages:
        not good for order-related queries
        need to resize when too many collisions

    - Hash table:
        * is a DS that has runtime complexity of O(1) for insert, delete, and lookup
        * uses a hash function transforms the key to an index of an array. The value stored is typically a list.
            Requirements on hash function:
                * Equal key has equal hash codes
                * Ideally, hash function spreads out the values evenly

    - Pointers:
        * Consider using pre-computed lookup tables instead of hard code if else comparisons (like RPN expression)
        * Consider using a multimap, a map that contains multiple values for a single key, ie collections.defaultdict(list)
        * Consider using a hashcode as a signature to enhance performance, such as filtering out candidates
        * Not every key is hashable. Mutable containers is not hashable
        * A user defined class should implement the __hash__(self), keeping in mind what constitutes logical equality
    """

    # ----------------------------
    # Know you libraries
    #   Set, DefaultDict, Counter
    # ----------------------------
    # Set: Stores only keys
    s = set([1,2,1,3])
    s.add(4)        # {1, 2, 3, 4}
    s.remove(4)     # {1, 2, 3}
    1 in s          # True
    t = {2, 5}
    t <= s          # is t a subset of s? False because set t has the value 5
    {1} <= s        # True
    s -t            # Element in s that is not in set t; {1, 3}

    # Counter: Key -> numCnt(Key)
    from collections import Counter
    c = Counter(a=3, b=1)
    d = Counter(a=1, b=2)
    c + d       # Counter({'a': 4, 'b': 3})
    c - d       # subtraction; keep only positive counts
    c & d       # intersection: min of each key-value : Counter({'a': 1, 'b': 1})
    c | d       # union: max of each key-value Counter({'a': 3, 'b': 2})

    # multi-map: defaultdict(list): key -> list[ ]
    from collections import defaultdict
    d = defaultdict[list]

    return

def chap13_algo_sorting() -> None:
    """
    Key Points:
        - Uncover some structure by sorting the inputs

    Sorting
        - rearrange a collection to increasing|decreasing order
        - so (i) improve search time (ii) identify similar items
        - quicksort is USUALLY the best choice for sorting. O(n log(n))
        - most sorting routines is based on a compare function; exception is radix which is based on numerical attributes
        - If we just need the min/max element, consider the heap, which gives O(1) lookup and O(log(n)) insert.

    Pointers:
        - When to sort?  If problem has a search element. If the inputs has a natural ordering.  Ordering the sequence the search faster. Look at 13.1
        - Sorting problems comes in 2 flavors:
            * use sorting to make subsequent algorihtm easier; write a custom comparator function
            * design a custom sorting routine from ground level; use DS like BST, heap, or array indexed by values
    """

    # ----------------------------
    # Know you libraries
    # ----------------------------
    class Student:
        def __init__(self, name: str, grade_point_average: float) -> None:
            self.name = name
            self.grade_point_average = grade_point_average
        def __lt__(self, other: 'Student') -> bool:
            return self.name < other.name

    students = [ Student('A', 4.0), Student('C', 3.0)]

    # sorted can use the objects __lt__ OR one can pass in a comparator function
    # sorted takes an iterable and return a new list. Original list is not changed.
    students_sorted_by_name = sorted(students)

    # sort students in place by GPA
    # reverse= True --> descending order. Default is from small to largest, ie ascending
    students.sort(key = lambda student: student.grade_point_average, reverse=True)

    return





def chap14_ds_binary_search_trees() -> None:
    """
    pg 202

    - Key Points:
        * insertion, deletion, lookups, find-min, find-max, successor&predecessor: O(log n)
        * be familiar with notion of balance and operations maintaining balance

    - BST is a workhorse DS that solve almost DS access pattern efficiently (usually log(N))
        * search key
        * min/max value
        * successor/predecessor of a search key
        * enumerate key in a range in sorted order
        * [NOTE] BST efficiency depends on how balance the tree is; RedBlack tree is a height balanced BST

    - BST property: (i) node.data >= node.left.data (ii) node.data < node.right.data
        * This lends BST problem frequently malleable to recursion

    - Comparison with other DS
        * Like arrays, stored values are stored in sorted order.  Unlike array, BST elements can be deleted/inserted efficiently
        * Hash table is optimized (O(1)) for key lookups; In comparison, BST gives O(log(n)) for min/max element, key lookup, delete, find

    - Pointers
        * One can iterate through elements in sorted order in O(N) regardless whether BST is balanced
        * Combine BST with hash table. One of the most common mistake for BST is not updating the element.
            Ex: Student(name, GPA).  BST node is Student; tree is ordered by gpa. If we need to update a student score by name, we need to traverse entire tree since we BST gaurantees n.gpa > node.left.gpa. By having a hashtable, we can look up a node by student name, DELETE the node, and update.
        * Consider augmenting the node.data to be more complex to support complex queries (Page 220)

    """

    # ----------------------------
    # Know you libraries
    # ----------------------------
    class BstNode():
        def __init__(self, data=None, left=None, right=None):
            self.data = data
            self.left = left
            self.right = right

    # key is the VALUE we are looking for. key is compared against BstNode.data
    def search_bst(tree: BstNode, key: int):
        if not tree or key == tree.data:
            return tree
        if key < tree.data :
            return search_bst(tree.left, key)
        else:
            return search_bst(tree.right, key)

    import bintrees
    #(key, value)
    t = bintrees.RBTree( [(5, 'Alfa'), (2, 'Bravo'), (7, 'Charlie'), (3, 'Deleta'), (6, 'Echo') ])
    print(t[2])  # print value by node name; --> Bravo . This is O(n) !!

    print(t.min_item(), t.max_item()) # log(N) (2, 'Bravo') (7, 'Charlie')

    t.insert(9, 'Golf') # O(log(N))

    t.discard(3) # delete in O(log(N))

    a = t.pop_min() # log(N)
    b = t.pop_max()

    return


def chap15_algo_recursion() -> None:
    """
    pg 223
    - Recursion is GENERAL approach of decomposing a problem in sub problems. Good approach to problems like search, enumeration, and divideConquer.

    - Relationship to divide&Conquer, DP, and regular expression.

        * Divide & Conquer: sub problems are (i) INDEPENDENT (ii) of same type (? same input parameter)

        * Dynamic Programming: sub problems are (i) DEPENDENT (ii) of the same type
            dependent means the solution of 1 subProblemA depends on solution of subProblemB.
            It could also mean we pass the function with the sample input values; in this case we should cache the result

        * Regular Expression: sub problems are of different type (?)

    - Recursive function consists of
        * base termination
        * define input parameters where at each recursion call we pass in different values.

    - Recursion call implemented via a function takes space complexity; rewrite via iteration to save this

    - Recursion can be removed from tail-recursive by using a while loop IF we frame the recursive function from A to this; this is what compilers do.
        def factorial_non_tail(n):
          if n == 0: return 1
              else: return factorial(n-1) * n <- BC we multiply n outside of function call, compiler needs to keep track of our result for factorial(n-1)

        def tail_factorial(n, accumulator=1):
          if n == 0: return 1
          else: return tail_factorial(n-1, accumulator * n) <- compiler now does not need to track the multiplication result; compiler can rewrite this with while.  UNFORTUNATELY, python does not do this.

        Reference: https://chrispenner.ca/posts/python-tail-recursion

    - Problems
        * If I know how to move the n-1 solution, how does it help with the nth solution? This can help model the recurrence relationship. [HANOI]
        * recursion often gives rise to brute-force non-efficient run time. Minimize by cache or smarter way of iterating (N-QUEENS: iterate by rows)
        * Be efficient with storage; try to reuse state variables, rewrite/reuse at each recursive function. 
            - via smart iteration: [N-QUEENS: P15.3 col_placment]
            - via memorization/ state: [ coin change, as in dp: https://docs.google.com/document/d/1d16JzPZzeTYDl0A4Vi_lrhsSnAPBzAhln9rxWi5PZ-A/edit#]
        * Recursion will often use back-tracking for generating permutation problems. (Generate the Power Set P15.4 pg 231)
        * To calculate time complexity: O(n) often depends on the number of recursive calls, C(n), for each function. (see permutation.py and power_set.py), usually n! or 2^n
    - Pattern
        def function(inputA):
            def recurse(states: {ex: i - index to inputA, currCanddiate} ):  # states represent the variables used in the recurrence
                if baseCondition(states)
                    solution.append
                for i in iterable():
                    if condition() # meet some condition a currCandidate in this loop needs to satisfy ie n queens
                        update currCandidate

                    swap()  # for backtrack, common in generate combination problems, ie
                    recurse()
                    swap()  # for backtrack, common in generate combination problems

            solution = []
            currCandidate = []
                Do NOT need this we can iterate/recurse smartly and reuse outer function inputs, ie permutation.py P15.4.
                currCandidate can be also paseed as input to recurse, like power_set.py P15.5, where each recurse function need its own copy of candidate
            inner(seed)
            return solution
    """

    # ----------------------------
    # Know you libraries
    # ----------------------------

    return

def chap16_algo_dp() -> None:
    """
    pg 242

    DP is an algorithm
        - express a solution recursively in terms of previous sub solutions
        - applicable to problems like: optimization, combinations, and decision problems

    In relation to Divide&Conquer
        - Both combines solutions of smaller sub-problems. Both combines optimum solutions to subproblem to arrive at a global optimum (unlike greedy)
        - Unlike Divide&Conquer, DP sub-problem can appear over and over, (ie the same input argument). DP takes advantage of this pattern by
            (i) caching sub-problems solutions. We cache the result in a hash or a BST.
            (ii) iterate in a bottom up approach
        - Unlike Divide&Conquer, we are not dividing the problem to 2 EQUAL halves, such as quicksort

    In relation to recursion
        - Both uses recursion: identify the recurrence relationship and model it
        - However, recursion can be both SPACE and COMPUTATION inefficient.
            (i) Call stacks --> space.
            (ii) Repeating the same call with the same argument -> wasted computation.
            DP addresses (ii) by caching the result of the sub problem.  Caching will take some space though.

    To apply DP,
        (i) frame the original problem in such a way tha solving the sub problems can be used solve the original problem
            Because of this, one may need to think back from the solution. Ex: Find maximum sum sub array: find max contiguous sum
            SUPPOSE we look at the sub solution at index i. What are prior sub solutions at i-1?  What are the possible states that solution i can use?  Ans: either we use the solution at i-1 OR we start over.

        (ii) cache the solution to the sub-problem
        (iii)
    """

    """
    Leetcode notes on GoogleDrive

    Step1: How to recognize a problem is a DP? What is the recurrence?
        At this point, you work out an example, using the variables in problem, but not formalizing the state.  We have not formalized the recurrence in function form, but in example form
            Ex: diceTargetSum:
                Variables: dices, values, target
                Let assume we have 5 dices, each with 6 values
        Property1: Overlapping subproblems
            Solution to a sub-problem is used over and over.  Binary search can use recursion, but we do not reuse solutions.
            Applied to memoization (top down)
            similar to recursion but we use a lookup table before computing solution
            Applied to tabulation (bottom up)
            Builds a table up from base state, and return the last entry in table

        Property2: Optimal substructure
            optimal solution to a state depends on the optimal solution of other states
            Example: shortest path:

    Step2: Decide the state. What is the key to the lookup table?
        State is the set of parameters that can uniquely identify/describe a sub-solution. It is the key to a lookup cache. We want the state to be small (1-2)

        Using the example outlined in step1, you should be able to see which and how each variable changes at each sub-problem.

        In knapsack problem, the state is (index, weight). It can be the state of our answer, like n, in fibinacci.

        If take the memorization approach, the state becomes the key to your memorization AND many be the input to recursive function

        Example: diceTargetSum:
            dp(dice, value, target) =

    Step3: Formulate a relation among the states
        Hardest part of DP

        Since DP is a recurrence and uses sub solutions indexed by the state, how does one solve the general state?
            Example: diceTargetSum:
                dp( dice, value, target) =
                    dp(5, 6, 18) =  dp(4,6,17) + dp(4,6,16) + dp(4,6,15) + dp(4,6,14) + dp(4,6,13) + dp(4,6,12) +
            Example: Given 3 numbers {1, 3, 5}, what is the total number of ways to form a number N?
                Let’s assume we know dp[1], dp[2], dp[3], dp[4], dp[5], dp[6]

                what is dp[7]?
                    dp[7] = dp[7-1] + dp[7-3] + dp[7-5]

            Example: longest subsequence of 2 strings (longSubSequence)
            at each recurrence, what are the possible actions (i.e. match or no match)

    Step4: Optimize by adding tabulation or memoization
        Store the subproblem's answer : top down
            coinChange

        Tabulation makes the problem iterative; bottom up.
            longestPali | coinChange
    """

    # ----------------------------
    # Know you libraries
    # ----------------------------

    return

def chap17_algo_greedy_algos() -> None:
    """
    pg 268
    Local optimum approach does not guarantee global minimum

    """

    # ----------------------------
    # Know you libraries
    # ----------------------------

    return

def chap18_algo_graphs() -> None:
    """
    pg 284
    Key Points:
        - Model the problem using a graph (adjacency list) and solve it using a graph algorithm (DFS, BFS)

    Graph
        - are great to problems that has structure, and can be modeled the nodes and edges.  The answer to these questions is related on the structure BETWEEN the nodes and edges.
            * Examples: Shortest distance (BFS)
            * Example [optimizations]:

        - Unlike graphs, DP solution at i depends on [i-1, i+1]

        - Implementation:
            * Data model is implemented using adjacency lists or adjacency matrix (see code below)
            * answer to problem is achieved via graph search

    Types of Graph Search
        - General: DFS vs BFS
            * Both have run complexity: O(V + E) ; space complexity: O(V)
            * DFS:
                DIFF: gives discovery time and finishing time
                more intuitive to code since it leverages the call stack

            * BFS
                DIFF: gives distance from vertex; good for shortest distance problems

        - Optimization: Dijkstra's
    """

    # ----------------------------
    # Code Snippets
    # ----------------------------


    # ----------------------------
    # Know you libraries
    # ----------------------------
    from dataclasses import dataclass
    @dataclass
    class Shape:
        name: str
        num_sides: int

    # uToVs is from ONE source to multiple sinks
    Node = collections.namedtuple('Node', ('source', 'sink'))

    def build_graph(nodes): # via adjacency lists
        graph = collections.defaultdict(set)
        for n in nodes:
            graph[n.source].add(n.sink)  # WOW: We don't we need to check if graph has this node.
        print(graph)
        return graph

    build_graph([Node(1, 2), Node(2,3)])

    return



def chap19_algo_parallel_computing() -> None:
    """
    pg 300
    """

    # ----------------------------
    # Know you libraries
    # ----------------------------

    return