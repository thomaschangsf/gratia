package personalCode

import java.io.{File, InputStream, PrintWriter}

import personalCode.fp.{None, Option, Some}

object fp extends App {
  val as = Array(1, 2, 3)

  System.out.println(fib(4));
  val as1 = Array(5, 2, 3)
  // Here, we are using function literal
  val result = isSorted(as1, (a: Int, b: Int) => {
    a > b
  })
  val ex1 = Nilly

  System.out.println("FindFirst=" + findFirst(as, isEqualTo2))
  val ex2 = Cons(1, Nilly)
  val ex3 = Cons("a", Cons("b", Nilly))
  val ds = List(1, 2, 3, 4)
  System.out.println("IsSorted=" + result)
  val result2 = dropWhile(ds, (x: Int) => {
    x % 2 != 0
  })

  //fnc: (A,B) => C . Input parameter is a fnc that has 2 parameters A B and returns a value of type C,
  //Returns a function of 1 function that is partially applied
  val x = None
  val y = Option
  val z = Some

  /**
    * *************************
    * CHAPTER 2
    * *************************
    */

  // ----------------------------------------------------
  // Example 2.01: fib.  Writing loop functionally
  // Define an inner function
  // ----------------------------------------------------
  def fib(n: Int): Int = {
    def loop(n: Int, prev: Int, curr: Int): Int = {
      if (n == 0) prev;
      else loop(n - 1, curr, prev + curr)
    }
    loop(n, 0, 1)
  }

  // ----------------------------------------------------
  // Polymorphic function: functions that operate on multiple data types. Here A is what makes this polymorphic.
  // High order function: functions that takes function as input
  // ----------------------------------------------------
  def findFirst[A](as: Array[A], fnc: (A) => Boolean): Int = {
    def loop(n: Int): Int = {
      if (n >= as.length) -1
      else if (fnc(as(n))) n
      else loop(n + 1)
    }
    loop(0)
  }

  def isEqualTo2(i: Int): Boolean = {
    i == 5;
  }

  def isSorted[A](as: Array[A], gt: (A, A) => Boolean): Boolean = {
    def go(n: Int): Boolean = {
      if (n > as.length - 1) true;
      else if (gt(as(n), as(n + 1))) false
      else go(n + 1)
    }
    go(0)
  }

  // ----------------------------------------------------
  // Currying: partial applying a function
  // ----------------------------------------------------
  def curry[A, B, C](fnc: (A, B) => C): A => (B => C) = {
    a => b => fnc(a, b)
  }

  // ----------------------------------------------------
  // Implement a higher order function that composes 2 functions, ie f(g(x))
  // Compose takes 2 functions, that each take one parameter of type B and A
  // And returns a function that takes a input of type A, and return a type C
  // ----------------------------------------------------
  def compose[A, B, C](f: (B) => C, g: (A) => B): (A) => C = {
    //Since g takes a input parameter of type A, z is of type A
    (z) => f(g(z))
  }

  // ----------------------------------------------------
  // Example 3.03 Remove the head of a list
  // ----------------------------------------------------
  def tail[A](ds: List[A]): List[A] =
  ds match {
    case Nilly => sys.error("Cannot tail empty lst")
    // We are actually not creating new data strucutre. This is a immutable linked list, so we are playing with pointers
    case Cons(_, t) => t
  }

  // ----------------------------------------------------
  // Example 3.04 Remove the first n element of a list
  // ----------------------------------------------------
  def drop[A](ds: List[A], n: Int): List[A] = {
    if (n <= 0) ds
    else ds match {
      case Nilly => Nilly
      case Cons(_, t) => drop(t, n - 1)
    }
  }

  // ----------------------------------------------------
  // Example 3.05 Drop all elements that matches a predicate. All these examples show data sharing. We are not creating new ds
  // ----------------------------------------------------
  def dropWhile[A](ds: List[A], predicate: (A) => Boolean): List[A] = {
    ds match {
      case Cons(h, t) if predicate(h) => dropWhile(t, predicate)
      case _ => ds
    }
  }

