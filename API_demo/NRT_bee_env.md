LANDFIRE API Demo
================

### Load Packages

``` r
if (!require(pacman)) install.packages('pacman')
```

    Loading required package: pacman

``` r
library(pacman)

pacman::p_load(purrr, dplyr, tidyr, 
               terra, sf, rgbif, 
               cluster, tmap)

source("../R/landfireAPI.R")
```

## Basic functionality

### Calls the LANDFIRE Product Service (LFPS) API from R

#### Parameter arguments

##### **Product list:**

- `products` Product names as character vector (see:
  <https://lfps.usgs.gov/helpdocs/productstable.html>)

##### **Area of interest**

- `aoi` Area of interest as character or numeric vector defined by
  latitude and longitude in decimal degrees in WGS84, ordered `xmin`,
  `ymin`, `xmax`, `ymax` or a LANDFIRE map zone.

##### **Output Projection**

- `projection` Optional. A numeric value of the WKID for the output
  projection. Default is a localized Albers projection.

##### **Resample Resolution**

- `resolution` Optional. A numeric value between 31-9999 specifying the
  resample resolution in meters. Default is 30m.

##### **Edit Rule**

- `edit_rule` *Optional.* **Not currently functional**

##### **Edit Mask**

- `edit_mask` *Optional.* **Not currently functional**

------------------------------------------------------------------------

#### R only arguments

- `path` Path to .zip directory. Passed to `utils::download.file()`. If
  `NULL`, a temporary directory is created.

- `max_time` Maximum time, in seconds, to wait for job to be completed

- `method` Passed to `utils::download.file()`. See `?download.file`

Returns API call passed from httr::get(). Downloads files to `path`

### Example

Ask for three products for an area Northern California projected to
NAD83(2011) / California Albers and resampled to 90m resolution.

Products:

- 220CC_22 - Forest Canopy Cover 2022
- ELEV2020 - Elevation
- 220VCC - Vegetation Condition Class

``` r
products <-  c("220CC_22", "ELEV2020", "220VCC")
aoi <- c("-123.7835", "41.7534", "-123.6352", "41.8042")
projection <- 6414
resolution <- 90
save_file <- tempfile(fileext = ".zip")

ncal <- landfireAPI(products, aoi, projection, resolution, 
                    path = save_file, max_time = 1000)
```

    Job Messages:
     esriJobMessageTypeInformative: Executing (LandfireProductService): LcpClip 220CC_22;ELEV2020;220VCC &quot;-123.7835 41.7534 -123.6352 41.8042&quot; 6414 # 90 # #
    esriJobMessageTypeInformative: Start Time: Thu Feb 9 13:12:22 2023
    esriJobMessageTypeInformative: Executing (LcpClip): LcpClip 220CC_22;ELEV2020;220VCC &quot;-123.7835 41.7534 -123.6352 41.8042&quot; 6414 # 90 # #
    esriJobMessageTypeInformative: Start Time: Thu Feb 9 13:12:22 2023
    esriJobMessageTypeInformative: Running script LcpClip...
    esriJobMessageTypeInformative: AOI: -123.7835 41.7534 -123.6352 41.8042
    esriJobMessageTypeInformative: Entering ValidateCoordinates()
    esriJobMessageTypeInformative: Entering DetermineRegion()
    esriJobMessageTypeInformative: region: US_
    esriJobMessageTypeInformative: Exiting DetermineRegion()
    esriJobMessageTypeInformative: US_220CC_22
    esriJobMessageTypeInformative: Entering getISinfo()
    esriJobMessageTypeInformative: Exiting getISinfo()
    esriJobMessageTypeInformative: US_ELEV2020
    esriJobMessageTypeInformative: US_220VCC
    esriJobMessageTypeInformative: Start creating geotif
    esriJobMessageTypeInformative: Start resample of geotif
    esriJobMessageTypeInformative: Finish resample of geotif
    esriJobMessageTypeInformative: Finished creating geotif
    esriJobMessageTypeInformative: Start zipping of files
    esriJobMessageTypeInformative: All files zipped successfully.
    esriJobMessageTypeInformative: Job Finished
    esriJobMessageTypeInformative: Completed script LcpClip...
    esriJobMessageTypeInformative: Succeeded at Thu Feb 9 13:12:36 2023 (Elapsed Time: 14.08 seconds)
    esriJobMessageTypeInformative: Succeeded at Thu Feb 9 13:12:36 2023 (Elapsed Time: 14.09 seconds) 
     
    ------------------- 
    Elapsed time:  17.9 s (Max time: 1000 s) 
    -------------------

### Failed Call

``` r
projection <- 00001 #Not a WKID

ncal <- landfireAPI(products, aoi, projection, resolution, 
                    path = save_file, max_time = 1000)
```

    Job Status:  esriJobFailed 
    Job Messages:
     esriJobMessageTypeInformative: Submitted.
    esriJobMessageTypeInformative: Executing...
    esriJobMessageTypeInformative: Executing (LandfireProductService): LcpClip 220CC_22;ELEV2020;220VCC &quot;-123.7835 41.7534 -123.6352 41.8042&quot; 1 # 90 # #
    esriJobMessageTypeInformative: Start Time: Thu Feb 9 13:12:38 2023
    esriJobMessageTypeInformative: Executing (LcpClip): LcpClip 220CC_22;ELEV2020;220VCC &quot;-123.7835 41.7534 -123.6352 41.8042&quot; 1 # 90 # #
    esriJobMessageTypeInformative: Start Time: Thu Feb 9 13:12:38 2023
    esriJobMessageTypeInformative: Running script LcpClip...
    esriJobMessageTypeInformative: AOI: -123.7835 41.7534 -123.6352 41.8042
    esriJobMessageTypeInformative: Entering ValidateCoordinates()
    esriJobMessageTypeInformative: Entering DetermineRegion()
    esriJobMessageTypeInformative: region: US_
    esriJobMessageTypeInformative: Exiting DetermineRegion()
    esriJobMessageTypeInformative: US_220CC_22
    esriJobMessageTypeInformative: Entering getISinfo()
    esriJobMessageTypeInformative: Exiting getISinfo()
    esriJobMessageTypeInformative: US_ELEV2020
    esriJobMessageTypeInformative: US_220VCC
    esriJobMessageTypeError: ERROR: An exception of type RuntimeError occurred. Arguments:
    ('ERROR 999999: Error executing function.\nthe input is not a geographic or projected coordinate system',)
    esriJobMessageTypeInformative: Failed script LcpClip...
    esriJobMessageTypeError: Traceback (most recent call last):
    AttributeError: Object: Error in parsing arguments for SetParameterAsText

    esriJobMessageTypeError: Failed to execute (LcpClip).
    esriJobMessageTypeInformative: Failed at Thu Feb 9 13:12:42 2023 (Elapsed Time: 3.88 seconds)
    esriJobMessageTypeError: Failed to execute (LandfireProductService).
    esriJobMessageTypeInformative: Failed at Thu Feb 9 13:12:42 2023 (Elapsed Time: 3.90 seconds)
    esriJobMessageTypeError: Failed. 
    ------------------- 
    Elapsed time:  2.8 s (Max time: 1000 s) 
    -------------------

### Exceed `max_time`

``` r
projection <- 6414

ncal <- landfireAPI(products, aoi, projection, resolution, 
                    path = save_file, max_time = 10)
```

    Job Status:  esriJobSubmitted 
    Job Messages:
      
    ------------------- 
    Elapsed time:  0.1 s (Max time: 10 s) 
    -------------------Job Status:  esriJobSubmitted 
    Job Messages:
      
    ------------------- 
    Elapsed time:  0.2 s (Max time: 10 s) 
    -------------------

    Error in landfireAPI(products, aoi, projection, resolution, path = save_file, : Job status: Incomplete and max_time reached
    Visit URL to check status and download manually
       https://lfps.usgs.gov/arcgis/rest/services/LandfireProductService/GPServer/LandfireProductService/jobs/jbeac39d187ae4578ae4523c46eb955a0

## Automated processes and reports

### Schedule a script

``` r
library(taskscheduleR)
taskscheduler_create(taskname = "bee_env", rscript = "/path/to/script.R",
                     schedule = "DAILY")
```

### Data

I’ll use use bee observation records here but in theory a similar
concept could be anything (e.g., FIRMS thermal anomalies)

### Obtain recent records

You could set the script to programatically check for new data from the
day before with a script by running:

`date <- format.Date(seq(Sys.Date(), length = 2, by = "-1 day")[2], "%Y-%m-%d")`

Or if using another API this functionality may be baked in:

I assigned a specific date below because I know there are records on
that day.

``` r
key <- name_backbone(name = "Apis mellifera")$usageKey
date <- "2023-01-08"

records <- occ_search(taxonKey = key, eventDate = date, stateProvince = "Arizona",
           hasCoordinate = TRUE, limit = 5)

head(records$data[,2:4])
```

    # A tibble: 5 × 3
      scientificName                decimalLatitude decimalLongitude
      <chr>                                   <dbl>            <dbl>
    1 Apis mellifera Linnaeus, 1758            32.7            -114.
    2 Apis mellifera Linnaeus, 1758            32.7            -114.
    3 Apis mellifera Linnaeus, 1758            32.7            -114.
    4 Apis mellifera Linnaeus, 1758            32.7            -114.
    5 Apis mellifera Linnaeus, 1758            33.6            -112.

### Process records

Simplify the records and project the data to a different CRS (UTM 12N):

``` r
occ <- records$data %>% 
  dplyr::select(species, eventDate, lat = decimalLatitude, 
                lon = decimalLongitude) %>%
  st_as_sf(coords = c("lon", "lat"), crs = st_crs(4326)) %>% 
  st_transform(crs = st_crs(32612))
```

To minimize the amount of data I need to download, I’ll cluster the
occurrence records by distance.

``` r
dist <- st_distance(occ) %>% 
  units::drop_units()

dist
```

                 1            2           3            4        5
    1      0.00000     50.07652    136.9277     27.37750 249274.4
    2     50.07652      0.00000    162.4476     27.40342 249291.7
    3    136.92770    162.44763      0.0000    138.72017 249376.0
    4     27.37750     27.40342    138.7202      0.00000 249293.5
    5 249274.42513 249291.65822 249376.0364 249293.46250      0.0

Four of the five bee records are within 150m of each other while one is
nearly 25km away from all other points.

I’ll use hierarchical clustering to assign the values to groups.

``` r
test <- agnes(dist, stand = FALSE, method = "complete")
clust <- cutree(test, h = 10000) #height would need to be optimized.

clust
```

    [1] 1 1 1 1 2

As expected the points cluster into two distinct groups.

Instead of downloading LANDFIRE data for each point we will create and
area of interest for each cluster. That way we can make two different
api calls to only download data near the locations of interest not the
25km of data in between.

Note: the function `st_bbox` returns values in the correct order but
they must be coerced into a vector to be used in `landfireAPI`.

``` r
occ_split <- cbind(occ, clust) %>% 
  split(clust)

aoi <- purrr::map(occ_split, ~ st_buffer(.x, 100) %>% 
                    st_transform(crs = st_crs(4326)) %>% 
                    st_bbox() %>% 
                    as.vector())

aoi
```

    $`1`
    [1] -114.46363   32.67243 -114.46007   32.67506

    $`2`
    [1] -112.01421   33.57112 -112.01205   33.57292

### LANDFIRE

#### API Download

``` r
# Define parameters
products <-  c("ASP2020", "ELEV2020", "SLPP2020")
projection <- 32612
resolution <- 90

# Create a path for each cluster
save_dirs <- list()
for (i in 1:length(aoi)) {
  save_dirs[[i]] <- tempfile(pattern = paste0(i, "_"), fileext = ".zip")
}

# Call landfire twice
api_call <- purrr::map2(aoi, save_dirs, 
                        ~ landfireAPI(products, aoi = .x, projection, resolution,
                                      path = .y)
                        )
```

    Job Status:  esriJobSucceeded 
    Job Messages:
     esriJobMessageTypeInformative: Executing (LandfireProductService): LcpClip ASP2020;ELEV2020;SLPP2020 &quot;-112.014208319673 33.5711201867004 -112.012053679858 33.5729238131651&quot; 32612 # 90 # #
    esriJobMessageTypeInformative: Start Time: Thu Feb 9 13:12:54 2023
    esriJobMessageTypeInformative: Executing (LcpClip): LcpClip ASP2020;ELEV2020;SLPP2020 &quot;-112.014208319673 33.5711201867004 -112.012053679858 33.5729238131651&quot; 32612 # 90 # #
    esriJobMessageTypeInformative: Start Time: Thu Feb 9 13:12:54 2023
    esriJobMessageTypeInformative: Running script LcpClip...
    esriJobMessageTypeInformative: AOI: -112.014208319673 33.5711201867004 -112.012053679858 33.5729238131651
    esriJobMessageTypeInformative: Entering ValidateCoordinates()
    esriJobMessageTypeInformative: Entering DetermineRegion()
    esriJobMessageTypeInformative: region: US_
    esriJobMessageTypeInformative: Exiting DetermineRegion()
    esriJobMessageTypeInformative: US_ASP2020
    esriJobMessageTypeInformative: Entering getISinfo()
    esriJobMessageTypeInformative: Exiting getISinfo()
    esriJobMessageTypeInformative: US_ELEV2020
    esriJobMessageTypeInformative: US_SLPP2020
    esriJobMessageTypeInformative: Start creating geotif
    esriJobMessageTypeInformative: Start resample of geotif
    esriJobMessageTypeInformative: Finish resample of geotif
    esriJobMessageTypeInformative: Finished creating geotif
    esriJobMessageTypeInformative: Start zipping of files
    esriJobMessageTypeInformative: All files zipped successfully.
    esriJobMessageTypeInformative: Job Finished
    esriJobMessageTypeInformative: Completed script LcpClip...
    esriJobMessageTypeInformative: Succeeded at Thu Feb 9 13:13:03 2023 (Elapsed Time: 9.17 seconds)
    esriJobMessageTypeInformative: Succeeded at Thu Feb 9 13:13:03 2023 (Elapsed Time: 9.19 seconds) 
     
    ------------------- 
    Elapsed time:  5.8 s (Max time: 1000 s) 
    -------------------

``` r
api_call[[1]]
```

    Response [https://lfps.usgs.gov/arcgis/rest/services/LandfireProductService/GPServer/LandfireProductService/jobs/j2c421e02de13497a9757b4d0a284020f]
      Date: 2023-02-09 19:12
      Status: 200
      Content-Type: text/html;charset=utf-8
      Size: 5.26 kB
    <html lang="en">
    <head>
    <title>Job Details: j2c421e02de13497a9757b4d0a284020f (LandfireProductService...
    <link href="/arcgis/rest/static/main.css" rel="stylesheet" type="text/css"/>
    </head>
    <body>
    <table width="100%" class="userTable">
    <tr>
    <td class="titlecell">
    ArcGIS REST Services Directory
    ...

#### Load in LANDFIRE data

``` r
# Unzip the downloaded files
zip_files <- list.files(tempdir(), pattern = ".zip", full.names = TRUE)

ext_dirs <- list()
for (i in 1:length(aoi)) {
  ext_dirs[[i]] <- paste0(tempdir(), "/clust", i)
  filesstrings::create_dir(ext_dirs[[i]])
}
```

    1 directory created. 
    1 directory created. 

``` r
purrr::map2(zip_files, ext_dirs, ~ unzip(.x, exdir = .y))
```

    [[1]]
    [1] "/tmp/Rtmp3KF1nT/clust1/j2c421e02de13497a9757b4d0a284020f.tfw"        
    [2] "/tmp/Rtmp3KF1nT/clust1/j2c421e02de13497a9757b4d0a284020f.tif"        
    [3] "/tmp/Rtmp3KF1nT/clust1/j2c421e02de13497a9757b4d0a284020f.tif.aux.xml"

    [[2]]
    [1] "/tmp/Rtmp3KF1nT/clust2/j22fceb5131c24aae882350472678f383.tfw"        
    [2] "/tmp/Rtmp3KF1nT/clust2/j22fceb5131c24aae882350472678f383.tif"        
    [3] "/tmp/Rtmp3KF1nT/clust2/j22fceb5131c24aae882350472678f383.tif.aux.xml"

``` r
# Load files as rasters
r <- purrr::map(ext_dirs, ~ list.files(.x, pattern = ".tif$",
                                              full.names = TRUE) %>% 
                  terra::rast())

r
```

    [[1]]
    class       : SpatRaster 
    dimensions  : 6, 5, 3  (nrow, ncol, nlyr)
    resolution  : 90, 90  (x, y)
    extent      : 175136.8, 175586.8, 3620184, 3620724  (xmin, xmax, ymin, ymax)
    coord. ref. : WGS_1984_UTM_Zone_12N (EPSG:32612) 
    source      : j2c421e02de13497a9757b4d0a284020f.tif 
    names       : US_ASP2020, US_ELEV2020, US_SLPP2020 
    min values  :         -1,          71,           0 
    max values  :         -1,          77,           4 

    [[2]]
    class       : SpatRaster 
    dimensions  : 4, 4, 3  (nrow, ncol, nlyr)
    resolution  : 90, 90  (x, y)
    extent      : 405776.8, 406136.8, 3715014, 3715374  (xmin, xmax, ymin, ymax)
    coord. ref. : WGS_1984_UTM_Zone_12N (EPSG:32612) 
    source      : j22fceb5131c24aae882350472678f383.tif 
    names       : US_ASP2020, US_ELEV2020, US_SLPP2020 
    min values  :         -1,         446,           1 
    max values  :          6,         450,           5 

#### Extract ENV

Now we could do anything we might normally want to do with LANDFIRE
data, create maps and reports, or as an extremely basic example, extract
the values of certain variables of interest at each location where a bee
was observed.

``` r
occ_vect <- purrr::map(occ_split, ~ terra::vect(.x))
extract <- purrr::map2(occ_vect, r, ~ terra::extract(.y, .x) %>% 
                         cbind(.x, .) %>% 
                         as.data.frame(row.names = FALSE))

df <- dplyr::bind_rows(extract)

df
```

             species           eventDate clust ID US_ASP2020 US_ELEV2020
    1 Apis mellifera 2023-01-08T14:55:06     1  1         -1          75
    2 Apis mellifera 2023-01-08T14:54:29     1  2         -1          75
    3 Apis mellifera 2023-01-08T14:45:31     1  3         -1          73
    4 Apis mellifera 2023-01-08T14:50:51     1  4         -1          75
    5 Apis mellifera 2023-01-08T14:40:49     2  1         -1         448
      US_SLPP2020
    1           3
    2           3
    3           1
    4           3
    5           1

#### Append to csv

Since a similar script could be automated, we can then append the values
to `.csv` file for future processing.

``` r
write.table(df, file = "./bee_env_data.csv", sep = ",", 
            row.names = FALSE, col.names = FALSE,
            append = TRUE)
```
