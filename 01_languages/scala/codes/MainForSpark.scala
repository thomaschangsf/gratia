package personalCode
import com.typesafe.config.ConfigFactory
import org.apache.hadoop.io.compress.GzipCodec
import org.apache.log4j.Logger
import org.apache.spark._ //SparkContext
import org.apache.spark.rdd.RDD


object MainForSpark extends BulkConfigKeys {

  val sc = new SparkContext()
  val log = Logger.getLogger(getClass.getName)

  def main(args: Array[String]): Unit = {

  }

  class Chapter3 {
    def coreIdeas = {
      /**
       * Creating RDD : 2 ways
       * 	Option 1: parallelize a collection
       * 	Option 2: text File
       */
      var linesViaCollection = sc.parallelize(List("Tom", "Chang"))
      var linesViaTextFile = sc.textFile("/Users/thchang/Documents/dev/git/SearchIndex")
      var inputRDD = linesViaTextFile

      /**
       * Operations : 2 Types
       * 	Transformations:
       * 		Creates a new RDD from the previous RDD
       * 		Transformations are lazy.  RDDA --> RDD_B --> Action. It is only at Action that RDD are computed
       *
       * 		RDD is by default, recomputed each time.  If you want to resuse, then rdd.persist().
       * 		Typically, use it for intermediate RDDs.
       *
       * 	Actions:
       * 		Compute a result from a RDD. Returns result to the driver program, or save to external storage
       */
      // Transformations
      val errorsRDD = inputRDD.filter(x => x.contains("error"))
      val warningsRDD = inputRDD.filter(x => x.contains("warningsRDD"))
      var badLines = errorsRDD.union(warningsRDD)

      // Actions
      badLines.collect() //combine the RDD, and put in one computer.  Solutions: chapter 5.
      badLines.take(10).foreach(println)
    }

    def showPassingFunctionsToRDD(rdds: RDD[String]) = {
      def addNumber(s: String) = {
        "1" + s
      }
      rdds.map(addNumber)
    }

    def showRDDTransformations() = {
      //basic: map, flatMap, filter, distinct

      val rdd1 = sc.parallelize(List(1, 2, 3))
      var rdd2 = sc.parallelize(List(3, 4, 5))

      rdd1.union(rdd2) //1,2,3,4,5
      rdd1.intersection(rdd2) //3
      rdd1.subtract(rdd2) //1,2
      rdd1.cartesian(rdd2)
    }

    def showRDDActions() = {
      var rdd = sc.parallelize(List(1, 2, 3, 3))

      rdd.collect() // List(1,2,3,3)
      rdd.count()
      rdd.countByValue() // returns a map {(1,1), (2,1), (3,2) }
      rdd.take(2) //returns num element from RDD
      rdd.top(2) // returns num elements based upon spark's ordering

      def myOrdering(a: RDD[Int], b: RDD[Int]): Boolean = {
        true
      }
      //rdd.takeOrdered(2)(myOrdering)

      rdd.takeSample(false, 3) // randomly choose 3 elements

      rdd.reduce((x, y) => x + y) // returns 9 = 1 + 2 + 3 + 3

      // Similar to reduce, but start with an offset
      rdd.fold(10)((x, y) => x + y) // returns 19 = 10 + 1 + 2 + 3+ 3

      // Similar to reduce, but can return different types
      // rdd.aggregate(

    }

    def showCaching() = {

      var linesViaTextFile = sc.textFile("/Users/thchang/Documents/dev/git/SearchIndex")
      val inputRDD = linesViaTextFile

      inputRDD.persist(StorageLevel.MEMORY_AND_DISK)
      /**
       * Different storage level impacts memory space(RAM), CPU time, OR disk
       *
       * MEMORY_ONLY
       * MEMORY_ONLY_SER
       * MEMORY_AND_DISK
       * MEMORY_AND_DISK_SER
       * DISK_ONLY
       */

    }
  }

  /**
   * Working with Key/Value Pairs
   */
  class Chapter4 {
    var linesRDD = sc.textFile("/Users/thchang/Documents/dev/git/SearchIndex")

