<?php
	if(isset($_GET["secret"])){
		switch($_GET["secret"]){
      case "token2-991a212d21b48891bac47e997":
        saveip("subdomain1");
       break;
      case "token1-62785a13e85fddcf28b520d23":
        saveip("subdomain2");
      break;
		}
	}

	function saveip($_subdomain){
		file_put_contents ("../protectedfolder/".$_subdomain."_NEWIP.txt", $_SERVER['REMOTE_ADDR']);
	}
?>
