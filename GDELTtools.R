### Load/install the required packages
if (!require("GDELTtools")) {
  install.package("GDELTtools", dep = true)
  library(GDELTtools)
}
if (!require("RColorBrewer")) {
  install.packages("RColorBrewer", dep = true)
  library(RColorBrewer)
}
if (!require("rworldmap")) {
  install.packages("rworldmap", dep = true)
  library("rworldmap")
}
colourPalette <- brewer.pal(7,'Greens')
#
# Economic.humanitarian aid
#
gdelt.aid <- GetGDELT(start.date="2015-07-01", end.date="2015-07-02", local.folder="YOUR_DATA_FOLDER", filter=list(EventCode="07*"), allow.wildcards=TRUE)
normed.gdelt.aid <- NormEventCounts(gdelt.aid, unit.analysis="country.year", var.name="reports.of.aid")
library("rworldmap")
map.data.aid <- joinCountryData2Map(normed.gdelt.aid,
                                joinCode="ISO2",
                                nameJoinColumn="country")  
mapCountryData(map.data.aid, 
               nameColumnToPlot="reports.of.aid.norm",
               mapTitle="Reports of Giving Economic Or Humanitarian Aid",
               oceanCol="lightBlue",
               colourPalette=colourPalette,               
               missingCountryCol="white",
               catMethod="fixedWidth")
#
# Fighting
#
gdelt.fight <- GetGDELT(start.date="2015-07-01", end.date="2015-07-02", local.folder="YOUR_DATA_FOLDER", filter=list(EventCode="19*"), allow.wildcards=TRUE)
normed.gdelt.fight <- NormEventCounts(gdelt.fight, unit.analysis="country.year", var.name="reports.of.fighting")
map.data.fight <- joinCountryData2Map(normed.gdelt.fight, joinCode="ISO2", nameJoinColumn="country")
colourPalette <- brewer.pal(7,'Reds')
mapCountryData(map.data.fight, 
               nameColumnToPlot="reports.of.fighting.norm",
               mapTitle="Reports of Fighting",
               colourPalette = colourPalette,
               oceanCol="lightBlue",
               missingCountryCol="white",
               cat="fixedWidth")