# Projecta

Projecta is a web application based on django that aims to make it easy to 
publish news about your software project, attract sponsors and 
collaborate with your team members.

![screen shot 2017-09-10 at 4 52 01 pm](https://user-images.githubusercontent.com/178003/30250023-6a8082fc-9648-11e7-8d6b-e2dca9e68dfd.png)

There are some options that might need additional configuration:

1. **Django ALLOWED_HOSTS setting**

The Django framework used by GeoNode will run in production mode. For security reasons,
it doesn't allow a hostname that is not described in the ALLOWED_HOSTS setting. 

2. **Django SITEURL setting**

Change this value into something your instance will be referenced from the network. 

3. **Nginx frontend port**

The frontend that will serve the webserver is nginx by proxying uwsgi. You can specify
`nginx.ports` key into your exposed port. For example, `7000:80` will forward 
nginx 80 port into the agent 7000 port. If your agent directly serve the webserver, 
you can use `80:80` for example.

Note that all of these settings can also be changed by upgrading the relevant services 
after you have created the stack.

In `rancher-compose.yml` file, there are some options that might need additional configuration:


# Troubleshooting

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

1. Django second
2. Nginx last

This will ensure that intercontainer references are maintained properly.

## Credits

Tim Sutton, Kartoza Pty Ltd, October 2017
