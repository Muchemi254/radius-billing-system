<?php

if (php_sapi_name() === 'cli') {
    // When running from the command line, $_SERVER variables are not available.
    // Set a default APP_URL. You may need to change "http://localhost" to the
    // actual public URL of your application.
    define("APP_URL", "http://localhost");
} else {
    $protocol = (!empty($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] !== "off" || $_SERVER["SERVER_PORT"] == 443) ? "https://" : "http://";
    $host = $_SERVER["HTTP_HOST"];
    $baseDir = rtrim(dirname($_SERVER["SCRIPT_NAME"]), "/\\");
    define("APP_URL", $protocol . $host . $baseDir);
}

// Live, Dev, Demo
$_app_stage = "Live";

// Database PHPNuxBill
$db_host	    = "mysql";
$db_user        = "radius_admin";
$db_pass    	= "ChangeThisPassword123!";
$db_name	    = "phpnuxbill";

// Database Radius
$radius_host	    = "mysql";
$radius_user        = "radius_admin";
$radius_pass    	= "ChangeThisPassword123!";
$radius_name	    = "phpnuxbill";

if($_app_stage!="Live"){
    error_reporting(E_ERROR);
    ini_set("display_errors", 1);
    ini_set("display_startup_errors", 1);
}else{
    error_reporting(E_ERROR);
    ini_set("display_errors", 0);
    ini_set("display_startup_errors", 0);
}

