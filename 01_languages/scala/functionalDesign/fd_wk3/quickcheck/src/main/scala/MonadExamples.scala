
/**
  * https://github.com/sjuvekar/reactive-programming-scala/blob/master/ReactiveCheatSheet.md
  * https://www.stephanboyer.com/post/9/monads-part-1-a-design-pattern
  *
  * Monads and their operations like flatMap help us handle programs with
  * side-effects (like exceptions) elegantly.  Without it, we need alot of code to handle None case,
  * for example None/callback handling hell.
  *
  * Monad is like a design pattern. A monad is a structure that represents
  * computations defined as sequences of steps.
  *
  * Generally, it can be used in scenarios where operations can be COMPOSED
  * and each operation may have side effects(exception, IO, latency, etc).
  * Try, Future and Observable in scala are all based on monad.
  *
  * Option is another widely used monad in Scala.
  *
  * Try is the monad to handle exceptions in a functional way.
  *
  * Future enables programmers to compose asynchronous computation in an elegant way
  * while avoiding the callback hell.
  *
  * The limit of Future is that one future can only encapsulate one asynchronous result.
  * But what if there’s a stream of asynchronous events? Observable does exactly that.
  * With Observale, you can work at a very high level of abstraction
  */
class MonadExamples {


  import scala.util.{Try, Success, Failure}

  /**
    * (1-A) Mondad with Try with For Expression - guarantee exception handling
    *
    */
  class ShowTryWithForExpression() {
    // Notice how the t2 takes in an integer
    var showSuccessPath: Try[Int] = for {
      x: Int <- t1()
      y: Int <- t2(x)
      if y > 0
    } yield y + x // Returns Success(4)

    var showFailurePath: Try[Int] = for {
      x: Int <- t1()
      y: Int <- t3(x)
      if y > 0
    } yield y //Returns Failure(RunTimeException: Blah)

    var showExperiment: Try[Int] = for {
      x: Int <- t1 // t3(0)
      y =  t4(x) //has to be y=, because t4 does not return a try
      z : Int <- t2(y) // can pass in x or y
      if z > 0
    } yield z //Returns Success(102)


    def t1(): Try[Int] = {
      Try(1)
    }

    def t2(p1: Int): Try[Int] = {
      Try(2 + p1)
    }

    def t3(p1: Int): Try[Int] = {
      throw new RuntimeException("Blah")
    }

    def t4(p4: Int): Int = {
      p4
    }
  }

  /**
    * (1-B) Mondad with Try WITHOUT For Expressions - guarantee exception handling
    * For expression allows us to write more elegant code by leverging monad's ability left, right, and associativity rule.
    * This enables us not to deal with so much match Success/Failure.  TODO: GuidedSearch can use some of this.
    */
  class ShowTryWithoutForExpressions() {
    def answerToLife(nb: Int): Try[Int] = {
      if (nb == 42) Success(nb)
      else Failure(new Exception("WRONG"))
    }

    answerToLife(42) match {
      case Success(t) => t // returns 42
      case failure@Failure(e) => failure // returns Failure(java.Lang.Exception: WRONG)
    }
  }


  /**
    * (2) Monad with Option - guarantee valid values
    */
  class ShowOption() {
    // returns Some(4)
    var showSuccesspath: Option[Int] = for {
      x: Int <- o1()
      y: Int <- o2(x)
    } yield x + y

    var showFailurePath1: Option[Person] =
      for {firstName <- maybeFirstName
           surname <- maybeSurname
      } yield Person(firstName, surname) // returns None, because surName is None
    // for loop help us write more elegant code
    // Equivalent to: maybeFirstName.flatMap { firstName => maybeSurname.map { surname => Person(firstName, surname) } }

    var showFailurePath2: Option[TupleInt] =
      for {
        x: Int <- o1()
        y: Int <- o3()
      } yield TupleInt(x, y) // returns None because y is None. Notice that TupleInt takes in Ints, and not OPtion

    def maybeFirstName: Option[String] = {
      Some("Mark")
    }

    def maybeSurname: Option[String] = {
      None
    }

    def o1(): Option[Int] = {
      Some(1)
    }

    //Returns None

    def o2(p1: Int): Option[Int] = {
      Some(2 + p1)
    }

    def o3(): Option[Int] = {
      None
    }

    case class Person(firstName: String, surname: String)

    case class TupleInt(x: Int, y: Int)

  }

  /**
    * (3 - A) Monad with Latency Without For Loop - guarantee that we will process upon completion of synchronous call
    */
  class ShowFutureWithoutForExpression() {

    import scala.concurrent._
    import ExecutionContext.Implicits.global

    // The function to be run asyncronously
    val answerToLife: Future[Int] = Future {
      42
    }

    // These are various callback functions that can be defined
    answerToLife onComplete {
      case Success(result) => result
      case Failure(t) => println("An error has occured: " + t.getMessage)
    }

    answerToLife onSuccess {
      case result => result
    }

    answerToLife onFailure {
      case t => println("An error has occured: " + t.getMessage)
    }

    answerToLife // only works if the future is completed
  }

  /**
    * (3 - B) Monad with Latnecy with For Loop
    */
  class ShowFutureWithForExpression() {

    import scala.concurrent._
    import ExecutionContext.Implicits.global

    // The function to be run asyncronously
    val answerToLife: Future[Int] = Future {
      42
    }
    val result: Future[Int] = for {
      x: Int <- answerToLife
      y: Int  <- answerToResponsibility(x)

      if y > 0
    } yield y

    def answerToResponsibility(age: Int): Future[Int] = Future {
      100 - age
    }

    result // only works if the future is completed
  }

  /**
    * (4 - Observables)
    *
    * Futures works with one asynchronous result. What if you have a list of asynchronous events? Hence Observables
    */
  class ShowObservables() {

    import rx.lang.scala._

  }

  /**
    * (5 - Actors)
    *
    * Main Ideas
    * - Actors can only communicate with each other by sending messages
    * - Message sending is asynchronous
    * - Messages for an actor are processed in sequence(no concurrency)
    *
    */
  class ShowActors() {

  }

}
