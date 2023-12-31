import org.apache.spark.sql.functions._
import org.apache.spark.sql.DataFrame


def printRecordsPerPartition(df:org.apache.spark.sql.Dataset[Row]):Unit = {
  // import org.apache.spark.sql.functions._
  val results = df.rdd                                   // Convert to an RDD
    .mapPartitions(it => Array(it.size).iterator, true)  // For each partition, count
    .collect()                                           // Return the counts to the driver
 
  println("Per-Partition Counts")
  var i = 0
  for (r <- results) {
    i = i +1
    println("#%s: %,d".format(i,r))
  }
}
 
// ****************************************************************************
// StateFileWithPartition
// ****************************************************************************
import org.apache.spark.sql.functions._
import org.apache.spark.sql.DataFrame
def statFileWithPartitions(input_path_para: String , partsCol: List[String],input_type:String = "parquet" ):DataFrame ={
  
    val filter_file_name = if(input_type == "parquet") "name like 'part-%'" else " 1==1"
  
    val  input_path = input_path_para +(input_path_para.takeRight(1) match{
        case "/" => ""
        case _ => "/"
    })//input_path_para has to have / at the end
 
    val oneMB = 1048576.0 //1MB
    val rawDF =  input_type match {
             case "parquet" => spark.read.parquet(input_path)
             case  "csv"|"tsv" => spark.read.csv(input_path)
    }
    val rawDFStat = rawDF.selectExpr(partsCol:_*).distinct
    val listOfPartitions = rawDFStat.collect().map(r => (partsCol.zip(r.toSeq).toList.map(t => t._1+"="+t._2).mkString("/"),r.toSeq.mkString("_")))
 
    var statArr = listOfPartitions.map{ case(lp,lv) =>{
        val partPath = lp
        val fullPath = input_path + partPath
        println(fullPath)
        val filesDF = dbutils.fs.ls(fullPath).toDF
        val statDF = filesDF
                     .where(filter_file_name)
                     .agg(count("name").as("num_file")
                         ,(max("size")/oneMB).as("max_size")
                         ,(min("size")/oneMB).as("min_size")
                         ,(avg("size")/oneMB).as("avg_size")
                         ,(sum("size")/oneMB).as("part_size")
                      )
        statDF.withColumn("partition",lit(lv))
    }}
     val statDF = statArr.reduce(_.union(_))
     statDF
}
 
def statFileFolder(input_path: String ):DataFrame ={
      val oneMB = 1048576.0 //1MB
 
      val filesDF = dbutils.fs.ls(input_path).toDF
      val statDF = filesDF.where("name like 'part-%'").agg(count("name").as("num_file")
                                                             ,(max("size")/oneMB).as("max_size")
                                                             ,(min("size")/oneMB).as("min_size")
                                                             ,(avg("size")/oneMB).as("avg_size")
                                                             ,(sum("size")/oneMB).as("part_size")
                                                            )
  statDF
}

// ****************************************************************************
// Utility to count the number of files in and size of a directory
// ****************************************************************************
 
def computeFileStats(path:String):(Long,Long) = {
  var bytes = 0L
  var count = 0L
 
  import scala.collection.mutable.ArrayBuffer
  var files=ArrayBuffer(dbutils.fs.ls(path):_ *)
 
  while (files.isEmpty == false) {
    val fileInfo = files.remove(0)
    if (fileInfo.isDir == false) {
      count += 1
      bytes += fileInfo.size
    } else {
      files.append(dbutils.fs.ls(fileInfo.path):_ *)
    }
  }
  (count, bytes)
}
 
// ****************************************************************************
// Utility method to cache a table with a specific name
// ****************************************************************************
 
def cacheAs(df:org.apache.spark.sql.DataFrame, name:String, level:org.apache.spark.storage.StorageLevel):org.apache.spark.sql.DataFrame = {
  try spark.catalog.uncacheTable(name)
  catch { case _: org.apache.spark.sql.AnalysisException => () }
  
  df.createOrReplaceTempView(name)
  spark.catalog.cacheTable(name, level)
  return df
}
 
// ****************************************************************************
// Simplified benchmark of count()
// ****************************************************************************
 
def benchmarkCount(func:() => org.apache.spark.sql.DataFrame):(org.apache.spark.sql.DataFrame, Long, Long) = {
  val start = System.currentTimeMillis            // Start the clock
  val df = func()                                 // Get our lambda
  val total = df.count()                          // Count the records
  val duration = System.currentTimeMillis - start // Stop the clock
  (df, total, duration)
}
 