  // Example appends all the elments in a to b
  def append[A](a: List[A], b: List[A]): List[A] = {
    a match {
      case Nilly => b
      case Cons(h, t) => Cons(h, append(t, a))
    }
  }

  System.out.print("DropWhile=" + result2)

  //Cons(2,Cons(3,Cons(4,Nilly))) sharing data here.

  // foldRight = abstraction to apply anonymous fnc f from left to right on the elements in as
  // as is a list, z is termination value
  // We split the 3 parameters into (2 parameter)(anonymous fun) to assist in type inference when passing an anonymous func.
  // foldRight(as, 0, (x:Int, y:Int) => x+y)
  // VS foldRight(as, 0, (x, y) => x+y) line 176
  def foldRight[A, B](as: List[A], z: B)(f: (A, B) => B): B = {
    as match {
      case Nilly => z
      case Cons(x, xs) => f(x, foldRight(xs, z)(f))
    }
  }

  def sum(ds: List[Double]): Double = {
    // Scala infers the type of A and B based on the parameter you passed in. Since ds is a Double, foldRight expect B to be double as well
    foldRight(ds, 0.0)((x, y) => x + y)
    //foldRight(ds, 0.0)((x:Double, y:Double) => x + y)
  }

  /**
    * What the hell is going on? x is the first element of ds.  But what about y? y is the recursive call, and returns only once all the terms on the right of the array has been calcualted. Let's look at call stack
    * foldRight(Cons(1,Cons(2, Cons(3, Nil))), 0) ((x,y) => x+y)
    * 1 + foldRight(Cons(2, Cons(3, Nil))), 0) ((x,y) => x+y)
    * 1 + 2 + foldRight(Cons(3, Nil))), 0) ((x,y) => x+y)
    * 1 + 2 + 3 + foldRight(Nil, 0)
    * 1 + 2 + 3 + 0
    *
    */

  // Find the length of an Seq using foldRight
  def length(ds: List[Double]) {
    foldRight(ds, 0)((x, acc) => acc + 1)
  }

  // foldRight is not tail safe (ie stack safe). Solution: foldLeft
  def foldLeft[A, B](as: List[A], z: B)(f: (B, A) => B): B = {
    as match {
      case Nilly => z
      case Cons(h, t) => foldLeft(t, f(z: B, h: A))(f)
    }
  }

  def sum3(ds: List[Int]) {
    foldLeft(ds, 0)((x, y) => x + y)
  }

  def f(x: Any): Int = {
    x match {
      case _ => 1
      case None => 2
    }
  }

  /**
    * *************************
    * CHAPTER 3: Functional data structures
    * Functional programs do not update variables or modify MUTABLE data structures.
    * Functional data structures are IMMUTABLE. But that does not mean we create lots of copies
    * *************************
    */
  sealed trait List[+A]

  trait Option[+A] {
    val t = Some(22) getOrElse 3

    map((x: A) => x) getOrElse None
    Option(1) map ((x: Int) => 2 * x)
    Option(1).map((x: Int) => 2 * x)
    // returns22
    val v = None getOrElse {
      -1
    }
    // returns -1
    val fnc = (x: Int) => None
    //fnc returns Option[Something]
    val u = fnc(2) getOrElse { (x: Int) => 2 * x }
    //returns 4
    val options = List(Option(1), Option(2), None)

    // Apply f to the OPtion if NOT None
    def flapMap[B](f: A => Option[B]): Option[B] = {
      map(f) getOrElse None
    }

    // Apply f if Option is NOT None
    def map[B](f: A => B): Option[B] = {
      this match {
        //this refers to the Option itself
        case None => None
        case Some(a) => Some(f(a)) // a refers to this, which refers to Option
      }
    }

    // B>:A means B must be a supertype of A
    // Return the option's value if option is NOT empty. Otherwise return the result of evaluating default.
    def getOrElse[B >: A](default: => B): B = {
      this match {
        case None => default
        case Some(a) => a
      }
    }

    // Don'e evaluate obj unless needed
    def orElse[B >: A](obj: => Option[B]): Option[B] = {
      this match {
        case None => obj
        case _ => this
      }
    }

