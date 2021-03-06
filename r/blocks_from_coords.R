#' Find Census Blocks from Lat/Lng Coordinates
#'
#' This function allows you to geocode a dataset of coordinates into census blocks and isolates a GISJOIN variable that enables simple
#' and easy merging with Census and American Community Survey data
#' 
#' @param filename the path to a file which contains latitude ("lat"), longitude ("lng"), and state ("state"), with those names 
#' @param year the census year that shapefiles will be drawn from for tracts (2000, 2010, 2015); defaults to 2016
#' 
#' @keywords census blocks
#' @export
#' @examples 
#' tracts_from_coords(filename = "your_filename.csv", year = 2010)
#' 
#' @details 
#' Warning: Census block shapefiles are massive and require a dependable and strong internet connection. The block files of some larger states can exceed 0.5GBs
#' 



blocks_from_coords <- function(filename, year){
  
  
  ## importing data file that contains the variables lat, lon, and state
  holder_table <- rio::import(filename)
  holder_table$lat <- as.numeric(holder_table$lat)
  holder_table$lng <- as.numeric(holder_table$lng)
  holder_table <- base::subset(holder_table, !is.na(holder_table$lat))
  holder_table$id <- base::seq.int(nrow(holder_table))
  
  ## selecting these specialized 
  coords <- dplyr::select(holder_table, c("lat", "lng", "state", "id"))
  colnames(coords) <- c("latitude", "longitude", "state", "id")
  
  
  
  
  ## isolating state data to isolate
  ########################################################
  coords_states <- base::table(coords$state)
  coords_states <- as.data.frame(coords_states)
  colnames(coords_states) <- c("state", "frequency")
  ########################################################
  
  
  ## running loop on all state-level shapefiles to extract census data
  ########################################################
  tracts_output <- data.frame()
  
  for (i in 1:NROW(coords_states)){
    
    ## isolating state name and fips to be used in subset
    use_state <- paste(coords_states[i, "state"])
    
    ## subsetting nssats data into usable data by state
    use <- base::subset(coords, state == use_state)
    use <- base::subset(use, !is.na(use$lat))
    
    
    ## importing shapefile for given state and transforming into SP4 data
    if(missing(year)){
      block <- tigris::blocks(use_state)
    } else {
      block <- tigris::blocks(use_state, year = year)
    }
    block <- sp::spTransform(x=block, CRSobj= sp::CRS("+proj=longlat +datum=WGS84"))
    names(block@data) <- base::tolower(names(block@data))
    
    ## transforming usable data at state level to SP4 data
    spuse <- sp::SpatialPointsDataFrame(coords=use[, c("longitude", "latitude")],
                                        data=use[, c("state", "id")],
                                        proj4string= sp::CRS("+proj=longlat +datum=WGS84"))
    
    ## finding census tract intersction with sp::over to produce census data from lat/lon
    ## affixing this data to the "use" SP4 file
    spuse_tract <- sp::over(x = spuse, y = block)
    spuse@data <- base::data.frame(spuse@data, spuse_tract)
    
    ## isolating the data for specified fips FROM SP4 data object
    holder_data <- base::as.data.frame(spuse@data)
    
    ## merging specified data to overall NSSATS file
    tracts_output <- base::rbind(tracts_output, holder_data)
  }
  
  rm(holder_table, holder_data, spuse_tract, spuse, block, use_state)
  
  ########################################################
  
  output <- dplyr::left_join(holder_table, tracts_output, by = "id")
  
  base::return(output)
}



