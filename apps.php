<?php
//This file will be used to insert non identified depotid into steamapps table in order to identify them later, with community assistance or sometime when free will try to parse the appid or game name from steam.
//until then we'll either call it manually or prepare a page to enter game name manually...
require_once 'conn.php';

$app_query = "SELECT DISTINCT App FROM access_logs";
$app_result = mysqli_query($conn, $app_query);

while ($row = mysqli_fetch_assoc($app_result)) {
    $app = $row['App'];

    $check_query = "SELECT * FROM steamapps WHERE AppID = '$app'";
    $check_result = mysqli_query($conn, $check_query);

    if (mysqli_num_rows($check_result) == 0) {
        $insert_query = "INSERT INTO steamapps (AppID, AppName) VALUES ('$app', '')";
        if (mysqli_query($conn, $insert_query)) {
            echo "New record for '$app' inserted successfully.<br>";
        } else {
            echo "Error inserting record for '$app': " . mysqli_error($conn) . "<br>";
        }
    } else {

        echo "Record for '$app' already exists in the table.<br>";
    }
}

mysqli_close($conn);
?>