    // Convert Some to None if the value doesn't satisfy f
    def filter(f: A => Boolean): Option[A] = {
      this match {
        case Some(a) if f(a) => this // a refers to this, which refers to Option
        case _ => None
      }
    }

  }

  // Constructor 1: Nilly is an empty List
  case class Cons[+A](head: A, tail: List[A]) extends List[A]

  case class Some[+A](x: A) extends Option[A]

  // +A ==> covariant; sealed=all implementation/subclasses defined in this file
  // Following are data constructors: are functions to construct that form of data type
  case object Nilly extends List[Nothing]

  // object = singleton. When it has the same name as a class, then it's called a companion object
  object List {

    // Examples of case matching
    val ds = List(1, 2, 3, 4, 5)

    // Notice how we don't need a loop
    // Pattern matching is a fancy switch statement, that descend into the STRUCTURE of expressions (ds)
    // and extract sub-expression of that structure.
    def product(ds: List[Double]): Double = ds match {
      case Nilly => 1.0
      // pattern => result
      case Cons(0.0, _) => 0.0
      case Cons(x, xs) => x * product(xs)
    }

    // Variadic function: accepts 0 or more elements. ie List(1,2,3) aka List literal.
    // It is syntatic sugar to create a Seq (interface to List, Queue). A* = Seq(1,2,3)
    def apply[A](as: A*): List[A] = {
      if (as.isEmpty) Nilly
      else Cons(as.head, apply(as.tail: _*))
    }

    def example(ds: List[Double]): Double = ds match {
      case Cons(0.0, _) => 0.0
      case Cons(x, Cons(y, Cons(3, Cons(4, _)))) => x + y // match, return 1+2=3; _=5
      case Cons(h, _) => h // match as well, but will return previous one; h=1
      //case Cons(_, t) => t // match as well, t=2,3,4,5
      case _ => 101
    }
  }

  /**
    * *************************
    * CHAPTER 4: Exception handling
    * Exception are not Referential Transparent, and introduce context dependence. The final output depends on the which exception handler it resides.
    * Exception are not type safe/or checked.  Will be run time.
    * Solution: use Option type
    *
    * Object implements the Null Object pattern.
    * It is an abstract class, with 2 subclasses: Some & None
    * It is also a Monad
    * *************************
    */
  case object None extends Option[Nothing]

  //options.map( (x:Int) => x)

}

case object Empty extends LinkedList[Nothing]

case class Node[+E](head: E, tail: LinkedList[E]) extends LinkedList[E]

trait LinkedList[+E] {
  def map[R](f: E => R): LinkedList[R] = {
    // this refers to the linked list itself
    this match {
      case Node(head, tail) => Node(f(head), tail.map(f))
      case Empty => Empty

    }
  }
}

case class ErrorHandlineViaOption() {
  val x = toInt("1")
  //returns Option[Int] = Some(1)
  val y = toInt("foo")
  //return Option[Int] = None
  // Using Option with collections
  val bag = List("1", "2", "foo", "3", "bar")

  toInt("1") match {
    case Some(i) => println(i)
    case None => println("That didn't work.")
  }

  /*
   * Option disregards bad inputs by ignoring the values
   *	- returns objects of Some, None type
   *  - convert Some, None to int or default value getOrElse(0)
   *  - can also use match
   */
  def toInt(s: String): Option[Int] = {
    try {
      Some(Integer.parseInt(s.trim))
    } catch {
      case e: Exception => None
    }
  }

  bag.map(toInt) //res0: List[Option[Int]] = List(Some(1), Some(2), None, Some(3), None)

  //remove bad values List(1, 2, 3)
  bag.map(toInt).flatten // method 1
  bag.flatMap(toInt) // method 2
  bag.map(toInt).collect { case Some(i) => i } //method 3

  /* Example with 3rd party library
  def getAll() : List[Stock] = {
    DB.withConnection { implicit connection =>
        sqlQuery().collect {
            // the 'company' field has a value
            case Row(id: Int, symbol: String, Some(company: String)) =>
                    Stock(id, symbol, Some(company))
            // the 'company' field does not have a value
            case Row(id: Int, symbol: String, None) =>
                    Stock(id, symbol, None)
        }.toList
     }
	}
	*/
}

