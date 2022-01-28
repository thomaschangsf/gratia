
package com.ebay.n.search.spark

import com.ebay.n.search.ReadBtV2
import com.ebay.n.search.data.Item2title
import com.ebay.n.search.data.model.SimpleSearchListingProto.SimpleSearchListing
import com.ebay.n.search.index.ItemDedup
import com.ebay.n.search.store.CatalogV2
import com.ebay.n.search.util.{ProtobufSparkUtil, ReadBTDependencies}
import com.typesafe.config.ConfigFactory
import com.holdenkarau.spark.testing.SharedSparkContext
import org.scalatest._
import org.scalatest.mockito.MockitoSugar
import org.mockito.Matchers.any
import org.mockito.Mockito._
import com.typesafe.config.Config

/**
  * Example code to show to how to write Spark Testss
  */
class ReadBtIT extends FunSuite with /*BeforeAndAfterAll*/ SharedSparkContext with Matchers with MockitoSugar{
  /*
  If we want to create our sparkContext ourselves

  private var sparkConf: SparkConf = _
  private var sc : SparkContext = _

  val appID = new Date().toString + math.floor(math.random * 10E4).toLong.toString

  override def beforeAll() {
    sparkConf = new SparkConf().
      setMaster("local[*]").
      setAppName("test").
      set("spark.ui.enabled", "false").
      set("spark.app.id", appID)
    sc = new SparkContext(sparkConf)
    super.beforeAll()
  }

  override def afterAll(): Unit = {
    try {
      LocalSparkContext.stop(sc)
      sc = null
    } finally {
      super.afterAll()
    }
  }
  */

  /*
  test("Show how to mock with MockitoSugar") {
    val appComponents = MockAppComponents()
    import appComponents.services._

    when(tomService.method1).thenReturn()
  }
  */

  /*
  test("Show how to mock RDD functions") {
    val appComponents = MockAppComponents()
    import appComponents.services._

    val emptySimpleListingRddMock = mock[org.apache.spark.rdd.RDD[SimpleSearchListing]]

    // Method0 returns a Unit type
    doNothing().when(catalogV2Mock).method0(any(), any())
    catalogV2Mock.method0(emptySimpleListingRddMock, "myPath")

    when(catalogV2Mock.method1()).thenReturn(0)
    assert(catalogV2Mock.method1() == 0)

    when(catalogV2Mock.method2(any())).thenReturn(0)
    val rddIds = mock[org.apache.spark.rdd.RDD[Long]]
    assert(catalogV2Mock.method2(rddIds) == 0)

    // Sometimes, we want to verify the input to a function call
    // https://www.anchormen.nl/variable-argument-matching-in-scala-with-mockito-unit-testing-spark-drivers/?lang=nl
    // https://github.com/Anchormen/SparkVarArgMatching/blob/master/src/test/scala/nl/anchormen/example/ExampleSparkDriverTest.scala
    // verify(catalogV2Mock).method2(any())
    // mockEq

    val emptyIntRddMock = mock[org.apache.spark.rdd.RDD[Int]]
    when(catalogV2Mock.method3(any(), any())).thenReturn(emptyIntRddMock)
    val result1 : org.apache.spark.rdd.RDD[Int] = catalogV2Mock.method3(rddIds, sc)
    assert(catalogV2Mock.method3(rddIds, sc).equals(emptyIntRddMock))

    when(catalogV2Mock.method4(any(), any())).thenReturn(emptySimpleListingRddMock)
    catalogV2Mock.method4(rddIds, sc).equals(emptySimpleListingRddMock)

  }
  */

