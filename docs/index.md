---
title: Shiny and Leaflet
author: Matt DeSaix
date: November 2017
---
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

This is a general introduction to using Shiny and Leaflet to create a sampling map: [PROW sampling map](https://https://mgdesaix.github.io/SitesShiny/)


### Layers

Importing shapefiles can be achieved with the `readOGR()` function from the `rgdal` library

```{r eval = FALSE}
library(rgdal)
sum.shp <- readOGR(dsn = path.expand("./shapefiles/"), layer = "PROW_summer")
```

The two primary components of `readOGR()` are `dsn` (data source name) and `layer`. With `dsn` you specify the absolute or relative path to the directory containing your  You don't need to specify the extension of the shapefile, and sometimes `readOGR` doesn't like certain parts of the path, such as ~, so I always add `path.expand()`.

In the [PROW sampling map](https://https://mgdesaix.github.io/SitesShiny/), there are 3  layers for seasonal distribution that I obtained from [NatureServe](http://www.natureserve.org/conservation-tools/data-maps-tools).  The trend and relative abundance maps were downloaded from the Breeding Bird Survey ([BBS](https://www.pwrc.usgs.gov/bbs/RawData/)) website.  

`spTransform` is used to change projections for spatial data classes with defined projections.  In this instance I am using the [NatureServe](http://www.natureserve.org/conservation-tools/data-maps-tools) shapefiles to define to projection of the ([BBS](https://www.pwrc.usgs.gov/bbs/RawData/)) data. The coordinate reference system is specified by `crs()`, thus `crs(object)` outputs the coordinate system for `object`.  Defining projctions and setting all objects to the same projection is essential for working with spatial data!

```{r, eval=FALSE}
mig.shp <- readOGR(dsn = path.expand("./shapefiles/"), layer = "PROW_migration")
tr <- readOGR(dsn = path.expand("./shapefiles/tr06370/"), layer = "tr06370")
tr.shp <- spTransform( tr, crs(mig.shp))
```













