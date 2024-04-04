<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>

<div class="container">
  <h1>LanCache Dashboard</h1>
  <p><strong>Collect, Parse and send logs to MySQL database to process it into an awesome dashboard.</strong></p>
  <p>Originally inspired by lancache-elk, but I found it too resource hungry for my needs, couldn't find a light alternative, so I decided to make a simple alternative.</p>
  
  <img src="https://raw.githubusercontent.com/Maavey/lancache-stats/main/lancache_stats.png" alt="Dashboard Screenshot">
  <h2>Requirements:</h2>
  <ul>
    <li>Any LanCache system, I am using Monolithic LanCache.</li>
    <li>mysqlclient on LanCache docker host.</li>
    <li>Modify <code>10_log_format.conf</code> as below.</li>
    <li>LAMP Server or Container + Restore attached db and PHP files.</li>
    <li>Enter Database connection parameters in conn.php and in sendlogs.sh</li>
    <li>Run a CronJob to call Attached sendlogs.sh every 10 minutes or 15 minutes to collect and parse logs into database.</li>
  </ul>

  <h2>Log Format:</h2>
  <p><code>sudo docker exec -it [dockerid] bash</code></p>
  <p><code>nano /etc/nginx/conf.d/10_log_format.conf</code></p>
  <p><code>log_format cachelog '[$time_local] $cacheidentifier $upstream_cache_status $remote_addr $status $body_bytes_sent "$request_uri" "$http_referer" "$http_user_agent" "$host" "$http_range"';</code></p>

  <h2>Working:</h2>
  <p>Auto collection of logs and populating the database.</p>
  <p>All Values are visible into the Dashboard</p>

  <h2>To Do:</h2>
  <ul>
    <li>Integrate with Steam API to collect Game Name from DepotID (currently done manually for Steam).</li>
    <li>Auto Refresh the Dashboard using AJAX or auto page reload.</li>
    <li>Improve Served IPs Section</li>
    <li>Improve Handling log format outside the Container</li>
    <li>Current Method empties log file upon parsing and inserts it into the DB, we'll probably relook into that</li>
    <li>Other ideas and pushes from contributors...</li>
  </ul>
  <h4><a target="_blank" href="https://www.paypal.com/donate/?hosted_button_id=HV9H8JQ6XHGZY">Buy me Coffee?</a></h4>
</div>
</body>
</html>
