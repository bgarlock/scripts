$HTTP_SERVER_VARS


$surfer_info[ip]    = $HTTP_SERVER_VARS["REMOTE_ADDR"];
// $surfer_info[real_ip] will only contain something if the surfer used a transparent proxy
$surfer_info[real_ip]   = $HTTP_SERVER_VARS["X_FORWARDED_FOR"];
$surfer_info[port]   = $HTTP_SERVER_VARS["REMOTE_PORT"];
$surfer_info[browser_lang]  = $HTTP_SERVER_VARS["HTTP_ACCEPT_LANGUAGE"];
$surfer_info[user_agent]  = $HTTP_SERVER_VARS["HTTP_USER_AGENT"];
$surfer_info[request_path]  = $HTTP_SERVER_VARS["PATH_INFO"];
$surfer_info[request_query]  = $HTTP_SERVER_VARS["QUERY_STRING"];
$surfer_info[request_method] = $HTTP_SERVER_VARS["REQUEST_METHOD"];
$surfer_info[http_referrer]  = $HTTP_SERVER_VARS["HTTP_REFERER"];



It is just a row of variables, - it is up to you to decide how they are useful to your script and how to integrate them.
But if you want to see something happening any way, add
print_r($surfer_info);
to the bottom of the script (but before the closing ?>). Doing so will cause the script to show you what information the variables picked up.

