# tractR
An R package to geocode census geographies from coordinates

Working with geospatial data can be challenging and the learning curve is steep. Needing to learn about shapefiles and geometric fitting can pose a steep learning curve and push users to a paid service to do a simple "geocoding". **This package allows users to parse a data file with latitude/longitudes and state identifiers and outputs the same data frame with census geographies merged by observation.**

The data parsed by the functions of this package need 3 specific things. (1) A latitude variable named "lat", (2) a longitude variable named "lng", and (3) a state variable named "state". The state variable can have the state name as US Postal code or the full name, both will be parsed by the system. Without those three things, this package and the nested functions will **not** work.

This package has two very simple functions to use that will offer the same "service" with two different geographies.

(1) **tracts_from_coords** retrieves census tracts from coordinates parsed

(2) **blocks_from_coords** retrieves census blocks from coordinates parsed

