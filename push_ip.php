<?php
/*
	Corresponding cronjob on client server for subdomain1 will look like this:

	wget -qO- --no-check-certificate --inet4-only https://yourdomain.com/push_ip.php?token=token1-991a212d21b48891bac47e997
	wget -qO- --no-check-certificate --inet6-only https://yourdomain.com/push_ip.php?token=token1-991a212d21b48891bac47e997
*/

if (isset($_GET["token"])) {
	switch ($_GET["token"]) {
			// Change token and subdomain as desired
		case "token1-991a212d21b48891bac47e997":
			saveip("subdomain1");
			break;
		case "token2-62785a13e85fddcf28b520d23":
			saveip("subdomain2");
			// Multiple subdomain on same Remote Server can be added via CNAME (.subdomain3.yourdomain.com CNAME subdomain2.yourdomain.com) 
			// or - in this case - as seperate A/AAAA entries via a second saveip() call
			saveip("subdomain3");
			break;
	}
}

function saveip($_subdomain)
{
	// Set desired folder here:
	$FOLDER = "../";

	if (filter_var($_SERVER['REMOTE_ADDR'], FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) {
		$entry = "A";
	} elseif (filter_var($_SERVER['REMOTE_ADDR'], FILTER_VALIDATE_IP, FILTER_FLAG_IPV6)) {
		$entry = "AAAA";
	}

	if (isset($entry)) {
		file_put_contents($FOLDER . $_subdomain . "_" . $entry . ".txt", $_SERVER['REMOTE_ADDR']);
		// Uncomment following line to get response when successfull
		// die($_subdomain . " - " . $entry . " - " . $_SERVER['REMOTE_ADDR']);
	}
}

/* Any other Content to be served to clients without correct token can be added here */
