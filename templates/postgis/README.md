# PostGIS in Rancher

This is an orchestrated set of GIS hosting tools:

* [PostGIS](http://postgis.org) - packaged by Kartoza
* [PG-Backup](https://github.com/kartoza/docker-pg-backup) - packaged by Kartoza
* [Resilio sync (formerly btsync)](http://resilio.com/) - packaged by Kartoza
* [Pg-watch2](https://github.com/cybertec-postgresql/pgwatch2) - packaged by Cybertec
Here is the link graph for the orchestrated stack:

![screen shot 2017-10-24 at 08 17 32](https://user-images.githubusercontent.com/178003/31927317-dbf77f9a-b893-11e7-8c30-999886f8ae8c.png)

Once the appliance is running, you can access the PostGIS instance at
<ip>:5432 (taking the IP from the rancher admin panel).

**Note:**  for non-personal use of Resilio Sync you need to acquire a licence
from http://resilio.com

## Credits

Individual software projects as listed above.

Packaging for Docker and Rancher:

Tim Sutton, October 2017