case class ErrorValidationViaTryFailure() {

  /* Benefit of Try
   * ability to pipeline, or chain, operations, catching exceptions along 
   * the way. You can map as you would a collection, an option or a 
   * right projection of an Either*/

  val x = divideXByY(1, 1).getOrElse(0)

  divideXByY(1, 1) //res0: scala.util.Try[Int] = Success(1)
  divideXByY(1, 0)
  //res1: scala.util.Try[Int] = Failure(java.lang.ArithmeticException: / by zero)
  // returns 1
  val y = divideXByY(1, 0).getOrElse(0)
  // returns 0
  // Can use Try to chain operations, always giving safe result
  val z = for {
    a <- Try(x.toInt)
    b <- Try(y.toInt)
  } yield a * b

  divideXByY(1, 1) match {
    case Success(i) => println(s"Success, value is: $i")
    case Failure(s) => println(s"Failed, message is: $s")
  }
  val answer = z.getOrElse(0) * 2

  def divideXByY(x: Int, y: Int): Try[Int] = {
    Try(x / y)
  }

  // Another example
  def divide: Try[Int] = {
    val dividend = Try(Console.readLine("Enter an Int that you'd like to divide:\n").toInt)
    val divisor = Try(Console.readLine("Enter an Int that you'd like to divide by:\n").toInt)
    val problem = dividend.flatMap(x => divisor.map(y => x / y))
    problem match {
      case Success(v) =>
        println("Result of " + dividend.get + "/" + divisor.get + " is: " + v)
        Success(v)
      case Failure(e) =>
        println("You must've divided by zero or entered something that's not an Int. Try again!")
        println("Info from the exception: " + e.getMessage)
        divide
    }
  }
}

/*
 * A partial function works only on a "subset" of the input (ie has to be positive, has to Some)
 * 
 * Some Scala functions, like collect and flatmap, requires partial function
 */
case class showPartialFunction() {
  val divide = new PartialFunction[Int, Int] {
    def apply(x: Int) = 42 / x

    //apply is required function
    def isDefinedAt(x: Int) = x != 0 //isDefinedAt is a required function
  }
  divide.isDefinedAt(1) //returns True
  if (divide.isDefinedAt(1)) divide(1) //divide(1) calls apply, returns AnyVal=2
  divide.isDefinedAt(0)
  // returns False

  // Another implementation using case statements
  val divide2: PartialFunction[Int, Int] = {
    case d: Int if d != 0 => 42 / d
  }
  divide2.isDefinedAt(0) //false

  //http://alvinalexander.com/scala/how-to-define-use-partial-functions-in-scala-syntax-examples
  List(0, 1, 2) collect {
    divide2
  } // returns List(42,21)
}

/**
  * Map : key value collection
  *
  * collection.map(fn) : operator that applies the fn to every element in collection
  *
  * flatMap : operator
  *
  * http://www.brunton-spall.co.uk/post/2011/12/02/map-map-and-flatmap-in-scala/
  */
case class showMapFlatMap() {
  /*
   * Flatmap is useful when
   * 	- function f returns a list
   *
   */
  val a = List(1, 2, 3)
  val f: Int => List[Int] = {
    x => List(x - 1, x, x + 1)
  }
  val u = a.map(i => f(i))
  // returns List[List[Int]]
  val v = a.flatMap(i => f(i)) // returns List[Int]
  // Example of removing bad values None
  l.map(x => toInt(x)).flatten // method 1
  l.flatMap(toInt) // method 2
  l.map(toInt).collect { case Some(i) => i }
  //method 3
  var m = Map("a" -> 1, "b" -> 2)
  var l = List("1", "2", "Bad")
  var x = l.map(x => toInt(x)) // Some(1), Some(2), None

  def toInt(s: String): Option[Int] = {
    Try {
      s.trim.toInt
    } match {
      case Success(s) => Option(s)
      case Failure(f) => None
    }
  }

  // ??? But why/how does flatMap remove None?  That's the power of nomads..
  Option(1)
}

