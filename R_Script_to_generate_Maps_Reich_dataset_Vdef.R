#Tutorial: https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html
#Rivers: https://www.rdocumentation.org/packages/rnaturalearth/versions/0.1.0
#Other tutorial: https://evodify.com/rivers-map-in-r/

#Install packages required for first installation
#install.packages("readxl")
#install.packages("cowplot")
#install.packages("googleway")
#install.packages("ggplot2")
#install.packages("ggrepel")
#install.packages("ggspatial")
#install.packages("libwgeom")
#install.packages("sf")
#install.packages("rnaturalearth")
#install.packages("rnaturalearthdata")
#install.packages("rnaturalearthhires",
 #                repos = "http://packages.ropensci.org",
 #                type = "source")
#install.packages("rgeos")

#Loading packages required
library("readxl")
library("ggplot2")
theme_set(theme_bw())
library("sf")
library("rgeos")
library("rnaturalearth")
library("rnaturalearthdata")
library("ggspatial")
library("ggrepel")

###Load own data here###
# dat <- read_excel("Reich_v50.0_1240k_public (1).xlsx", sheet="Sheet2")
dat <- read.csv("filtered.csv", header=TRUE, stringsAsFactors=FALSE)
###Load own data here###

#Load world map
world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

#Create own map with data frame automatically set by coordinates of plotted sites
#Set variables
lats <- as.numeric(dat$Lat.)
longs <- as.numeric(dat$Long.)
site_name <- as.numeric(dat$Site)
lab_pos <- dat$Region
#Set data frame (only works if all coordinates are known)
(df <- data.frame(longitude = c(longs, na.rm=T), latitude = c(lats, na.rm=T)))
df <- head(df,-1)
(sites <- st_as_sf(df, coords = c("longitude", "latitude"), crs = 4326, agr = "constant"))
(df2 <- data.frame(site=c(site_name, na.rm=T), longitude = c(longs, na.rm=T), latitude = c(lats, na.rm=T)))
df2 <- head(df2, -1)
(site_name <- st_as_sf(df2, coords=c("longitude", "latitude"), remove=FALSE, crs = 4326, agr = "constant"))


#Generating the map, including setting up colour of land, here "peachpuff" cf. ggplot2 color options
#options(ggrepel.max.overlaps=Inf)
ggplot(data = world) +
  geom_sf(color = "grey", fill = "antiquewhite") +
  geom_sf(data = sites, size = 1.4, shape = 23, color="black", fill="black") +
# scale_fill_manual(values=c(1='steelblue', 2='darkgoldenrod', 3='chartreuse3', 4='darkgray'))+
  #To add labels: alternative 1. Simple labels on the sites
  #geom_text(data=site_name, aes(x=longs, y=lats, label=site), size=3.0, col="black", fontface="bold", check_overlap = TRUE, position=position_jitter(width=0.8, height=0.8))+
  #To add labels: alternative 2. Labels set to avoid overlap
  #geom_text_repel(data=site_name, aes(x=longs, y=lats, label=site), size=4, nudge_x=-0.2, nudge_y=-0.2, point.padding = NA, col=lab_pos, fontface="bold")+
  #Setting coordinates of the map, here automatically set by latitude, longitude of sites +2
  coord_sf(xlim = c(min(longs, na.rm=T)-1.5, max(longs,na.rm=T)+1.5), ylim = c(min(lats, na.rm=T)-1.5, max(lats, na.rm=T)+1.5), expand = FALSE, datum=NA)+
  #To add scale
  #annotation_scale(location = "bl", width_hint = 0.25)+
  #To add north arrow
  #annotation_north_arrow(location = "bl", which_north = "true",
                        #pad_x = unit(0.05, "in"), pad_y = unit(0.2, "in"),
                        #style = north_arrow_fancy_orienteering)+
  #Defining overall theme, including color of sea, here aliceblue
 # geom_sf(data = rivers50, col = 'blue')+
  theme(panel.grid.major = element_line(color = gray(0.1), linetype = "dashed",
                                        size = 0.1), panel.background = element_rect(fill = "aliceblue"))