    // Creating Pair RDD
    var pairRDDs = linesRDD.map(x => (x.split(" ")(0), x))
    var familyRDD = sc.parallelize(List(("Tom Chang", 39), ("Bernice Chang", 39), ("Caryse Chang", 8), ("Mason Chang", 4)))
    var numberRdd = sc.parallelize(List((1, 2), (3, 4), (3, 6)))

    def showTransformations() = {
      def showSingleRDD() = {
        // Combine VALUES of the same key. {(1,2), (3,10)}
        numberRdd.reduceByKey((x, y) => x + y)

        // Group values with the same key. {(1,[2]), (3,[4,6])}
        numberRdd.groupByKey()

        // Apply a funciton to EACH value of key value pair.
        numberRdd.mapValues(x => x + 1) //{(1,3), (3,5), (3,7)}

        numberRdd.values
        numberRdd.keys
        numberRdd.sortByKey()
      }

      def showMultipleRDD() = {
        var otherRdd = sc.parallelize(List((3, 9)))

        // Remove pairs from numberRdd that has keys in otherRDD. {(1,2)}
        numberRdd.subtractByKey(otherRdd)

        // Inner join on common keys {(3,(4,9)), (3, (6,9))}
        numberRdd.join(otherRdd)


        // Left refers to numberRdd, whose element is always there {(1,(2,None)), (3, (4,Some(9)), (3,(6,Some(9))))
        numberRdd.leftOuterJoin(otherRdd)
        numberRdd.leftOuterJoin(otherRdd)

      }

    } // end of showTransformations

    def showActions() = {
      // Counts the number of values for EACH key
      numberRdd.countByKey()

      // Collect the result as a Map Map{(1,2), (3,4), (3,6)}
      numberRdd.collectAsMap()

      // [4,6]
      numberRdd.lookup(3)
    }

    def showPartitioning() = {
      /**
       * Partitioning minimizes network traffic by putting "similar" data on the same node.
       */

      val familyRDD = sc.parallelize(List(("Tom Chang", 39), ("Bernice Chang", 39), ("Caryse Chang", 8), ("Mason Chang", 4)))

      // RDDs are immutable. 

      val dataPartitioned = familyRDD
        .partitionBy(new HashPartitioner(100)) //partitionBy is a transformation, returns a new RDD.  This is why we need to persist.
        .persist() // number of partition >= number of cpu cores

      dataPartitioned.partitioner // returns the partitioner used

      /**
       * Operations benefit from paritioning:
       * 		- involve shuffling data by keys across network
       * 		- cogroup(), groupWith()
       * 		- join, leftOuterJoin, rightOuterJoin, groupByKey
       * 		- reduceByKey, combineByKEy
       * 		- lookup
       */

      /**
       * Page Rank
       *
       * 1) Initialize each page rank to 1.0
       * 2) On each iteration, have page p send a contribution of rank(p)/numNeighhoers(p) to its neighors, ie the links of this page
       * 3) Set each page's rank to 0.15 + 0.85 * contributionReceived
       *
       *
       * Neighborlists was saved as a Spark objetFile
       * val links = sc.objectFile[(String, Seq[String])]("links")
       * 								.partitionBy(new HashPartitioner(100))
       * 								.persist()
       *
       * Initialize each page's rank to 1.0.  mapValues returns RDD with the same paritioner as links
       * var ranks = links.mapValues(v => 1.0)
       *
       * for (i <- 0 until 10) {
       * 		val contributions = links.join(ranks).flatMap {
       * 			case(pageId, (pageLinks, rank)) =>
       * 				pageLinks.map(dest => (dest, rank / pageLinks.size))
       * 		}
       * 		ranks = contributions.reduceByKey((x,y) => x+y)
       * 													.mapvalues(v => 0.15 * 0.85 *v )
       * }
       * ranks.saveAsTextFile
       *
       */
    }
  }

  /**
   * Advanced Spark Programming
   *
   * Shared variables
   * 		- Accumulators : to aggregate information
   * 		- Broadcast variables : efficiently distribute large values
   *
   * Pipe() - interact with other programs
   *
   * Working with numeric data
   *
   */
  class Chapter6 {