case class Monad() {

  val getChild = (user: User) => user.child
  // function that takes a user input, and returns the user's child
  // Option 1
  val result = UserService.loadUser("mike")
    .flatMap(user => user.child) // using lambda function
    .flatMap(user => user.child)
  // Option 2: for list comprehension: wrapper for flatmap, filter
  val result2 = for {
    user <- UserService.loadUser("mike")
    usersChild <- user.child
    usersGrandChild <- usersChild.child
  } yield usersGrandChild

  /*https://medium.com/@sinisalouc/demystifying-the-monad-in-scala-cc716bb6f534#.mzv3k3t41
   *
   * Monad
   * 	- Monad required functions
   * 		+ unit[A] : is a wrapper of type A. It’s sort of a monad constructor. Ex: Option
   * 		+ implements flatmap
   *
   * 			trait M[A] {	// Monad Interface
   * 				def flatMap[B](f: A => M[B]): M[B]
   * 			}
   *
   * 			def unit[A](x: A): M[A] // takes x and create a Monad instance of type A. Ex: Option
   *
   * 	- Consequence
   * 			Let x be a value of basic type, ie Int
   * 			Let M be a monad instance, ie List
   * 			Let unit be Option?
   * 			Let f and g of type Int → M[Int]
   *
   * 			- Rule 1: Left Identity
   * 					unit(x).flatMap(f) == f(x)
   * 			- Rule 2: Right Identity
   * 					m.flatMap(unit) == m
   * 			- Rule 3: Associativity law
   * 					m.flatMap(f).flatMap(g) == m.flatMap(x => f(x).flatMap(g))
   *
   * 	- In practice, this means we can chain operations together, and it will not matter
   * 	- Examples of Monads, Future, List
   *
   */
  trait User {
    val child: Option[User]
  }

  // Code flow
  //  String → Option[User] // load from db
  //  User → Option[User] // get child  
  //  User → Option[User] // get child’s child

  case class UserImpl2() extends User {
  }

  object UserService {
    def loadUser(name: String): Some[User] = {
      Some(new UserImpl)
    }
  }

}

/**
  * Construct takes a collection, and creates a new collection of the same type
  *
  * A new collection of the same type as the input collection is created
  *
  * For each loop iteration, we append a new element to the collection
  *
  *
  * http://alvinalexander.com/scala/scala-for-loop-yield-examples-yield-tutorial
  */
case class showForYieldLoops() {
  var x = for (i <- 1 to 5) yield i

  // Operates on the collection array
  var array1 = List(1, 2, 3, 4)
  var y = for (j <- array1) yield j

  // With guard if e > 2
  for (e <- array1 if e > 2) yield e
  //Array[Int] = Array(3, 4, 5)

  // Doing more inside the collection generation
  var array2 = List("one", "two", "three", "four")
  var result = for {
    number <- array1 if number > 1
    name <- array2 if name.nonEmpty

  } yield number + ":" + name

  /* Example
   def getQueryAsSeq(query: String): Seq[MiniTweet] = {
    val queryResults = getTwitterInstance.search(new Query(query))
    val tweets = queryResults.getTweets  // java.util.List[Status]
    for (status <- tweets) yield ListTweet(status.getUser.toString, status.getText, status.getCreatedAt.toString)
	}
  */
}

case class SortedMapExample() {

  import java.io._

  //val normalizer = new SimpleNormalizer()
  val pw = new PrintWriter(new File("/Users/thchang/Desktop/EnglishMinStemmer.txt"))

  val dataFile: String = "/Users/thchang/Downloads/query_only2.txt"
  val lines = Source.fromFile(dataFile).getLines()
  val dict = lines
    .flatMap({ x => x.split("\\W+") })
    .foldLeft(Map.empty[String, Int])({
      (d, word) => d + (word -> (d.getOrElse(word, 0) + 1)) //d is the accumulator. word comes from flatMap
    })
    .toSeq.sortWith((left, right) => left._2 > right._2) // sort by value in descending order
    .foreach({
    case (key, value) => {
      val isNumber = Try(key.toInt).isSuccess // Remove integer search
      if ((value > 10) && !isNumber) {
        //println(key + "-->" + normalizer.apply(key))
        //pw.write(key + "-->" + normalizer.apply(key)+ "\n")
      }
    }
  })
  pw.close
  println("Done")

}

