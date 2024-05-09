# LanCache Dashboard

**Collect, Parse and send logs to MySQL database to process it into an awesome dashboard.**

Originally inspired by lancache-elk, but I found it too resource hungry for my needs, couldn't find a light alternative, so I decided to make a simple alternative.
  
![Dashboard Screenshot](https://raw.githubusercontent.com/Maavey/lancache-stats/main/lancache_stats.png)

## Requirements

- Any LanCache system, but this has only been tested on [Monolithic](https://lancache.net/docs/containers/monolithic/)
- mysqlclient on the LanCache docker host.
    - Required for the *sendlogs.sh* script to push its data to a mysql database
    - For example: `apt-get install default-mysql-client`
- A mysql server
- A LAMP server or container, probably hosted on another system to make use of port 80/443.

## Setup

1. Execute *lancache_db.sql* on the mysql database.

1. Put *sendlogs.sh* on the LanCache docker host and edit the parameters to fit your setup.

1. Edit the log format of the lancache-data container so it is easier to parse
    1. `sudo docker exec -it [dockerid] bash`
    1. If nano is not available yet, install it: `apt-get install nano`
    1. `nano /etc/nginx/conf.d/10_log_format.conf`
    1. Edit *log_format cachelog* to `log_format cachelog '[$time_local] $cacheidentifier $upstream_cache_status $remote_addr $status $body_bytes_sent "$request_uri" "$http_referer" "$http_user_agent" "$host" "$http_range"';` <!---The original format is '[$cacheidentifier] $remote_addr / $http_x_forwarded_for - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$upstream_cache_status" "$host" "$http_range"')-->    
    1. Exit and save (CTRL + X), Y.
    1. This edit is automatically picked up, but not persisted to a volume and will be lost when the container is recreated.

1. Create a CronJob to call *sendlogs.sh* at your desired interval. We recommend a 1 minute interval.
    1. Make sure the script is executable `chmod +x ./sendlogs.sh`
    1. With the user that is able to access the *sendlogs.sh* and LanCache logs: `crontab -e`
    1. Add job entry, every minute is the fastest we can go: `* * * * * /path/to/sendlogs.sh`
    1. Save and exit

1. On the LAMP server, copy *dashboard.php* and *conn.php.new* to the desired web folder.

1. Edit *conn.php.new* with the database information and store or rename it as *conn.php*

## Supported functionality

- Auto collection of logs and populating the database. LanCache does not seem to limit the size of the logfile, so processing it only once a minute does not seem to miss entries.
- Everything in the screenshot is functional, **but there is a lot of room for improvement. Feel free to contribute or modify it to suit your needs.**

## To Do

- Integrate with Steam API to collect Game Name from DepotID (currently done manually for Steam).
- Auto Refresh the Dashboard using AJAX or auto page reload.
- Select a time range to display data for.
- Parse the timestamp and combine (historical) data strictly per minute.
- Improve Served IPs Section.
- Improve Handling log format outside the Container.
- Current Method empties log file upon parsing and inserts it into the DB, we will probably relook into that.
    - For example, streaming with *tail -f*, but should only offload at certain intervals.
    - Log rotation support
- Other ideas and pushes from contributors...

### [Buy me a Coffee?](https://www.paypal.com/donate/?hosted_button_id=HV9H8JQ6XHGZY)