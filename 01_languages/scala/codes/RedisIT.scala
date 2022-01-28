package personalCode

package com.ebay.n.search.store

//import com.redislabs.provider.redis._
import org.scalatest.FunSuite
import org.apache.spark.{SparkConf, SparkContext}

import scala.collection.JavaConversions._
import org.scalameter._

import scala.collection.mutable.Seq
import scala.concurrent.{Await, Future}
import scala.concurrent.duration._
import scala.concurrent.ExecutionContext.Implicits.global
import scala.util.{Failure, Success}

class RedisIT extends FunSuite {
  /*
  test("Sample run") {
    /*val runFromLocal = false
    val ip = if (runFromLocal) "104.198.164.252" else "10.128.0.136"
    val port = 15820

    val conf = new SparkConf().setMaster("local").setAppName("myApp").set("redis.host", ip).set("redis.port", port.toString)

    val sc = new SparkContext(conf)

    //val redisDB = new RedisConfig(new RedisEndpoint(ip, port))

    //val listRdd = sc.parallelize(Array("One", "Two"))
    //sc.toRedisLIST(listRdd, "TestList", 0)
    */

    val bRunInLocalMode = true
    val (ip, port) =
      if (bRunInLocalMode)
        ("127.0.0.1", 6379)
      else
        ("10.128.0.136", 15820)

    val jedis = new Jedis(ip, port)
    //jedis.get("a")
    //jedis.set("a", "b")
    val result = jedis.get("a")
    System.out.println(s"TWC:result=$result")

  }
  */


  val profileRedis = new ProfileRedis

  test("Benchmark hashMap read latency. Expect ~ 33uS") {
    if (TestCase.bRunHashMapReadLatency) {
      profileRedis.hashMapReadLatency(500)
    }
  }

  test("Benchmark hashMap read throughput. ") {
    if (TestCase.bRunHashMapReadThroughput) {

    }
  }

  test("Benchmark hashMap write latency. Expect ~ 28 us") {
    if (TestCase.bRunHashMapWriteLatency) {
      profileRedis.hashMapWriteLatency(500)
    }
  }

  test("Benchmark hashMap write throughput. ") {
    if (TestCase.bRunHashMapWriteThroughput) {
      /* Baseline numbers
          NumThread   NumOpsPerThread   Time
          1           1                 ~0.8ms
          5           1                 ~0.8ms
          10          1                 ~0.8ms
          5           1000               ~4ms

       */
      for {
        numThreads <- List(1) /*, 5)*/
        opsPerThread <- List(10, 100, 1000, 10000, 100000, 1000000)
      } yield {
        val fTime = profileRedis.hashMapWriteThroughput(numThreads, opsPerThread)
        fTime.onComplete {
          case Success(result) => {
            val operationsPerformed: Int = numThreads * opsPerThread
            println(s"ThreadNum=$numThreads TotalOps=$operationsPerformed duration=$result")
          }
          case Failure(f) => {
            val operationsPerformed: Int = numThreads * opsPerThread
            println(s"ThreadNum=$numThreads TotalOps=$operationsPerformed failed")
          }
        }
        Await.ready(fTime, 10 minutes)
      }
    }
  }

}

object TestCase {
  val bRunHashMapWriteLatency = false
  val bRunHashMapWriteThroughput = true
  val bRunHashMapReadLatency = false
  val bRunHashMapReadThroughput = false
}

class ProfileRedis(redisIp: String = "127.0.0.1", redisPort: Int = 6379) {
  val redisClient = getJedisClient
  val latencyUtil = LatencyTestUtil

  def hashMapWriteLatency(numInserts: Int) = {
    val keys = (0 until numInserts).map { i => generateKey(i) }

    val benchMark: Quantity[Double] = {
      val time: Quantity[Double] = {
        latencyUtil.standardConfig measure {
          keys.foreach { k =>
            redisClient.hset(k, "field", "value")
          }
        }
      }
      Quantity(time.value / numInserts, time.units)
    }
    System.out.println(s"HashMap: Write operation took ${benchMark.value} ${benchMark.units} ")

    // Cleanup
    keys.foreach { k => redisClient.del(k) }
  }

  def generateKey(k: Int): String = {
    s"listing:$k"
  }

