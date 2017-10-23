# GeoNode with QGIS Server Backend - Rancher Setup Guide

**Contents**

* [Prerequisites](https://github.com/kartoza/docker-geosafe/blob/develop/deployment/production/docs/Rancher.md#prerequisites)
* [Creating a stack](https://github.com/kartoza/docker-geosafe/blob/develop/deployment/production/docs/Rancher.md#creating-a-stack)
* [GeoNode with QGIS Server](https://github.com/kartoza/docker-geosafe/blob/develop/deployment/production/docs/Rancher.md#geonode-with-qgis-server)
* [Troubleshooting](https://github.com/kartoza/docker-geosafe/blob/develop/deployment/production/docs/Rancher.md#troubleshooting)


# Overview

This guide serves as a quick setup guide to spin up a GeoNode_QGIS-server or a GeoNode_QGIS-server + GeoSAFE instance. If you are new to docker and/or rancher, take a look at this video walk through so you understand the process:

[![GeoNode and Rancher Walkthrough](https://img.youtube.com/vi/lJCrbCizsmo/0.jpg)](https://www.youtube.com/watch?v=lJCrbCizsmo)

# Prerequisites

This guide assumes that the following requirements are met:

1. Docker is installed on your server. Use Ubuntu 16.04 for the best results because that is what we are testing on. For quick installation, use the [convenience scripts](http://rancher.com/docs/rancher/v1.6/en/hosts/#supported-docker-versions) provided by Rancher (make sure you choose a supported version).


2. The **stable** version of Rancher Server has been set up.

If it's not, refer to [Rancher quickstart guide](http://rancher.com/docs/rancher/v1.6/en/installing-rancher/installing-server/). Here is an example of how to run the latest stable release with a persistent mysql database stored on the file system:

```
mkdir /home/mysql
docker run -d -v /home/mysql:/var/lib/mysql --restart=unless-stopped -p 8080:8080 rancher/server:stable
```

3. One rancher agent has been set up to actually run the instance (it could be
on the same host as the rancher server). Take care not to specify the
``--name`` argument when running the agent - this is not supported and will
cause problems with your installation later.

# Creating a stack

This is the default compose file to quickly set up a new instance.
However, there are some environment variables which are dependent on how you set up 
your instance. You need to change these values depending on your environment. Again see 
the video at the top of this page if you need some background on how a stack is created in rancher.

# GeoNode with QGIS Server

A GeoNode with QGIS Server backend sample stack is stored [here](../docker/compose-files/qgis-server).

Here is the link diagram for GeoNode with QGIS Server

![screen shot 2017-09-10 at 4 52 01 pm](https://user-images.githubusercontent.com/178003/30250023-6a8082fc-9648-11e7-8d6b-e2dca9e68dfd.png)

In `docker-compose.yml` file, there are some options that might need additional configuration:

1. **Volumes**

Volumes were all configured using named volumes. By default, Rancher will create
new containers with mounted volumes. These named volume will be created if they don't exist.
Once created, they will be persisted on the agent. So if you spin up a new service,
but mount the same named-volume, the data will be the same. You can optionally 
change these named-volume into a path location in your agent if you need to. 
Usually this is useful when you have some existing data.

2. **Django ALLOWED_HOSTS setting**

The Django framework used by GeoNode will run in production mode. For security reasons,
it doesn't allow a hostname that is not described in the ALLOWED_HOSTS setting. 
Simply append your hostname into this setting located in `django.environment` key
and `celery.environment` key. Again, see the video at the top of this page for a demonstration of how you upgrade your services to set their settings.

3. **Django SITEURL setting**

Change this value into something your instance will be referenced from the network. 
This settinng is located in `django.environment` key and `celery.environment` key.

4. **Nginx frontend port**

The frontend that will serve the webserver is nginx by proxying uwsgi. You can specify
`nginx.ports` key into your exposed port. For example, `7000:80` will forward 
nginx 80 port into the agent 7000 port. If your agent directly serve the webserver, 
you can use `80:80` for example.

Note that all of these settings can also be changed by upgrading the relevant services 
after you have created the stack.

In `rancher-compose.yml` file, there are some options that might need additional configuration:

5. **Service scaling**

Scalable service in this stack are: `celery` and `qgis-server-backend`. It is scaled
to 4 by default. You can change this into other relevant value. You can also change 
this value after you have created the stack.




# Troubleshooting

## Hung containers

If a service (e.g. qgis-server-backend service) is in a stale condition (stuck on rolling back but didn’t do anything), the easiest way to deal with this is to rename the service first (e.g. qgis-server-backend-old). Next clone the service into the previous name (qgis-server-backend), so we have the same service name, but with fresh containers and the same settings. Then because the qgis-server service is a load balancer to qgis-server-backend, I restart that service too. To make sure it picks up the new container instance’s internal ip.

## Gateway errors

If you try opening the web page and it says ``Gateway error``, there might be two reasons for this:

1. The django service container is dead, 
2. It doesn’t connect to nginx container (because nginx forward request to django container). 

Check the log for **django** service. If it is running it’s maybe not dead so just restart the **nginx** service to make sure it picks up the django service instance. Generally if you restart django, then you need to restart nginx, because it needs the new internal ip of django (see sequencing upgrade section below as this is the same reasone why upgrades need to happen in sequence).

## Sequencing upgrades

When upgrading / restarting services, you should take care to do things in the proper order:

1. Celery workers first
2. Django second
3. Nginx last

This will ensure that intercontainer references are maintained properly.

