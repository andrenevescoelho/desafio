<?php

$token = ($_POST['token']);

  if($token == "desafio"){
		
		header('Content-Type: image/gif');
		readfile('images/nyan.gif');


  }else{
    echo"Token Incorreto";
	

  }
?>