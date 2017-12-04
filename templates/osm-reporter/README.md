# OSM Reporter

A reporting tool for OpenStreetMap written by [Kartoza](http://kartoza.com).
A simple tool for getting stats for an openstreetmap area.  You can also use
this tool to download OSM shapefiles with a nice QGIS canned style for OSM
roads and buildings for the area of your choosing.

See [osm-reporter github page](https://github.com/kartoza/osm-reporter/) for
more details.


# Troubleshooting

## No results

Check if your host has free space - if not consider killing, removing and
restarting this service since the logs can fill up and consume lots of space. 

The system uses overpass for queries - there are limits to how big the 
result can be and how long the query may take.