// ****************************************************************************
// Benchmarking and cache tracking tool
// ****************************************************************************
 
case class JobResults[T](runtime:Long, duration:Long, cacheSize:Long, maxCacheBefore:Long, remCacheBefore:Long, maxCacheAfter:Long, remCacheAfter:Long, result:T) {
  def printTime():Unit = {
    if (runtime < 1000)                 println(f"Runtime:  ${runtime}%,d ms")
    else if (runtime < 60 * 1000)       println(f"Runtime:  ${runtime/1000.0}%,.2f sec")
    else if (runtime < 60 * 60 * 1000)  println(f"Runtime:  ${runtime/1000.0/60.0}%,.2f min")
    else                                println(f"Runtime:  ${runtime/1000.0/60.0/60.0}%,.2f hr")
    
    if (duration < 1000)                println(f"All Jobs: ${duration}%,d ms")
    else if (duration < 60 * 1000)      println(f"All Jobs: ${duration/1000.0}%,.2f sec")
    else if (duration < 60 * 60 * 1000) println(f"All Jobs: ${duration/1000.0/60.0}%,.2f min")
    else                                println(f"Job Dur: ${duration/1000.0/60.0/60.0}%,.2f hr")
  }
  def printCache():Unit = {
    if (Math.abs(cacheSize) < 1024)                    println(f"Cached:   ${cacheSize}%,d bytes")
    else if (Math.abs(cacheSize) < 1024 * 1024)        println(f"Cached:   ${cacheSize/1024.0}%,.3f KB")
    else if (Math.abs(cacheSize) < 1024 * 1024 * 1024) println(f"Cached:   ${cacheSize/1024.0/1024.0}%,.3f MB")
    else                                               println(f"Cached:   ${cacheSize/1024.0/1024.0/1024.0}%,.3f GB")
    
    println(f"Before:   ${remCacheBefore / 1024.0 / 1024.0}%,.3f / ${maxCacheBefore / 1024.0 / 1024.0}%,.3f MB / ${100.0*remCacheBefore/maxCacheBefore}%.2f%%")
    println(f"After:    ${remCacheAfter / 1024.0 / 1024.0}%,.3f / ${maxCacheAfter / 1024.0 / 1024.0}%,.3f MB / ${100.0*remCacheAfter/maxCacheAfter}%.2f%%")
  }
  def print():Unit = {
    printTime()
    printCache()
  }
}
 
case class Node(driver:Boolean, executor:Boolean, address:String, maximum:Long, available:Long) {
  def this(address:String, maximum:Long, available:Long) = this(address.contains("-"), !address.contains("-"), address, maximum, available)
}
 
class Tracker() extends org.apache.spark.scheduler.SparkListener() {
  
  sc.addSparkListener(this)
  
  val jobStarts = scala.collection.mutable.Map[Int,Long]()
  val jobEnds = scala.collection.mutable.Map[Int,Long]()
  
  def track[T](func:() => T):JobResults[T] = {
    jobEnds.clear()
    jobStarts.clear()
 
    val executorsBefore = sc.getExecutorMemoryStatus.map(x => new Node(x._1, x._2._1, x._2._2)).filter(_.executor)
    val maxCacheBefore = executorsBefore.map(_.maximum).sum
    val remCacheBefore = executorsBefore.map(_.available).sum
    
    val start = System.currentTimeMillis()
    val result = func()
    val runtime = System.currentTimeMillis() - start
    
    Thread.sleep(1000) // give it a second to catch up
 
    val executorsAfter = sc.getExecutorMemoryStatus.map(x => new Node(x._1, x._2._1, x._2._2)).filter(_.executor)
    val maxCacheAfter = executorsAfter.map(_.maximum).sum
    val remCacheAfter = executorsAfter.map(_.available).sum
 
    var duration = 0L
    
    for ((jobId, startAt) <- jobStarts) {
      assert(jobEnds.keySet.exists(_ == jobId), s"A conclusion for Job ID $jobId was not found.") 
      duration += jobEnds(jobId) - startAt
    }
    JobResults(runtime, duration, remCacheBefore-remCacheAfter, maxCacheBefore, remCacheBefore, maxCacheAfter, remCacheAfter, result)
  }
  override def onJobStart(jobStart: org.apache.spark.scheduler.SparkListenerJobStart):Unit = jobStarts.put(jobStart.jobId, jobStart.time)
  override def onJobEnd(jobEnd: org.apache.spark.scheduler.SparkListenerJobEnd): Unit = jobEnds.put(jobEnd.jobId, jobEnd.time)
}
 
val tracker = new Tracker()
