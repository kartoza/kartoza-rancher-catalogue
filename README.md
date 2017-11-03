# Kartoza.com Rancher Catalogue

This is our catalogue of Rancher recipes - mainly related to
Geographical Information Systems (GIS) provided by the
open source community.

Provided Catalogue Entries:
---------------------------
* GeoServer (http://geoserver.org) - see [README](./templates/geoserver/README.md)
* GeoNode with QGIS Backend (Kartoza extensions to http://geonode.org) - see
  [README](./templates/geonode/README.md)
* GeoSAFE based on GeoNode with QGIS Backend (Kartoza build of InaSAFE for the web) - see
  [README](./templates/geosafe/README.md)  
* PostgreSQL with PostGIS (enterprise geodatabase) - see
  [README](./templates/postgis/README.md)  
  

Planned Catalogue Entries:
---------------------------

* OSM Reporter
* QGIS Server with Btsync replication
* MapCampaigner
* Feti?
* Mapproxy
* User map
* QGIS Plugins repo
* Projecta
* Docker OSM
* [POSM](https://github.com/posm/posm-build)
* Sentry



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

3. Once rancher server has been set up, you need to add a host to the environment has been set up to actually run the instance (the agent could be on the same host as the rancher server). You can do this by ensuring your chosen environment is active and then from the menu do Environment -> Hosts. The process is quite logical and simple and involves pasting a single line of code onto the host that will run the agent. Once the host is set up with a running agent, you should see it join the environment as shown below:


![screen shot 2017-11-02 at 19 03 32](https://user-images.githubusercontent.com/178003/32339631-0bbb10f6-c001-11e7-9218-37074d7feafc.png)



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

