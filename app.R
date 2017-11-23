library(shiny)
library(leaflet)
library(magrittr)
library(rgdal)
library(raster)
library(RColorBrewer)

sites <- read.csv("Sites.csv")
mig.shp <- readOGR(dsn = path.expand("./shapefiles/"), layer = "PROW_migration")
sum.shp <- readOGR(dsn = path.expand("./shapefiles/"), layer = "PROW_summer")
win.shp <- readOGR(dsn = path.expand("./shapefiles/"), layer = "PROW_winter")
tr.color <- brewer.pal(5, "RdBu")
tr <- readOGR(dsn = path.expand("./shapefiles/tr06370/"), layer = "tr06370")
tr.shp <- spTransform( tr, crs(mig.shp))
tr.shp@data$COLOR[tr.shp@data$TRSTAT < -1.5] <- tr.color[1]
tr.shp@data$COLOR[tr.shp@data$TRSTAT >= -1.5 & tr.shp@data$TRSTAT < -0.25 ] <- tr.color[2]
tr.shp@data$COLOR[tr.shp@data$TRSTAT >= -0.25 & tr.shp@data$TRSTAT < 0.25 ] <- tr.color[3]
tr.shp@data$COLOR[tr.shp@data$TRSTAT >= 0.25 & tr.shp@data$TRSTAT < 1.5 ] <- tr.color[4]
tr.shp@data$COLOR[tr.shp@data$TRSTAT >= 1.5] <- tr.color[5]
ra.color <- brewer.pal(5, "Purples")
ra <- readOGR(dsn = path.expand("./shapefiles/ra06370/"), layer = "ra06370")
ra.shp <- spTransform( ra, crs(mig.shp))
ra.shp@data$COLOR[ra.shp@data$RASTAT < 0.05] <- ra.color[1]
ra.shp@data$COLOR[ra.shp@data$RASTAT >= 0.05 & ra.shp@data$RASTAT < 1] <- ra.color[2]
ra.shp@data$COLOR[ra.shp@data$RASTAT >= 1 & ra.shp@data$RASTAT < 3] <- ra.color[3]
ra.shp@data$COLOR[ra.shp@data$RASTAT >= 3 & ra.shp@data$RASTAT < 10] <- ra.color[4]
ra.shp@data$COLOR[ra.shp@data$RASTAT >= 10] <- ra.color[5]

ui <- fluidPage(
  titlePanel("PROW Sampling Sites"),
  mainPanel(
    leafletOutput("mymap", height = 600)
  ),
  sidebarPanel(dataTableOutput("table")
  )
)

server <- function(input,output,session) {
  getColor <- function(sites) {
    sapply(sites$season, function(season) {
      if(season == "Breeding") {
        "orange"
      } else if(season == "Migrating") {
        "green"
      } else {
        "blue"
      } })
  }
  icons <- awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = getColor(sites)
  )
  output$table <- renderDataTable(sites)
  output$mymap <- renderLeaflet({
    leaflet(data = sites) %>% 
      addProviderTiles(providers$Esri.NatGeoWorldMap) %>%
      addAwesomeMarkers(~long, ~lat,
                        icon = icons,
                        label = ~as.character(count),
                        popup = paste("Site:", sites$site, "<br>", "Count:", sites$count, "<br>")) %>%
      addPolygons(data = mig.shp, color = "Green", group = "Range", label = "Migration") %>%
      addPolygons(data = sum.shp, color = "Orange", group = "Range", label = "Breeding") %>%
      addPolygons(data = win.shp, color = "Blue", group = "Range", label = "Nonbreeding") %>%
      addPolygons(data = ra.shp, stroke = FALSE, fillOpacity = 0.7, color = ra.shp$COLOR, group = "Relative Abundance") %>%
      addPolygons(data = tr.shp, stroke = FALSE, fillOpacity = 0.5, color = tr.shp$COLOR, group = "Trends") %>%
      addLegend(position = "bottomright", colors = c("Orange", "Green", "Blue"), labels = c("Breeding", "Migration", "Nonbreeding"), title = "Range") %>%
      addLegend(position = "bottomleft", colors = rev(tr.color), labels = c("Greater than 1.5%", ">= 0.25% to 1.5%", ">= -0.25% to 0.25%", ">= -1.5% to -0.25", "Less than 1.5%"), title = "Trends: Percent Change per Year") %>%
      addLegend(position = "bottomleft", colors = rev(ra.color), labels = c("Greater than 10", ">= 3 to 10", ">= 1 to 3", ">= 0.05 to 1", "Less than 0.05"), title = "Relative Abundance") %>%
      addLayersControl(overlayGroups = c("Range", "Trends", "Relative Abundance") , options = layersControlOptions(collapsed = FALSE))
  })
}

shinyApp(ui, server)