    /* Accumulators allow each worker to compute a value and send it back to the driver program. Can be used for debugging purposes.*/
    def showSharedVariables_Accumulators() = {
      val file = sc.textFile("file.txt")
      val blankLines = sc.accumulator(0)

      val callSignes = file.flatMap(line => {
        if (line == "") {
          blankLines += 1 // each worker node can count their blandLines. At the finish, each variable will be sent back to driver program and aggregated.
        }
        line.split(" ")
      })
    }

    /* Broadcast variables allow program to send a large, READ-ONLY value to ALL the WORKER-NODES.  Compare to accumulators, it's the opoosite direction */
    def showSharedVariables_BroadCastVariables() = {

    }

    /* Some operations are done per partition, ie open database connection. Use mapParitions, mapParitionWithinIndex, foreachPartition */
    def showOperationsOnPerParition() = {
      //val signs = List() 
      //signs.distinct.mapParitions {
      //  eachSign =>
      //    print 1
      //}
    }

    /* Enables you for spark to call other language programs, ie R */
    def showPipe() = {

    }

    /* Numerics operations one can apply on a RDD or the StatsCounter object*/
    def showNumerics() = {

      var distanceRdd = sc.parallelize(List("1.1", "12", "4"))
      var distanceRddDoubles = distanceRdd.map(x => x.toDouble)
      var stats: StatCounter = distanceRddDoubles.stats();

      val mean = stats.mean
      val stddev = stats.stdev

      def removeOutlier = { distanceRddDoubles.filter(x => math.abs(x - mean) < 3 * stddev) }
    }
  }

  /**
   * - Driver
   * 		- Converts a user main program into tasks
   * 			- instantiates a SparkContext
   * 			- creates RDD
   * 			- RDD transformations and actions is converted to a Directed Acyclic graph of operations, arranged in stages, where each stage consist of multiple tasks
   * 		- Scheduling tasks on executors
   * 			- The driver will look at the registered executors, and try to place the tasks where the data resides (also cached data).
   * 			- First send the application the executor
   * 			- Then send the task to the executor
   * 		- Expose a web interface at localhost:4040
   * 		- Launched via spark-submit
   * - Cluster Managers
   * 		- Launches executors
   * 		- Can be hadoop YARN
   * - Executors
   * 		- Each executor on a worker node refers to the driver’s sparkContext object
   * 		- Each worker node = 1 vm
   * 				- 1 executor = 1 process
   * 				- has many taks (task ~= thread)
   * 				- Is where the RDD is
   */
  class Chapter7 {

    /*
     * (1) User submits an application using spark-submit
     * (2) Spark-submit launches the driver program and invokes the main method specified by user
     * (3) The driver program contacts the cluster manager (Standalone, YARN, MESOS) to ask for resources to launch executors
     * (4) Cluster manager launch the executors (VM) on behalf of driver programs
     * (5) The driver process runs through the user application. Based on the RDD actions and transformations 
     * 			in the program, the driver sends work to executors in the form of TASKS.
     * (6) Tasks are run on executor processes to compute and save results
     * (7) If the driver's main method exists or it calls SparkContext.stop(), it will terminate the executors and release 
     * 			resources from the cluster managers.
     */

    /*
     * Example: spark-submit --class com.ebay.n.search.TestForwardIndexV2 --master local[2]  ./target/scala-2.10/SearchIndexBuild-assembly-1.0-SNAPSHOT.jar "file://Users/thchang/Documents/dev/git/SearchIndex/gs/search-index/qa/34M-test1"
     * 
     * Spark submit
     * 	--master : indicates the cluster manager to connect to
     * 			spark://host:port = connect to a Spark Standalone cluster. By default, port is 7077
     * 			mesos://host:port = connect to a Mesos cluster
     * 			yarn : connect to a YARN cluster. Need to set HADOOP_CONF_DIR
     * 			local : run in local mode on a single core
     * 			local[N] : run in local mode with N cores
     * 
     * 	--deploy-mode :
     * 			client : will run the driver on the same machine as the spark-submit. DEFAULT.
     * 			cluster : the driver will be shipped on a worker node in the cluster.
     *  --class : The main class of  your application
     *  --executor-memory : The amount of memory to use for executors, in bytes
     *  --driver-memory : The amount of moemory for the driver process, in bytes
     */

