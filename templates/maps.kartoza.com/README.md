# Docker-Osm in Rancher

This is an orchestrated set of GIS hosting tools:

* [PostGIS](http://postgis.org) - packaged by Kartoza
* [Docker OSM](https://github.com/kartoza/docker-osm.git) - packaged by kartoza
* [PG-Backup](https://github.com/kartoza/docker-pg-backup) - packaged by Kartoza
* [Resilio sync (formerly btsync)](http://resilio.com/) - packaged by Kartoza

Here is the link graph for the orchestrated stack:

![screen shot 2017-10-24 at 08 17 32](https://raw.githubusercontent.com/kartoza/docker-osm/develop/docs/architecture.png)
Once the appliance is running, you can access the PostGIS instance at
<ip>:5432 (taking the IP from the rancher admin panel).

**Note:**  for non-personal use of Resilio Sync you need to acquire a licence
from http://resilio.com

## Credits

Individual software projects as listed above.

Packaging for Docker and Rancher:

Tim Sutton, October 2017
