# https://www.youtube.com/watch?v=LDRbO9a6XPU
# Decision trees (classification)
#   CART: Classification and Regression Trees
#   Root will receive all the training set. Root node will ask a question (what feature and split value), and child node will get the data.
#   Goal of each node: produce the pureset possible label at each node (minimize the impurity)

#   Key questions
#       (1) which question to ask? For a node at level k, what feature is the node going to use, and what's the split point
#       (2) when ?  At which node are we going to

# To help ask the questions, we can quanity the amount of uncertainity at a SINGLE node via the metric Gini impurity
# How much we reduce the uncertainity is called information gain


# ##################################################################################################
# Based on
#   Github:     https://github.com/random-forests/tutorials/blob/master/decision_tree.ipynb @ @
#   Youtube:    https://www.youtube.com/watch?v=LDRbO9a6XPU
# ##################################################################################################
def showDecisionTree():
    header = ["color", "diameter", "label"]
    training_data = [
        ['Green', 3, 'Apple'],
        ['Yellow', 3, 'Apple'],
        ['Red', 1, 'Grape'],
        ['Red', 1, 'Grape'],
        ['Yellow', 3, 'Lemon'],
    ]

    def unique_vals(rows, col):
        set([row[col] for row in rows])

    # returns number of each class in label
    def class_counts(rows):
        counts = {}
        for row in rows:
            label = row[-1]
            if label not in counts:
                counts[label] = 0
            counts[label] += 1
        return counts

    def is_numeric(self, value):
        return isinstance(value, int) or isinstance(value, float)

    class Question:
        def __init__(self, column, value):
            self.column = column
            self.value = value

        #example = data set
        def match(self, example):
            val = example[self.column]
            if self.is_numeric(example):
                return val >= self.value
            else: #categorical
                return val == self.value

        def __repr__(self):
            # This is just a helper method to print
            # the question in a readable format.
            condition = "=="
            if is_numeric(self.value):
                condition = ">="
            return "Is %s %s %s?" % (header[self.column], condition, str(self.value))

    # separate the frows into two groups, true or false
    def partition(rows, question):
        true_rows, false_rows = [], []
        for row in rows:
            if question.match(row):
                true_rows.append(row)
            else:
                false_rows.append(row)
        return true_rows, false_rows

    # gini = [0 - 1];  (gini=0)-> only 1 class -> Best
    def gini(rows):
        counts = class_counts(rows)
        impurity = 1
        for lbl in counts:
            prob_of_label = counts[lbl] / float(len(rows))
            impurity = impurity - prob_of_label **2

        return impurity

    def info_gain(left, right, current_uncertainity):
        p = float( len(left) / (len(left) + len(right)))
        current_uncertainity - gini(left) * p - gini(right) * (1-p)

    def find_best_splits(rows):

        best_info_gain = 0
        best_question = None

        current_uncertainity = gini(rows)

        n_features = len(rows[0]) -1

        for feature_col in range(n_features):

            feature_values =  unique_vals(rows, feature_col)

            for val in feature_values:
                question = Question(feature_col, val)

                true_rows, false_rows = partition(rows, question)

                if len(true_rows)==0 or len(false_rows)==0:
                    continue

                curr_info_gain = info_gain(true_rows, false_rows, current_uncertainity)

                if curr_info_gain > best_info_gain:
                    best_info_gain, best_question = curr_info_gain, question

        return best_info_gain, best_question

    def build_tree(rows):

        gain, question = find_best_splits(rows)

        if gain == 0:
            return

        true_rows, false_rows = partition(rows, question)

        true_branch = build_tree(true_rows)

        false_branch = build_tree(false_rows)

        # Return a Question node.
        # This records the best feature / value to ask at this point,
        # as well as the branches to follow
        # dependingo on the answer.
        return Decision_Node(question, true_branch, false_branch)