    // Book has more on how to connect to specific clusters managers.
  }

  /**
   * Components of Executions: Jobs, Tasks, and Stages
   */
  class Chapter8_TuningAndDebuggingSpark {
    // Logical view: RDD and Partitions
    // Physical view: translate the logical view into physical execution plan by merging multiple operations into TASKS.

    // RDD have meta data, ie has a directed acyclic graph to other RDD objects, ie ancestor
    // This relationship is used upon an action is executed.
    // To see this relationship, aRDD.toDebugString
    // Example
    val input = sc.textFile("input.text") // input.text is a input of info/error/warning
    input.toDebugString

    val tokenized = input.filter(line => line.size > 0).map(line => line.split(" "))
    tokenized.toDebugString

    val counts = tokenized
      .map(words => (words(0), 1))
      .reduceByKey { (a, b) => a + b }

    /* The Spark scheduler creates an execution plan upon an action.  It first start
     * with the final RDD (count), and work backward to develop a physcial plan to compute all 
     * the ancestor RDDs (tokenized, input). Scheduler will organize the plan as stages.
     * 
     * UI: localhost:4040
     */
    counts.collect()

    def tuningPerformanceViaParallelism() = {
      /*
       * An RDD is partitioned, where each partition contains a subset of the RDD
       * Each partition is executed by a task, which runs on at least 1 core
       * This parallelism is based on the underlying storage
       * 		For HDFS, one partition per block
       *
       * 	A new stage begins every time the job requires communication between partitions; this communication is aka shuffle
       * 	Task transforms a partition of RDD_A to a partition of RDD_B
       * 	Stage consists of multiple tasks, running on one machine
       * 	Stage is created when 2 partition needs to talk to each other
       */

      /* Tune parallelism by:
       * (1) RDD with operations that shuffles, proved the parallelism with the RDD. Shuffles moves data from one machine to another.
       * 		Stages are built by DAGScheduler, based on RDD's shuffleDependency. Each shuffleDependency maps to one stage and will lead to shuffling.
       * 		
       * 		Potential cost of shuffling: data partition, serialization/deserialization, data compression
       * 
       * 		shuffle operations: repartition, combineByKey, GroupByKey, ReduceByKey, cogroup
       * 
       * (2) Change an RDD parition
       * 		parition(10) --> split into 10 paritions
       * 		coalesc() --> reduce number of partition, and avoids shuffling
       * 
       * Other notes: http://www.slideshare.net/databricks/strata-sj-everyday-im-shuffling-tips-for-writing-better-spark-programs
       * 		Prefer reduceByKey vs groupByKeys
       */

      input.getNumPartitions
      input.coalesce(numPartitions = 5, shuffle = false)
    }

    def tuningPerformanceViaSerialization() = {
      // Kyro
    }

    def turningPerformanceViaMemoryManagement() = {
      /**
       * (1) RDD Storage (Default = 60%)
       * 		When I call persist or cache on an RDD, its partition will be stored in memory buffer.  
       * 		If exceed storage.memoryFraction, older partition will be dropped from memory.
       * 
       * (2) Shuffle and Aggregation Buffers (Default = 20%)
       * 		When shuffle operations, spark will create intermediate buffers to store intermediate results and aggregation. 
       * 		spark will try to limit this usage to the spark.shuffle.memoryFraction
       * 
       * (3) User code limit (Default = 20%)
       * 
       */
      
    } // end of Chapter8_TuningAndDebuggingSpark

    class Chapter11_MachineLearningWithMLlib {
      /**
        * General flow
        * (1) Collect data
        * (2) Run MLlib feature extraction, and represent as numerical features, ie feature vector
        *     What are some set of relevant features? This is some of the hardest part.
        *       In detecting spam, features may be
        *         - how many times free is mentioned
        *         - color of the text
        *     Extract the feature as nummerical features, ie vectors.
        *       In text classification, the featurized text may include counting the frequency of each word.
        *
        * (3) Apply one of the alogorithms
        *   supervised: classification, logistic regression
        *   unsupervised: clustering
        * (4) Evaluate model on a test data set using MLlib's evaluation functions
        *
        * - Also look at my dev/git/sparkMockingBird/MySparkMockingBird example.  Very detailed working example.
        */
        class SpamClassification {