case class test() {
  def containsNumber(s: String): Boolean = {
    case Nil => false
    case (s, rest) => if (Try(s.toInt).isSuccess) true else containsNumber(rest)
  }
}

case class helper() {

}


case class showFuture() {

  def handleRequest(search: SearchMessage, requestMockMap: Map[RankBy.Strategy, Future[ESResponse]] = Map()) = {

    val requestMap: Map[RankBy.Strategy, Future[ESResponse]] =
      if (requestMockMap.isEmpty) {
        // TODO: Extract rankings from search
        val rankings = List(RankBy.Deal, RankBy.Popularity)

        rankings.map {
          r: RankBy.Strategy => {
            val result = mapStrategyToPayload(search, r).getOrElse("")
            r -> executeESCommand(result)
          }
        } toMap
      } else {
        requestMockMap
      }

    Try {
      val aggregatedResponse: Future[List[ESResponse]] = postSearch(requestMap)

      Await.result(aggregatedResponse, 3000 millis)

      val x: Option[Try[List[ESResponse]]] = aggregatedResponse.value
      val y: Try[List[ESResponse]] = x.get
      val z: List[ESResponse] = y.getOrElse(List())

      createGuidedSearchResponse(z)
    } match {
      case (Success(s), _) => s
      case (Failure(f), _) => {
        println(s"Guided search failed. ${f}")
        new GuidedSearchResponse()
      }
    }
  }

  def postSearch(requestMap: Map[RankBy.Strategy, Future[ESResponse]]) = {
    def multipleSearches(requestMap: Map[RankBy.Strategy, Future[ESResponse]], completed: List[ESResponse], prom: Promise[List[ESResponse]]): Future[List[ESResponse]] = {
      val currFuture = if (requestMap.size == 1) {
        requestMap.head._2
      } else {
        Future.firstCompletedOf(requestMap.values)
      }

      currFuture onComplete {
        case Success(value) if (requestMap.size == 1) =>
          prom.success(value :: completed)
        case Success(value) =>
          multipleSearches(requestMap - value.rankType, value :: completed, prom)
        case Failure(ex) => prom.failure(ex)
      }
      prom.future
    }

    val initiateSearch = multipleSearches(requestMap, List(), Promise[List[ESResponse]]())

    initiateSearch andThen {
      case value: Try[List[ESResponse]] => {
        println(s"GuidedSearch callback completed: ${value.get}")
      }
    }
  }

  // end of postSearch

  /**
    * References:
    * http://srirangan.net/2013-01-controlling-flow-with-scala-futures
    * http://stackoverflow.com/questions/15837561/how-do-i-wait-for-asynchronous-tasks-to-complete-in-scala
    */

  case class ESResponse(title: String = "", price: String = "", leaf_cat_id: String = "", rankType: RankBy.Strategy = RankBy.Relevance)

  case class SearchMessage()

  class GuidedSearchResponse {
    var byRelevance: Option[ESResponse] = None
    var byPopularity: Option[ESResponse] = None
    var byDeal: Option[ESResponse] = None
    var byUsedItems: Option[ESResponse] = None
  }

  object RankBy extends Enumeration {
    type Strategy = Value
    val Deal, Popularity, Relevance, UsedItems = Value
  }

}


