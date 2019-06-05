# QGIS Server in Rancher

Provides: 

* [QGIS Server](http://qgis.org) - packaged by Kartoza
* [Resilio sync (formerly btsync)](http://resilio.com/) - packaged by Kartoza

Here is the link graph for the orchestrated stack:

![screen shot 2017-10-24 at 08 17 32](https://user-images.githubusercontent.com/178003/31927317-dbf77f9a-b893-11e7-8c30-999886f8ae8c.png)

Once the appliance is running, you can access the map services using your OGC 
compatible client (e.g. QGIS Desktop, OpenLayers, Leaflet etc.)

**Note:**  for non-personal use of Resilio Sync you need to acquire a licence
from http://resilio.com

## Service scaling

Scalable service in this stack are: `qgis-server-backend`. It is scaled
to 4 by default. You can change this into other relevant value. You can also change 
this value after you have created the stack.


## Credits

Individual software projects as listed above.

Packaging for Docker and Rancher:

Tim Sutton, October 2017


