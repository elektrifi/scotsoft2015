# Stop any existing SparkR context
# 
#sparkR.stop()
#
# This setup_spark file is for RStudio running on a headless AWS EC2 instance
#
# Set up display to use DISPLAY via Xvfb because headless
# Needed to get certain types of plot to show correctly 
# and requires xvfb on the RStudio server
#
# Sys.setenv("DISPLAY"=":7")
# 
# Set this to where Spark is installed
Sys.setenv(SPARK_HOME="/home/spark-user/spark")
Sys.setenv(HADOOP_HOME="/home/spark-user/hadoop")
# This line loads SparkR from the installed directory
.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))
.libPaths(c(file.path(Sys.getenv("HADOOP_HOME"), "lib"), .libPaths()))
# Prepare to read in CSV files
Sys.setenv('SPARKR_SUBMIT_ARGS'='"--packages" "com.databricks:spark-csv_2.10:1.0.3" "sparkr-shell"')
library(SparkR)
#library(magrittr)
#sc <- sparkR.init(master="local")
sc <- sparkR.init(master="spark://YOUR-SPARK-MASTER-IP:7077")
sqlContext <- sparkRSQL.init(sc)