case class Experiment() {
  def sortAndPruneFile(inputFile: String, outputFile: String) = {
    val pw = new PrintWriter(new File(outputFile))

    val lines: Array[String] = Source.fromFile(inputFile).getLines().toArray
    lines
      .filterNot { x => containsNumber(x) || x.split("-->")(0).length <= 3 }
      .sortWith { (left, right) => right.toLowerCase > left.toLowerCase }
      .foreach { l =>
        pw.write(l.toLowerCase + "\n")
      }
    pw.close
    println(s"Sorted dictionary has ${lines.size} lines")

  }

  def containsNumber2(str: String): Boolean = {
    def mapToInt(c: Char): Boolean = {
      print(c.toInt)
      Try(c.toInt).isSuccess
    }
    str.map(c => mapToInt(c)).contains(true)
  }

  def evaluate(outFileName: String): Unit = {
    val normalizer = new SimpleNormalizer()
    val pw = new PrintWriter(new File(s"/Users/thchang/Desktop/${outFileName}.txt"))

    val dataFile: String = "/Users/thchang/Downloads/query1M_quotes.txt"
    val lines = Source.fromFile(dataFile).getLines()
    lines
      .flatMap({ x => x.split("\\W+") })
      .foldLeft(Map.empty[String, Int])({
        (d, word) => d + (word -> (d.getOrElse(word, 0) + 1)) //d is the accumulator. word comes from flatMap
      })
      .toSeq.sortWith((left, right) => left._2 > right._2) // sort by value in descending order
      .foreach({
      case (key, value) => {
        val isNumber = Try(key.toInt).isSuccess // Remove integer search
        if ((value >= 0) && !isNumber) {
          //println(key + "-->" + normalizer.apply(key))
          pw.write(key + "-->" + normalizer.apply(key) + "\n")
        }
      }
    })
    pw.close
    println("Done")
  }

  class ReadingFiles {

    def buildDictionary(): Map[String, String] = {
      val stream: InputStream = getClass.getResourceAsStream("/special-words-dict.txt")
      val lines = scala.io.Source.fromInputStream(stream).getLines()

      val dict: Map[String, String] = Map()
      lines
        .map({ x => x.split("-->") })
        .foreach(kv => {
          val key = kv(0)
          val value = kv(1)
          dict += key -> value
        })
      dict
    }

    def evaluate(outFileName: String): Unit = {
      val pw = new PrintWriter(new File(s"/Users/thchang/Desktop/${outFileName}.txt"))

      val dataFile: String = "/Users/thchang/Downloads/query1M_quotes.txt"
      val lines = Source.fromFile(dataFile).getLines()
      lines
        .flatMap({ x => x.split("\\W+") })
        .foldLeft(Map.empty[String, Int])({
          (d, word) => d + (word -> (d.getOrElse(word, 0) + 1)) //d is the accumulator. word comes from flatMap
        })
        .toSeq.sortWith((left, right) => left._2 > right._2) // sort by value in descending order
        .foreach({
        case (key, value) => {
          val isNumber = Try(key.toInt).isSuccess // Remove integer search
          if ((value >= 0) && !isNumber) {
            //pw.write(key + "-->" + normalizer.apply(key))
            pw.write(key + "-->" + key + "\n")
          }
        }
      })
      pw.close
      println("Done")
    }

    def containsNumber(str: String): Boolean = {
      var i: Int = 0;
      while (i < str.length && !Character.isDigit(str.charAt(i))) i = i + 1
      if (i == str.length) false else true
    }

    def containsNumber2(str: String): Boolean = {
      def mapToInt(c: Char): Boolean = {
        print(c.toInt)
        Try(c.toInt).isSuccess
      }
      str.map(c => mapToInt(c)).contains(true)
    }
  }


  class Future {
    /**
      * http://danielwestheide.com/blog/2013/01/16/the-neophytes-guide-to-scala-part-9-promises-and-futures-in-practice.html
      * http://docs.scala-lang.org/overviews/core/futures.html
      * http://stackoverflow.com/questions/16256279/how-to-wait-for-several-futures
      *
      * Futures provide a way to reason about performing many operations in parallel– in an efficient and non-blocking way. A Future is a placeholder object for a value that may not yet exist.
      *
      * Futures are nonblocking, and use callbacks
      *
      * Future and Promises revolve around ExecutionContexts, responsible for executing computations.
      *
      * ExecutionContext, is similar to a Java Executor.  It is free to execute compuatoin in a new thread,
      * from a thread pool, backed by ForkJoinPool
      *
      * ForkJoinPool is not designed for long lasting blocking operations, limiting to 32767 threads.
      *
      * Future is a placeholder.
      * Once assigned (to value or exception) becomes immutable
      *
      * import ExecutionContext.Implicits.global imports the default global execution context.
      *
      *
      */
    val f: Future[List[String]] = Future {
      session.getRecentPosts
    }
    f onComplete {
      case Success(posts) => for (post <- posts) println(post)
      case Failure(t) => println("An error has occured: " + t.getMessage)
    }

    f onFailure {
      case t => println("An error has occured: " + t.getMessage)
    }
    f onSuccess {
      case posts => for (post <- posts) println(post)
    }

    /**
      * Chaining futures ...
      */

    /**
      * With Play
      */

    def index = Action.async {
      val futureInt = scala.concurrent.Future { intensiveComputation() }
      futureInt.map(i => Ok("Got result: " + i))
    }
  }

  /**
    * Thread testing
    *     for (i <- 0 to 20) {
      new Thread(new Runnable {
        def run:Unit = GuidedSearchUtil.getESClient(null, true)
      }).start()
      Thread.sleep(100)
    }

    */
  def showHowTopHandleOneOption = {
    val s : Option[Int] = Some(1)
    val t : Option[Int] = None

    s.foreach {i => println(i)}
    t.foreach {i => println(i)}

    s.map { i => i*2 } getOrElse 100
    t.map { i => i*2 } getOrElse 100

  }
}


