
#' Call LANDFIRE API from R - Needs work. 
#'
#' @param products Product names as character vector (see: https://lfps.usgs.gov/helpdocs/productstable.html)
#' @param aoi Area of interest as character or numeric vector ordered xmin, ymin, xmax, ymax
#' @param projection Single numeric value of the EPSG code for preferred output projection
#' @param resolution Single numeric value specifying the preferred resolution in meters
#' @param edit_rule Optional **Not currently functional 
#' @param edit_mask Optional **Not currently functional
#' @param path Path to write zip file. Passed to download.file().
#' @param max_time Maximum time, in seconds, to wait for job to be completed
#' @param method Passed to `download.file()` see ?download.file
#'
#' @return 
#' @export
#'
#' @examples
#' \dontrun{
#' products <-  c("ASP2020", "ELEV2020", "SLPP2020")
#' aoi <- c("-123.7835", "41.7534", "-123.6352", "41.8042")
#' projection <- 6414
#' resolution <- 90
#' save_file <- tempfile(fileext = ".zip")
#' test <- landfire_api(products, aoi, projection, resolution, path = save_file, max_time = 540)
#' }

landfire_api <- function(products, aoi, projection, resolution, edit_rule = NULL, edit_mask = NULL, path, max_time = 600, method = "curl") {
  base_url <- httr::parse_url("https://lfps.usgs.gov/arcgis/rest/services/LandfireProductService/GPServer/LandfireProductService/submitJob?")
  base_url$query <- list(Layer_List = paste(products, collapse = ";"),
                         Area_of_Interest = paste(aoi, collapse = " "),
                         Output_Projection = projection,
                         Resample_Resolution = resolution#,
                         #Edit_Rule = edit_rule,
                         #Edit_Mask = edit_mask
  )
  
  url <- httr::build_url(base_url)
  r <- httr::GET(url)
  job_id <- str_extract(r$url, ".{33}$") #NOTE: Assumes that job id length is always 33 characters
  dwl_url <- paste0("https://lfps.usgs.gov/arcgis/rest/directories/arcgisjobs/landfireproductservice_gpserver/", job_id, "/scratch/", job_id, ".zip")
  
  cat("Job Status: Submitted\nVisit url to track status:\n  ", r$url,"\n")
  
  #API always returns a successful status code (200) even if file is not ready. 
  if(httr::status_code(r) == 200 & grepl("Succeeded at", httr::content(r, "text"), fixed = TRUE)) {
    cat("Job Status: Complete.\nDownloading file\n")
    download.file(dwl_url, path, method = method)
    
  } else if(httr::status_code(r) == 200 & !grepl("Succeeded at", httr::content(r, "text"), fixed = TRUE)) {
    cat("Job Status: Executing \n")
    mt <- max_time/15
    
    for (i in 1:mt) {
      r2 <- httr::GET(r$url)
      
      if(grepl("Succeeded at", httr::content(r2, "text"), fixed = TRUE)){
        cat("Job Status: Complete.\nDownloading file\n")
        download.file(dwl_url, path, method = method)
        break
      }
      
      cat("\r  Elapsed time: ", i * 15, "s", "(Max time:", max_time, "s)")
      Sys.sleep(15)
      
      if(i == mt) {
        cat("\n")
        stop("Job status: Incomplete and max_time reached\nIncrease max_time or visit URL to check status and download manually\n   ", r$url)
      }
    }
    
  } else if(httr::status_code(r) != 200) {
    cat("\n")
    stop("Job status: Failed\nCheck URL for details\n  ", r$url)
  }
  
  return(r)
  
}

#TODO Get edit_rule and edit_mask running
#TODO Report job status and errors directly without the user having to visit the URL
#TODO Add input checks and any necessary errors/warnings 
