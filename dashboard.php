<?php
include 'conn.php';

//Prepare Values

//Query to get Disk Values
$query = "SELECT GBUsed, GBFree FROM cache_disk";
$result = mysqli_query($conn, $query);
if ($result) {
    $row = mysqli_fetch_assoc($result);
    $GBUsed = $row['GBUsed'];
    $GBFree = $row['GBFree'];
}

//Query for Upstream
$query = "SELECT Upstream, SUM(Bytes) AS TotalBytes FROM access_logs WHERE LStatus='HIT' GROUP BY Upstream";
$result = mysqli_query($conn, $query);
$labels = array();
$data = array();
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $labelvalues[] = strtoupper($row['Upstream']);
        $datavalues[] = $row['TotalBytes'] / 1024 / 1024 / 1024;
    }
}

// Query to get Cache Ratio
$query = "SELECT LStatus, SUM(Bytes) AS TotalBytes FROM access_logs GROUP BY LStatus";
$result = mysqli_query($conn, $query);
if ($result) {
    $data = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $data[$row['LStatus']] = $row['TotalBytes'];
    }
    $totalHits = $data['HIT'] / 1024 / 1024 / 1024;
    $totalMiss = $data['MISS'] / 1024 / 1024 / 1024;
}
//Query to get Disk Values
$query = "SELECT sum(Bytes) as Total FROM access_logs WHERE LStatus='HIT'";
$result = mysqli_query($conn, $query);
if ($result) {
    $row = mysqli_fetch_assoc($result);
    $GBServed = number_format($row['Total'] / 1024 / 1024 / 1024, 2);
}

//Query for Games
$query = "SELECT GameName, TotalBytes
FROM (
    SELECT 
        CASE 
            WHEN steamapps.AppName IS NOT NULL AND steamapps.AppName != '' THEN steamapps.AppName 
            ELSE access_logs.App 
        END AS GameName,
        SUM(Bytes) AS TotalBytes
    FROM 
        access_logs
    INNER JOIN 
        steamapps ON access_logs.App = steamapps.AppID
    WHERE 
        Upstream = 'steam'
        AND LStatus = 'HIT'
    GROUP BY 
        GameName

    UNION

    SELECT App, SUM(Bytes) AS TotalBytes
    FROM access_logs
    WHERE Upstream='epicgames'
    AND LStatus='HIT'
    GROUP BY App

    UNION

    SELECT 'League of Legends' AS App, SUM(Bytes) AS TotalBytes
    FROM access_logs
    WHERE Upstream = 'riot'
    AND LStatus = 'HIT'
    GROUP BY App
) AS CombinedResults
ORDER BY TotalBytes DESC;
";
$result = mysqli_query($conn, $query);
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $labelvalues4[] = $row['GameName'];
        $datavalues4[] = $row['TotalBytes'] / 1024 / 1024 / 1024;
    }
}

//Query for IPs
$query = "SELECT IP,sum(Bytes) as TotalBytes
FROM access_logs
WHERE LStatus='HIT'
and IP <> '172.17.100.3'
GROUP BY IP
ORDER BY TotalBytes DESC
LIMIT 8;";
$result = mysqli_query($conn, $query);
if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $IPvalue[] = $row['IP'];
        $GBValuep[] = $row['TotalBytes'] / 1024 / 1024 / 1024;
    }
}
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .row {
            height: 50vh;
        }

        .pie-chart {
            width: 250px;
            height: 250px;
            margin: auto;
        }

        .text-container {
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .text-container h3 {
            position: absolute;
            top: 0;
        }
    </style>
</head>

<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col text-center">
                <h3>Cache Disk Status GB</h3>
                <canvas id="pieChart1" class="pie-chart"></canvas>
            </div>
            <div class="col text-center">
                <h3>Served by Upstream GB</h3>
                <canvas id="pieChart2" class="pie-chart"></canvas>
            </div>
            <div class="col text-center">
                <h3>Cache Ratio GB</h3>
                <canvas id="pieChart3" class="pie-chart"></canvas>
            </div>
        </div>

        <div class="row">
            <hr>
            <div class="col text-center">
                <div class="text-container">
                    <h3>Cache Statistics</h3>
                    <h5>Added to Cache</h5>
                    <h4>
                        <?= $GBUsed ?> GB
                    </h4>
                    <hr>
                    <h5>Served from Cache</h5>
                    <h4>
                        <?= $GBServed ?> GB
                    </h4>
                </div>
            </div>
            <div class="col text-center">
                <h3>Served by Game GB</h3>
                <canvas id="pieChart4" class="pie-chart"></canvas>
            </div>
            <div class="col text-center">
                <div class="text-container">
                    <h3>Served IPs</h3>
                    <p>
                        <?php for ($i = 0; $i < count($IPvalue); $i++) {
                            echo $IPvalue[$i] . ' ==> ' . number_format($GBValuep[$i], 2) . ' GB<BR>';
                        } ?>
                    </p>
                </div>
            </div>
        </div>

    </div>
    <script>
        var data1 = {
            labels: ['Used', 'Free'],
            datasets: [{
                data: [<?= $GBUsed ?>, <?= $GBFree ?>],
                backgroundColor: ['#FF9800', '#4CAF50'],
                hoverBackgroundColor: ['#FF9800', '#4CAF50']
            }]
        };
        var labels2 = <?php echo json_encode($labelvalues); ?>;
        var data2 = <?php echo json_encode($datavalues); ?>;
        var chartData2 = {
            labels: labels2,
            datasets: [{
                data: data2
            }]
        };

        var data3 = {
            labels: ['Cached', 'Served'],
            datasets: [{
                data: [<?= $totalMiss ?>, <?= $totalHits ?>],
                backgroundColor: ['#FF9800', '#4CAF50'],
                hoverBackgroundColor: ['#FF9800', '#4CAF50']
            }]
        };

        var labels4 = <?php echo json_encode($labelvalues4); ?>;
        var data4 = <?php echo json_encode($datavalues4); ?>;
        var chartData4 = {
            labels: labels4,
            datasets: [{
                data: data4
            }]
        };
        var options4 = {
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    enabled: true
                }
            }
        };

        var ctx1 = document.getElementById('pieChart1').getContext('2d');
        new Chart(ctx1, {
            type: 'pie',
            data: data1
        });

        var ctx2 = document.getElementById('pieChart2').getContext('2d');
        new Chart(ctx2, {
            type: 'pie',
            data: chartData2
        });
        var ctx3 = document.getElementById('pieChart3').getContext('2d');
        new Chart(ctx3, {
            type: 'pie',
            data: data3
        });
        var ctx4 = document.getElementById('pieChart4').getContext('2d');
        new Chart(ctx4, {
            type: 'pie',
            data: chartData4,
            options: options4
        });
    </script>
</body>

</html>