package quickcheck

import common._

import org.scalacheck._
import Arbitrary._
import Gen._
import Prop._

abstract class QuickCheckHeap extends Properties("Heap") with IntHeap {

  //https://gist.github.com/wh5a/7394082
  lazy val genHeap: Gen[H] = for {
    node <- arbitrary[A]
    heap <- frequency((1, Gen.const(empty)), (9, genHeap))
  } yield insert(node, heap)

  lazy val genMap: Gen[Map[Int, Int]] = for {
    k <- arbitrary[Int]
    v <- arbitrary[Int]
    m <- oneOf(const(Map.empty[Int, Int]), genMap)
  } yield m.updated(k, v)


  property("hint1") = forAll { (n1: A, n2: A) =>
    val h = insert(n1, insert(n2, empty)
      findMin (h) == min(n1, n2)
  }

  property("hint2") = forAll { (n: A) =>
    isEmpty(deleteMin(insert(n, empty)))
  }

  property("hint3") = forAll { (h: H) =>
    def isSorted(h: H): Boolean = {
      if (isEmpty(h)) true
      else {
        val m = findMin(h)
        val h2 = deleteMin(h)
        isEmpty(h2) || (m <= findMin(h2) && isSorted(h2))
      }
    }

    isSorted(h)
  }

  property("hint 4") = forAll { (h1: H, h2: H) =>
    findMin(meld(h1, h2)) == min(findMin(h1), findMin(h2))
  }

  property("meld") = forAll { (h1: H, h2: H) =>
    def heapEqual(h1: H, h2:H): Boolean = {
      if (isEmpty(h1) && isEmpty(h2)) true
      else {
        val m1 = findMin(h1)
        val m2 = findMin(h2)
        m1 == m2 && heapEqual(deleteMin(h1), deleteMin(h2))
      }
    }

    heapEqual(meld(h1, h2), meld(deleteMin(h1), insert(findMin(h1), h2)))

  }


  property("min1") = forAll { a: Int =>
    val h = insert(a, empty)
    findMin(h)
  }

  property("gen1") = forAll { (h: H) =>
    val m = if (isEmpty(h)) 0 else findMin(h)
    findMin(insert(m, h)) == m
  }

  implicit lazy val arbHeap: Arbitrary[H] = Arbitrary(genHeap)

}