# GeoServer in Rancher

This is an orchestrated set of GIS hosting tools:

* [Geoserver](http://geoserver.org) - packaged by Kartoza
* [PostGIS](http://postgis.org) - packaged by Kartoza
* [PG-Backup](https://github.com/kartoza/docker-pg-backup) - packaged by Kartoza
* [Resilio sync (formerly btsync)](http://resilio.com/) - packaged by Kartoza

Here is the link graph for the orchestrated stack:

![screen shot 2017-10-24 at 08 17 32](https://user-images.githubusercontent.com/178003/31927317-dbf77f9a-b893-11e7-8c30-999886f8ae8c.png)

Once the appliance is running, you can access the Geoserver instance at
http://<url>:8080/geoserver (taking the URL from the rancher admin panel).

The rancher and docker orchestration work has been developed by Kartoza.

**Note:**  for non-personal use of Resilio Sync you need to acquire a licence
from http://resilio.com

## Credits

Individual software projects as listed above.

Packaging for Rancher:

Tim Sutton, October 2017
