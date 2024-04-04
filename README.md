<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>lancache-stats</title>
<style>
  body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
  }
  h1 {
    color: #333;
    text-align: center;
  }
  .container {
    max-width: 800px;
    margin: 0 auto;
  }
  p {
    line-height: 1.6;
    color: #666;
  }
  code {
    font-family: Consolas, monospace;
    background-color: #f4f4f4;
    padding: 2px 5px;
    border-radius: 3px;
  }
  ul {
    list-style-type: disc;
    padding-left: 20px;
  }
</style>
</head>
<body>
![Dashboard](https://raw.githubusercontent.com/Maavey/lancache-stats/main/lancache_stats.png)
<div class="container">
  <h1>LanCache Dashboard</h1>
  <p><strong>Collect, Parse and send logs to MySQL database to process it into an awesome dashboard.</strong></p>
  <p>Originally inspired by lancache-elk, but I found it too resource hungry for my needs, couldn't find a light alternative, so I decided to make a simple alternative.</p>
  
  <h2>Requirements:</h2>
  <ul>
    <li>Any LanCache system, I am using Monolithic LanCache.</li>
    <li>mysqlclient on LanCache docker host.</li>
    <li>Modify <code>10_log_format.conf</code> as below.</li>
    <li>LAMP Server or Container + Restore attached db and PHP files.</li>
    <li>Run a CronJob to call Attached <code>sendlogs.sh</code> every 10 minutes or 15 minutes to collect and parse logs into database.</li>
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
    <li>Other ideas and pushes from contributors...</li>
  </ul>
</div>
</body>
</html>