          def main() = {
            val spam = sc.textFile("spam.txt")
            val normal = sc.textFile("normal.txt")

            // Create feature vector using HashingTF to map email text to vectors of 10,0000 features
            val tf = new HashingTF(numFeatures = 10000)
            // Each email is split into words, and each word is mapped to one feature
            val spamFeatures = spam.map( email => tf.transform(email.split(" ")))
            val nomralFeatures = normal.map ( email => tf.transform(email.split(" ")))

            // Create labeledPoints datasets
            val positiveExamples = spamFeatures.map(features => LabeledPoint(1, features))
            val negativeExamples = normalFeatures.map(features => LabeledPoint(0, features))
            val trainingData = positiveExamples.union(negativeExamples)
            trainingData.cache()

            // Run logistic regression using the SGD alogirthm
            val model = new LogisticRegresssionWIthSGD().run(trainingData)

            // Test
            // Transform a test text into a feature vector
            val posTest = tf.transform("O M G Get cheap stuff".split(" "))

            // Apply the test feature vector to model to make a prediction
            val result = model.predict(posTest)

          }


      }

      /**
        * Data types
        *
        * 1) Vectors - stored as dense or sparse, ie only non-zeoros terms are stored
        * 2) Labeled Point - is a feature vector + a lablel
        * 3) Rating - rating of a product by a user
        * 4) Model classes - result of training algorithm, and has the predict method
        */

      // Creating a vector
      val denseVector1 = Vecors.dense(1.0, 2.0, 3.0)
      val denseVector2 = Vectors.dense(Array(1.0,2.0))
      val sparseVector = Vectors.sparse(4, Array(0,2))

      class Algorithm {
        // How to extract features
        def HowToGenerateFeatureVectors = {
          // Ex1: TF-IDF - generates feature vectors from text documents
          // For EACH docuemnt, it calculates
          //    TF = term frequency = number of times ther term occurs in the doc
          //    IDF = inverse document frequency = how INFREQUENTY a term occurs across the corpus
          // Spark has 2 algorithms : HashingTF and IDF

          // Ex2: Word2Vec - generates feature vectors for text based on neural network (https://code.google.com/p/word2vc

          /** To improve the results using the feature vectors
            *
            * 1) Scaling - scale all features in the feature vector to have the same weight,
            *     Ex: All features have a mean of 0, and a standard devation of 1
            *
            * 2) Normalization
            *     Ex: Normalize the feature vector to have an Eucledian distance of 1
            *     Ex: Normalize the input toe the TF-IDF by applying stemmers,e tc..
            */

        }

        def UseStatisticsToAnalyzerData = {
          val rdd = sc.parallelize(List(1,2,3))

          //Returns the min, max, mean, and variance for each column of the feature vector
          Statistics.colStat(rdd)

          //Computes the correlation matrix between coluns in a RDD of vectors, using the Pearson or Spearman correlation
          Statistics.corr(rdd, method=pearson)

          // Computes the p-value, test statistic, and degrees of freedom for each feature
          Statistics.chiSqTest(rdd)

        }

