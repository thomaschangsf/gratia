package circuitSimulation

  trait Parameters {
    def InverterDelay = 2

    // Why are these defined as def and not val?
    // (1) How it is used: It is used as a mixin with abstract class. ie object sim extends Circuits with Parameters
    // (2) val is call by name. val x= 5.  Will be executed even if code path does not reference to variable.
    //    In comparision, def is call by reference is only executed when referenced.
    def AndGateDelay = 3

    def OrGateDelay = 5
  }

  abstract class Simulation {

    type Action = () => Unit
    // This is call by reference with no parameter. Example: an inner method that does not take a parameter
    // Call by reference will only be executed only when referenced.
    /**
      * Example:
      * var y = 0
      * def methodA() = {y=y+1} //Side effect
      *
      * var actions: List[Action] = List()
      * actions::methodA ==> List(())
      */

    private var curTime = 0
    private var agenda: List[Event] = List()

    def currentTime: Int = curTime

    // block: => Unit means type of block is a function that takes in no parameter
    def afterDelay(delay: Int)(block: => Unit): Unit = {
      val newEvent = Event(currentTime + delay, () => block) // what is ()?
      agenda = insert(agenda, newEvent)
    }

    def run(): Unit = {
      afterDelay(0) {
        println(s"*** Simulation started, time = $currentTime ***")
      }
      loop()
    }

    private def insert(ag: List[Event], item: Event): List[Event] = ag match {
      // Notice how we are using pattern match to iterate through a collection
      case first :: rest
        if first.time < item.time => first :: insert(rest, item)
      case _ => item :: ag
    }

    private def loop(): Unit = agenda match {
      // With state in the class, the case operations refers to class state variables
      case first :: rest =>
        agenda = rest
        curTime = first.time
        first.action
        loop()
    }

    case class Event(time: Int, action: Action)

  }


  abstract class Gates extends Simulation {

    def InverterDelay: Int

    def AndGateDelay: Int

    def OrGateDelay: Int

    // Note how functions are used to represent objects..
    def inverter(input: Wire, output: Wire): Unit = {
      def invertAction(): Unit = () = {
        val inputSig = input.getSignal
        afterDelay(InverterDelay) {
          output setSignals (!inputSig)
        }
      }
      input.addAction(invertAction)
    }

    def andGate(in1: Wire, in2: Wire, output: Wire): Unit = {
      def andAction(): Unit = {
        val in1Sig = in1.getSignal
        val in2Sig = in2.getSignal

        afterDelay(AndGateDelay) {
          output.setSignals(in1Sig & in2Sig)
        }
      }

      in1 addAction (andAction)
      in2 addAction (andAction)
    }

    def orGate(in1: Wire, in2: Wire, output: Wire): Unit = {
      def orAction(): Unit = {
        afterDelay(OrGateDelay) {
          output.setSignals(in1.getSignal || in2.getSignal)
        }
      }
      in1.addAction(orAction)
      in2.addAction(orAction)
    }

    class Wire {
      private var signal = false
      private var actions: List[Action] = List()

      def getSignal = signal

      def setSignals(s: Boolean) = {
        if (s != signal) {
          signal = s
          //actions foreach ( _())
          for (eachAction: Action <- actions) eachAction()
        }
      }

      def addAction(a: Action): Unit = {
        actions = a :: actions
        a()
      }
    }
  }

  // Circuits
  abstract class Circuits extends Gates {
    def fullAdder(a: Wire, b: Wire, cin: Wire, sum: Wire, cout: Wire): Unit = {
      val s, c1, c2 = new Wire
      halfAdder(a, cin, s, c1)
      halfAdder(b, s, sum, c2)
      orGate(c1, c2, cout)
    }

    def halfAdder(a: Wire, b: Wire, s: Wire, c: Wire) = {
      val d, e = new Wire
      orGate(a, b, d)
      andGate(a, b, c)
      inverter(c, e)
      andGate(d, e, s)
    }

    def probe(name: String, w : Wire) = {
      def probeAction() : Unit = {
        println(s"$name : $currentTime : ${w.getSignal}")
      }

      w.addAction(probeAction)
      // Can I use this concept to log the latencies in GuidedSearch?
      // ESSearchMessage has a wire, where I can add probes to?
    }

  }

  // Test code
  object test {

    // Interesting:  Use trait to define variables in Gates abstract class.
    // Class hierarchy: Circuits --> Gates, which has def variables InverterDelay, GateDelay.  By inheriting the trait parameter, we populate the abstract variables GateDelay
    object sim extends Circuits with Parameters

    val in1, in2, sum, carry = new Wire
    halfAdder(in1, in2, sum, carry)

    probe("sum", sum)
    probe("carry", carry)


  }



