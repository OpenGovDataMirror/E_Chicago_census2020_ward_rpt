

##------------------------------------------------------------------------------
## Initialize
##------------------------------------------------------------------------------

library(data.table)
library(civis)
library(openxlsx)

## set civis key 
Sys.setenv(CIVIS_API_KEY=yaml::read_yaml("config/civis_api_key.yaml")$key)

## SET SHAREPOINT FILE PATH
sharepoint <- gsub("OneDrive - ","",Sys.getenv("OneDrive"))
sharepoint_census <- file.path(sharepoint, "Census 2020 - General")

##------------------------------------------------------------------------------
## Upload police and fire locations
##------------------------------------------------------------------------------
# policefire <- as.data.table(geneorama::clipped())
list.files(sharepoint_census)
infile <- file.path(sharepoint_census, "CIC Locations/police_fire_locations_geocoded_clean.xlsx")
policefire <- openxlsx::read.xlsx(infile, 1)
policefire <- data.table(policefire)
policefire[ , Census.Tract := NULL]
policefire[ , Census.Block := NULL]
policefire[ , Community.Area := NULL]
policefire[ , Community.Area.Name := NULL]
policefire[ , Ward := NULL]
policefire[ , `Lat/Long.Coordinates` := NULL]
str(policefire)
# civis::query_civis("DROP TABLE cic.police_and_fire;")
civis::write_civis(policefire, "cic.police_and_fire")
civis::query_civis("GRANT SELECT on cic.police_and_fire to GROUP CIVIS;")

##------------------------------------------------------------------------------
## Upload park kiosk sites
##------------------------------------------------------------------------------
infile <- file.path(sharepoint_census, "Internet Outreach/Parks - Copy of Kiosk Sites_3.12.20_Site hours.xlsx")
parkkiosks <- openxlsx::read.xlsx(infile, 1)
parkkiosks <- data.table(parkkiosks)
infile <- file.path(sharepoint_census, "Internet Outreach/AgencyKioskSitesCombined.xlsx")
latlonfile <- data.table(openxlsx::read.xlsx(infile, 1))
ii <- match(parkkiosks$Site.Name,latlonfile$Site.Name)
parkkiosks$lat <- latlonfile[ii,lat]
parkkiosks$lon <- latlonfile[ii,long]
# civis::query_civis("DROP TABLE cic.park_kiosks")
civis::write_civis(parkkiosks, "cic.park_kiosks")
civis::query_civis("GRANT SELECT on cic.park_kiosks to GROUP CIVIS;")

##------------------------------------------------------------------------------
## Upload other kiosk sites
##------------------------------------------------------------------------------
infile <- file.path(sharepoint_census, "Internet Outreach/Agency Kiosk Sites.xlsx")
allkiosks <- openxlsx::read.xlsx(infile, 1)
allkiosks <- data.table(allkiosks)

ii <- match(allkiosks$Point.of.Contact,latlonfile$Point.of.Contact)
allkiosks$lat <- latlonfile[ii,lat]
allkiosks$lon <- latlonfile[ii,long]

# civis::query_civis("DROP TABLE cic.kiosks")
civis::write_civis(allkiosks, "cic.kiosks")
civis::query_civis("GRANT SELECT on cic.kiosks to GROUP CIVIS;")

##------------------------------------------------------------------------------
## Multi unit buildings
##------------------------------------------------------------------------------
infile <- file.path(sharepoint_census, "CIC Locations/chicago_sevenplus_units.xlsx")
multis <- openxlsx::read.xlsx(infile, 1)
multis <- data.table(multis)
civis::write_civis(multis, "cic.multi_unit_buildings")
civis::query_civis("GRANT SELECT on cic.multi_unit_buildings to GROUP CIVIS;")

