#=============
# run the setup_spark.R script first
#=============
#source("~/spark-demo/setup_spark.R")

# Set up alerting via Pushbullet, whcih can alert you via your mobile phone when a job completes
library(rpushbullet)

#
# Load up files, which I'm assuming already reside in a Hadoop cluster in a directory called /data/aotp
#
airports <- read.df(sqlContext, "hdfs://YOUR-HADOOP-NAMENODE-IP:50050/data/aotp/airports.csv", "com.databricks.spark.csv", header="true")
carriers <- read.df(sqlContext, "hdfs://YOUR-HADOOP-NAMENODE-IP:50050/data/aotp/carriers.csv", "com.databricks.spark.csv", header="true")
plane_data <- read.df(sqlContext, "hdfs://YOUR-HADOOP-NAMENODE-IP:50050/data/aotp/plane-data.csv", "com.databricks.spark.csv", header="true")
aotp <- read.df(sqlContext, "hdfs://YOUR-HADOOP-NAMENODE-IP:50050/data/aotp/csv/all_flights.csv", "com.databricks.spark.csv", header="true")
# 
# Show schema info
printSchema(aotp)
printSchema(airports)
printSchema(carriers)
printSchema(plane_data)
# Turn them into temp tables
registerTempTable(airports, "airports")
registerTempTable(carriers,  "carriers")
registerTempTable(plane_data, "plane_data")
registerTempTable(aotp,  "aotp")
#
#simple_query <- sql(sqlContext, "SELECT DayOfWeek, count(DayOfWeek)
#                                FROM aotp
#                                WHERE Year = 2006
#                                GROUP BY DayOfWeek")

#
simple_query <- sql(sqlContext, "SELECT plane_data.tailnum, plane_data.aircraft_type, 
                                        plane_data.model, plane_data.year, 
                                        aotp.Origin, aotp.Dest
                                 FROM plane_data, aotp
                                 WHERE plane_data.tailnum = aotp.TailNum
                                 AND   aotp.Year = 2006
                                 AND   aotp.Month = 10")

#simple_query <- sql(sqlContext, "SELECT distinct(Origin)
#                                FROM aotp
#                    ")
#

#simple_query <- sql(sqlContext, "SELECT *
#                                 FROM carriers
#                     ")

#
start.time <- Sys.time()
showDF(simple_query)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
#
# Alert job completion
message <- paste("Time was ", time.taken, " mins")
pbPost("note", "SQL Job Done", message)

# # Find oldest plane on LAX route in Oct 2006
# simple_query <- sql(sqlContext, "SELECT plane_data.aircraft_type, 
#                                         plane_data.model, MIN(plane_data.year) 
#                     FROM plane_data, aotp
#                     WHERE plane_data.year = aotp.TailNum
#                     AND   aotp.Year = 2006
#                     AND   aotp.Month = 10
#                     AND   (aotp.Dest = 'LAX'
#                            OR aotp.Origin = 'LAX')
#                     GROUP BY plane_data.aircraft_type, plane_data.model, plane_data.year 
#                     ")
#
# start.time <- Sys.time()
# showDF(simple_query)
# end.time <- Sys.time()
# time.taken <- end.time - start.time
# time.taken
#
# Alert job completion
# message <- paste("Time was ", time.taken, " mins")
# pbPost("note", "Old plane job done", message)
#
#
# Make the SparkR dataframe a "local" R one
start.time <- Sys.time()
localDf <- collect(simple_query)
head(localDf)
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
#
# Alert job completion
message <- paste("Time was ", time.taken, " mins")
pbPost("note", "LocalDf job done", message)

#
# Now do everything using SparkR functions rather than SQL (see Revolution Analytics blog, 16th June 2015).
#
start.time <- Sys.time()
# Run a query to print the top 5 most frequent destinations from LAX
lax_flights <- filter(aotp, aotp$Origin == "LAX")

# Group the flights by destination and aggregate by the number of flights
dest_flights <- agg(group_by(lax_flights, lax_flights$Dest), count = n(lax_flights$Dest))

# Now sort by the `count` column and print the first few rows
head(arrange(dest_flights, desc(dest_flights$count)))

end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
#
# Alert job completion
message <- paste("Time was ", time.taken, " mins")
pbPost("note", "LAX sort done", message)

# More elegant approach 
start.time <- Sys.time()
library(magrittr)
dest_flights <- filter(aotp, aotp$Origin == "LAX") %>% group_by(aotp$Dest) %>% summarize(count = n(aotp$Dest))
arrange(dest_flights, desc(dest_flights$count)) %>% head
end.time <- Sys.time()
time.taken <- end.time - start.time
time.taken
#
# Alert job completion
message <- paste("Time was ", time.taken, " mins")
pbPost("note", "Magrittr LAX sort done", message)

#
sparkR.stop()