class Tom {
  def parseIdFromPubSubMsg(msg: String): Seq[String] = {
    val parts = msg.split(";")
    if (parts.size > 2) {
      parts(2).split(",")
    } else {
      Seq.empty[String]
    }
  }

  private def partitionByPubSubOperations(pubSubMsgs: Seq[String]): Map[BulkOperation, ListBuffer[String]] = {

    def update(operation: BulkOperation, acc: Map[BulkOperation, ListBuffer[String]], ids: Seq[String]): Map[BulkOperation, ListBuffer[String]] = {
      val prevIds: ListBuffer[String] = acc.getOrElse(operation, ListBuffer.empty[String])
      prevIds.appendAll(ids)
      acc + (operation -> prevIds)
    }

    pubSubMsgs.foldLeft(Map.empty[BulkOperation, ListBuffer[String]]) {
      (acc: Map[BulkOperation, ListBuffer[String]], p) =>
        val parts: Seq[String] = p.split(";")
        val ids: Seq[String] = parts(CatalogMsgFormat.ids).split(",")
        val changes: Seq[String] = Try {
          parts(CatalogMsgFormat.changes)
        }.toOption.getOrElse("").split(",")
        if (changes.contains("I")) {
          update(BulkOperation.INSERT_LISTING, acc, ids)
        } else if (changes.contains("D")) {
          update(BulkOperation.DELETE_RECORDS, acc, ids)
        } else {
          logger.warn(s"partitionByPubSubOperations: Do not know how to handle pubSubMsg $p")
          acc
        }
    }
  }
}

class showHowToJoinMultipleMaps {
  def run():Unit = {
    val m1 = Some(Map("k1"-> Seq(1), "k2"->Seq(2)))
    val m2 = Some(Map("k2"-> Seq(22), "k3"->Seq(3)))
    val mCombined = Seq(m1,m2,None).flatten.flatMap(_.toSeq) //List((k1,List(k1)), (k2,List(k2)), (k2,List(22)), (k3,List(3))
    val mGrouped = mCombined.groupBy(_._1) //Map(k2 -> List((k2,List(2)), (k2,List(22))), k1 -> List((k1,List(1))), k3 -> List((k3,List(3))))
    val mCleaned = mGrouped.mapValues(_.map(_._2)) //Map(k2 -> List(List(2), List(22)), k1 -> List(List(1)), k3 -> List(3))
    val mFinal = mCleaned.mapValues(_.flatten) //Map(k2 -> List(2, 22), k1 -> List(1), k3 -> List(3))

  }
}