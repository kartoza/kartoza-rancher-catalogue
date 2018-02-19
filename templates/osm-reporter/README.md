# OSM Reporter

A reporting tool for OpenStreetMap written by [Kartoza](http://kartoza.com).
A simple tool for getting stats for an openstreetmap area.  You can also use
this tool to download OSM shapefiles with a nice QGIS canned style for OSM
roads and buildings for the area of your choosing.

See [osm-reporter github page](https://github.com/kartoza/osm-reporter/) for
more details.


# Troubleshooting

**Issue:** No results

**Answer:**

Check if your host has free space - if not consider killing, removing and
restarting this service since the logs can fill up and consume lots of space. 

The system uses overpass for queries - there are limits to how big the 
result can be and how long the query may take.

**Issue:** When deploying via rancher catalogue agent continually restarts, service is down

**Answer:** 

Here is some post-mortem:

When running docker ps -a the server was showing the rancher agent to be continually restarting:

```
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                          PORTS               NAMES
54c45048afc8        rancher/agent       "/run.sh run"       4 minutes ago       Restarting (1) 41 seconds ago                       rancher-agent
```

I tried:
* killing the agent, removing it and rerunning it using the rancher add host agent string - did the same restart thing after it came up
* upgrading to a newer version of the agent - same outcome
* applying all system patches and updates and then restarting docker - same outcome
* system restart - same outcome

There was an error in the logs like this:

```
Found container ID: ec79bdab6b24806d9e42ebd32035ffbe07c8c0bc1784c98de6f7cf6fb6cf11eb
Checking root: /host/run/runc
Checking root: /host/var/run/runc
Checking root: /host/run/docker/execdriver/native
Checking root: /host/var/run/docker/execdriver/native
time="2018-02-08T08:14:47Z" level=fatal msg="Failed to find state.json"
```

I googled that - it seems to be a known issue that was already fixed in agent 1.16.15
other googling did not come up with a definitive reason of why it was doing htat
I eventually:

* went to the hetzner control panel and shut down the server
* then restored the last system snapshot
* then installed all OS updates
* then ran the rancher agent command again

All systems seemed to come up normally after that