        // Supervised Algorithms
        def ClassificationAndRegressionAlgorithms = {
          /** Predicted values:
            *   Classification --> prediction are discrete classes (spam, notSpam)
            *   Regression --> prediction are continous, ie confidence that the item is of brand Nike
            * */

          def showLinearRegressions : Double = {
            /**
              * Tuning parameters
              * - numIterations : numInterations to run (default = 100)
              * - stepSize : step size of the gradient descent (default: 1.0)
              * - intercept : add bias feature to the ata (default = false
              * - regParam : regularization parameter for Lasso and ridge
              */

            val points: RDD[LabeledPoint] = //
            val logisticRegressionAlgo = new LinearRegressionWithSGD().setNumIterations(200).setIntercept(false)
            val model = logisticRegressionAlgo.run(points)

            val someInputVector = HashingTF.transform("some sample input")
            val prediction = model.predict(someInputVector)
          }

          def showLogisticRegression : Boolean = {
            /**
              * Is binary classification alogrithm, ie male or female
              *
              * Has 2 algorithms :
              *   SGD - Stochastic Gradient Descent
              *   LBFGS - is a newton approximation, that converges in fewer iterations
              *
              * LogisticRegressionModel returns a 0/1 based on the setThreshold()
              */

          }

          def SupportVectorMachine : Boolean = {
            /**
              * Is a binary classification model
              *
              * Like LogisticRegression, also needs a threshold
              */
          }

          def NaiveBayes : Boolean = {
            /**
              * Is a MULTI-CLASS classification algorithm that scores how well each point belongs in each class based on a linear fucntion of the features
              *
              * Often used in text classification with TD-IDF features
              */
          }

          def TreesAndRandomForests = {
            /**
              * Can be used for both classifications and regressions.
              */
          }

        } // end of class ClassificationAndAlgorithms


        // Unsupervised algorithms - does not use labeled data
        class ClusteringAlgorithms {

          def Kmeans = {
            /**
              * Hyper-parameters:
              *   - K : number of clusters. Iterative process.  Try until the average intracluster distances stops decreasing dramatically
              *   - initializationMode: random or kmeans||. kmeans|| usually is better result, but more costly
              *   - maxIterations : max number of iterations to run (default: 100)
              *   - runs : number of concurrent runs of algorithms to executes
              */
          }
        } //end of class ClusteringAlgorithms

        // Used in recommendation systems.
       class CollaborativeFIlteraingAndRecommendationAlgorithm  {
          /**
            * Take a user A's ratings and A's interaction to other products (ie what A buys, what A browses) to recommend new ones
            *
            * Ebay: Can I use this for our personalized search engine?
            */


          def showAlternativeLeastSquares = {
            /**
              * Determine a feature vector for each user and product, such that the dot product of the user's vector and product is close to their score
              *
              * Hyperparameters:
              *   - rank : size of feature vectors to use. Larger ranks = better result, but more expensive
              *   - iterations : number of iterations to run (default = 10)
              *   - lambda : regularization paramters (default = 0.01)
              *   - alpha : constant used for computing confidence in implicit ALS (default 1.0)
              *   - numUserBlocks, numProductBlocks : number of blockes to divide user and product data into.
              *
              */
          }
        }

        // Reduce the number of dimensions in the feature vector(?) via Principal Component Analysis (en.wikipedia.org/wiki/Principal_component_analysis)
        // Eseentially, mape to the lower dimensional representation such that the lower dimension representation hhave high variance, therefore, meaning we can ignore them.
        class DimensionalityReduction {

          def showPCA = {
            val points : RDD[Vector] = //
            val mat: RowMatrix = new RowMatrix(points)
            val pc: Matrix = mat.computePrincipalComponents(2)

            // Project points to low-dimensional space
            val projected = mat.multiply(pc).rows

            val model = KMeans.train(projected, 10)

          }
        }
      } // end of Algorithms

      class ModelEvaluation {
        /** This part is in experimental code stage
          *
          */
      }

      class TipAndPerformance {
        def preparingFeatures = {
          /**
            * Result is only as goode as the data in.
            * - scale your input features to weigh features equally. Use StandardScaler
            * - Feature text correctly, ie stem, use IDF across a representative corpus for TF-IDF
            * - Label classes correctly
            */
        }

        def tuneEachAlgoHyperParameters = {

        }

        def cacheRddToResuse = {
          /**
            * rdd.cache before passing them to MLlib. Even if it does not fit, try persist(StorageLEvel.DISK_ONLY)
            *
            *
            */
        }

        def levelOfParallelism = {
          /**
            * Number of partitions >= number of cores
            *
            * Spark typically creates a parition for every block of file, which is 64MB
            *
            * But having too many partitions will increase communication cost
            */
        }
      }


    }//end of Chapter11_MachineLearningWithMLlib. TO see latest doc, spark.apache.org/documentation.html
  }

}