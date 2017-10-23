# GeoNode with QGIS Server Backend

A GeoNode with QGIS Server backend stack. Here is the link diagram for GeoNode with QGIS Server

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

## 400 Error

Your siteurl is probably not set. Use the upgrade option on the django container, 
perform the upgrade, then restart the nginx container.

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

