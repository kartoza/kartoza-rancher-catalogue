# Kartoza.com Rancher Catalogue

This is our catalogue of Rancher recipes - mainly related to
Geographical Information Systems (GIS) provided by the
open source community.

Provided Catalogue Entries:
---------------------------
* GeoServer (http://geoserver.org) - see [README](./templates/geoserver/README.md)
* GeoNode with QGIS Backend (Kartoza extensions to http://geonode.org) - see
  [README](./templates/geonode/README.md)

Planned Catalogue Entries:
---------------------------

* OSM Reporter
* QGIS Server with Btsync replication
* PostGIS with Btsync backups
* MapCampaigner
* Feti?
* Mapproxy
* User map
* QGIS Plugins repo
* Projecta



# Overview

This guide serves as a quick setup guide to spin up a one of our Rancher catalogue packages.

# Prerequisites

This guide assumes that the following requirements are met:

1. Docker is installed on your server. Use Ubuntu 16.04 for the best results
because that is what we are testing on. For quick installation, use the
[convenience scripts](http://rancher.com/docs/rancher/v1.6/en/hosts/#supported-docker-versions)
provided by Rancher (make sure you choose a supported version).


2. The **stable** version of Rancher Server has been set up.

If it's not, refer to [Rancher quickstart guide](http://rancher.com/docs/rancher/v1.6/en/installing-rancher/installing-server/). Here is an example of how to run the latest stable release with a persistent mysql database stored on the file system:

```
mkdir /home/mysql
docker run -d -v /home/mysql:/var/lib/mysql --restart=unless-stopped -p 8080:8080 rancher/server:stable
```

3. One rancher agent has been set up to actually run the instance (it could be on the same host as the rancher server). Take care not to specify the ``--name`` argument when running the agent - this is not supported and will cause problems with your installation later.

# Installing from the catalogue

Once Rancher is installed, use the Admin -> Settings menu to 
add our Rancher catalogue using this URL:

https://github.com/kartoza/kartoza-rancher-catalogue

Once your settings are saved open a Rancher environment and set up a 
stack from the catalogue's 'Kartoza' section - you will see 
GeoServer listed there.

![screen shot 2017-10-23 at 17 04 52](https://user-images.githubusercontent.com/178003/31914192-02bae616-b84a-11e7-8265-abd92bcb2dee.png)

Now you can add items from the Kartoza catalogue to your stack.


# About Kartoza

Visit our web page at http://kartoza.com to find out 
more about the services we offer.

Tim Sutton, October 2017