  def hashMapReadLatency(numReads: Int) = {
    for (i <- 0 until numReads) {
      val oneListing = Map("id" -> s"$i", "title" -> s"$i", "price" -> s"$i")
      redisClient.hmset(generateKey(i), oneListing)
    }

    def benchMark: org.scalameter.Quantity[Double] = {
      val time: org.scalameter.Quantity[Double] =
        latencyUtil.standardConfig measure {
          for (i <- 0 until numReads)
            redisClient.hget(generateKey(i), "id")
        }
      Quantity(time.value / numReads, time.units)
    }

    System.out.println(s"HashMap: Read operation took ${benchMark.value} ${benchMark.units} ")

    // Clean up
    for (i <- 0 until numReads)
      redisClient.del(generateKey((i)))
  }

  def hashMapWriteThroughput(numThread: Int = 5, numOpsPerThread: Int = 10): Future[Quantity[Double]] = {

    def createWorkerThread(threadNum: Int, insert: Boolean): Future[Int] = {
      val keys = (0 until numOpsPerThread).map { i => generateKey(i) }
      Future {
        var numInserts = 0
        val typeOfThread = if (insert) "Worker" else "Cleaner"
        //println(s"$typeOfThread thread $threadNum is executing")
        keys.foreach { k =>
          if (insert)
            numInserts += redisClient.hset(s"Thread[$threadNum]-k", "field", "value").toInt
          else
            redisClient.del(s"Thread[$threadNum]-k")
        }
        numInserts
      }
    }

    val cleanJob: Future[Seq[Unit]] = {
      // Clean the data
      // println("Before createCleanerThread starts")
      val cleanerAsyncs = Seq.empty[Future[Unit]]
      (0 until numThread).foreach { t =>
        cleanerAsyncs :+ createWorkerThread(t, false)
      }
      val fClean: Future[Seq[Unit]] = Future.sequence(cleanerAsyncs)
      fClean
    }

    val measureJob: Future[Quantity[Double]] = {
      Future {
        //latencyUtil.throughputConfig measure {
        //println("TWC: Time measurement starts.")
        val time = measure {
          val wokerAsyncs = Seq.empty[Future[Unit]]

          // Thread will start executiong at this point
          // println("Before createWorkerThread starts")
          (0 until numThread).foreach { i =>
            wokerAsyncs :+ createWorkerThread(i, true)
            Future.sequence(wokerAsyncs)
          }
        }
        //println("TWC: Time measurement ends.")
        time
      }
    }

    val fTime: Future[Quantity[Double]] =
      for {
        fClean <- cleanJob
        fMeasure <- measureJob
      } yield fMeasure

    fTime
  }

  def getJedisClient(): Jedis = {
    new Jedis(redisIp, redisPort)
  }
}

object LatencyTestUtil {
  val standardConfig: MeasureBuilder[Unit, Double] = config(
    Key.exec.minWarmupRuns -> 100,
    Key.exec.maxWarmupRuns -> 200,
    Key.exec.benchRuns -> 5, //500,
    Key.verbose -> false
  ) withMeasurer {
    /*
     Measure.IngoreGC prohibit Garbage collection.
     Other option is Measure.Default, Measurer.MemoryFootprint
     */
    new Measurer.IgnoringGC
  } withWarmer {
    /*
    Ensures the JVM is warmed up, which ensures its maximum performance.
    When JVM starts, the program is interpreted, and part of program is
    compiled into machine code.  JVM may then do some additional dynamic
    optimizations.
    */
    new Warmer.Default
  }

  val throughputConfig: MeasureBuilder[Unit, Double] = config(
    Key.exec.minWarmupRuns -> 1,
    Key.exec.maxWarmupRuns -> 2,
    Key.exec.benchRuns -> 5,
    Key.verbose -> false
  ) withMeasurer {
    /*
     Measure.IngoreGC prohibit Garbage collection.
     Other option is Measure.Default, Measurer.MemoryFootprint
     */
    new Measurer.IgnoringGC
  } withWarmer {
    /*
    Ensures the JVM is warmed up, which ensures its maximum performance.
    When JVM starts, the program is interpreted, and part of program is
    compiled into machine code.  JVM may then do some additional dynamic
    optimizations.
    */
    new Warmer.Default
  }

  def checkLatencyIsLessThan(measured: Quantity[Double], maxLatency: Double): Unit = {
    assert(measured.value < maxLatency)
  }
}