  /*
  test("ProtobuffSparkUtil.saveSimpleListing") {
    val appComponents = MockAppComponents()
    import appComponents.services._

    val emptySimpleListingRddMock = mock[org.apache.spark.rdd.RDD[SimpleSearchListing]]

    // Method0 returns a Unit type
    doNothing().when(catalogV2Mock).method0(any(), any())
    catalogV2Mock.method0(emptySimpleListingRddMock, "myPath")

    // Mock method will not be triggered. Evidence that we need dependency injection
    //
    val method = {
      val x = new ProtobufSparkUtilC()
      val rdd = mock[org.apache.spark.rdd.RDD[SimpleSearchListing]]
      x.saveSimpleSearchListingAsFile(rdd, "")
    }
    method

    /*
    doNothing().when(protobufSparkUtilMock).method0(any(), any())
    protobufSparkUtilMock.method0(emptySimpleListingRddMock, "myPath")

    // protobufSparkUtilMock by definition means the function is NOT called.
    protobufSparkUtilMock.saveSimpleSearchListingAsFile(emptySimpleListingRddMock, "")

    // Spying on a real object
    val protoUtilReal : ProtobufSparkUtilC= new (ProtobufSparkUtilC)
    val protoSpy = spy(protoUtilReal)
    doNothing.when(protoSpy).saveSimpleSearchListingAsFile(any(), any())
    protoSpy.saveSimpleSearchListingAsFile(emptySimpleListingRddMock, "")

    */

    // !! Lesson: You can't mock unless you have dependency injection.
    // Example: wWll not use the stub functions, no matter how you mock it.
    //  doNothing.when(protobufSparkUtilMock).saveSimpleListingAsFile(any(), any())
    //  new ProtobufSparkUtilC().saveSimple..
    val result =  1
  }
  */


  test("Method getPathConfig should handle valid path") {
    val testConfig : Config = ConfigFactory.load("application-test.conf")

    val appComponents = MockComponents()
    import appComponents.services._

    val simpleListingRddMock = mock[org.apache.spark.rdd.RDD[SimpleSearchListing]]
    val item2TitleRddMock = mock[org.apache.spark.rdd.RDD[(Long, String)]]

    doNothing().doNothing().doNothing().when(protobufSparkUtil).saveSimpleSearchListingAsFile(any(), any())
    when(protobufSparkUtil.readSimpleSearchListingProtoFile(any(), any())).thenReturn(simpleListingRddMock)
    when(catalogV2.getListingData(any())).thenReturn(simpleListingRddMock)
    when(itemDedup.applyPB(any())).thenReturn(simpleListingRddMock)
    when(item2Title.readItem2TitlePb(any())).thenReturn(item2TitleRddMock)
    doNothing().doNothing().when(item2Title).saveItem2TitlePb(any(), any(), any(), any())

    val args = List("dataDir", "local")
    new ReadBtV2(sc, testConfig, protobufSparkUtil, catalogV2, itemDedup, item2Title).execute(args.toArray)

    assert(true)
  }

}

class ReadBTDependenciesMock extends ReadBTDependencies with MockitoSugar {
  override lazy val protobufSparkUtil = mock[ProtobufSparkUtil]
  override lazy val catalogV2 = mock[CatalogV2]
  override lazy val itemDedup = mock[ItemDedup]
  override lazy val item2Title = mock[Item2title]
}

case class ReadBTComponents(services: ReadBTDependencies) {}

class MockComponents extends ReadBTComponents(new ReadBTDependenciesMock)

object MockComponents extends MockitoSugar {
  def apply() = new MockComponents
}}

case class SimpleSearchListing()

class CatalogV2 {
  def getListingData(ids: RDD[Long]): RDD[SimpleSearchListing] = {
    CatalogV2.getListingData(ids)
  }

  def method0(rdd : RDD[SimpleSearchListing], path : String): Unit = {
    println("Hi Tom")
  }

  def method1(): Int = {
    1
  }

  def method2(ids: RDD[Long]) : Int = {
    2
  }

  def method3(ids: RDD[Long], sc : SparkContext) : RDD[Int] = {
    sc.parallelize(Array(1,2,3))
  }

  def method4(ids: RDD[Long], sc: SparkContext) : RDD[SimpleSearchListing] = {
    //sc.parallelize(Array(new SimpleSearchListing(())))
    sc.emptyRDD[SimpleSearchListing]
  }
}