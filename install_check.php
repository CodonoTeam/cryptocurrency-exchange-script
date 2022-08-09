<?php
/*
 Crypto Exchange Script white label blockchain solution is an open source software that is built for private and public libraries.
 It is not controlled by centralized entities and is therefore free to use forever. Its codebase is open and tested by developers worldwide. 
 A leading Blockchain software development company, has created a secure and flexible white label version of the software for developers to deploy and customize cryptocurrency exchange services.
 The software is based on the blockchain technology and is licensed under the Commercial License.
 support@codono.com https://codono.com
 telegram @ctoninja
*/
header('Content-type:text/html; charset=utf-8');

// PHP version
$phpVersion = PHP_VERSION;
$phpVersionCould = version_compare($phpVersion, '7.3.0', '>=');
const DB_HOST="127.0.0.1";
const DB_USER="root";
const DB_PWD="";
const DB_NAME="codono";
const PHP_PATH="php";
$mysqli = @new mysqli(DB_HOST, DB_USER, DB_PWD, DB_NAME);
$os_found=PHP_OS;
if($os_found=='WINNT'){
	$found_php_path=str_replace('ext/', 'php.exe', ini_get('extension_dir'));
}else if ($os_found=='linux'){
	$found_php_path = exec("which php");
}else{
	$found_php_path= "Please google php path for $os_found";
}
/* check connection */
if (!$mysqli->connect_errno) {
		$mysqli_version=mysqli_get_server_info($mysqli);
}else{
	$mysqli_version="Connection Failed, Please check pure_config.php";
}

$phppath_result=strpos(exec(PHP_PATH." -v"),'Copyright'); 
if ($phppath_result !== false) {
    $phppath_result =true;
}

$phpPath = version_compare($phpVersion, '7.3.0', '>=');

// Directory permissions
$bootstrapDirWriteable = is_writable('Upload');
$storageDirWriteable = is_writeable('Runtime');
$envWriteable = is_writeable('pure_config.php');
// Extension
$redisExtension =extension_loaded('redis');
$opensslExtension = extension_loaded('openssl');
$pdoMysqlExtension = extension_loaded('pdo_mysql');
$mbstringExtension = extension_loaded('mbstring');
$curlExtension = extension_loaded('curl');

$tokenizerExtension = extension_loaded('tokenizer');
$xmlExtension = extension_loaded('xml');
$fileinfoExtension = extension_loaded('fileinfo');
$ctypeExtension = extension_loaded('ctype');
$jsonExtension = extension_loaded('json');
$bcmathExtension = extension_loaded('bcmath');
$zipExtension = extension_loaded('zip');
$gdExtension = extension_loaded('gd');
$allow_url_fopen = ini_get('allow_url_fopen');
$iconvExtension = extension_loaded('iconv');
$libsodium=extension_loaded('iconv');
$exec=function_exists('exec');
$stream_socket_server=function_exists('stream_socket_server');
//$mcypt=function_exists('mcrypt_create_iv');
$extensionRows = [
	'exec'=>$exec,
    'openssl' => $opensslExtension,
	'redis' => $redisExtension,
    'pdo_mysql' => $pdoMysqlExtension,
    'mbstring' => $mbstringExtension,
    'curl' => $curlExtension,
    'tokenizer' => $tokenizerExtension,
    'xml' => $xmlExtension,
    'fileinfo' => $fileinfoExtension,
    'ctype' => $ctypeExtension,
    'json' => $jsonExtension,
    'bcmath' => $bcmathExtension,
    'zip' => $zipExtension,
    'GD' => $gdExtension,
	'allow_url_fopen'=>$allow_url_fopen,
	'iconv'=>$iconvExtension,
	'libsodium'=>$libsodium,
	'stream_socket_server'=>$stream_socket_server,
//	'mcrypt'=>$mcrypt,
];
$isCross = $phpVersionCould && $storageDirWriteable && $bootstrapDirWriteable && $envWriteable;
if ($isCross) {
    foreach ($extensionRows as $extensionRow) {
        $isCross = $isCross && $extensionRow;
    }
}
?>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link crossorigin="anonymous" href="//stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" rel="stylesheet">
    <title>Codono Environment Check</title>
</head>
<body>
<div class="container">
    <div class="row justify-content-center">
        <div class="col-sm-12 mb-0 text-center">
            <h2 style="line-height: 60px;">Codono Environment Check</h2>
        </div>
        <div class="col-sm-12">
            <ul class="list-group">
                <li class="list-group-item list-group-item-info"><b>PHP version detection(Required version:=7.4)</b></li>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <?php echo $phpVersion; ?>
                    <span class="badge badge-<?php echo $phpVersionCould ? 'success' : 'danger' ?> badge-pill">
                            <?php echo $phpVersionCould ? 'Pass' : 'Fail' ?>
                        </span>
                </li>
				<li class="list-group-item list-group-item-info"><b>PHP Path in Pure Config  <strong>[Found: 	<?php echo $found_php_path;?>]</strong></b></li>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <?php echo PHP_PATH;?> 
                    <span class="badge badge-<?php echo $phppath_result ? 'success' : 'danger' ?> badge-pill">
                            <?php echo $phppath_result ? 'Correct Path' : 'Incorrect Path' ?>
                        </span>
                </li>
								<li class="list-group-item list-group-item-info"><b>MySQL connection </b></li>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <?php echo $mysqli_version;?>
                    <span class="badge badge-warning badge-pill">
                            Recommended MariaDB 
                        </span>
                </li>
                <li class="list-group-item list-group-item-info"><b>Directory permission writable</b></li>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <?php echo ('Upload'); ?>
                    <span class="badge badge-<?php echo $bootstrapDirWriteable ? 'success' : 'danger' ?> badge-pill">
                            <?php echo $bootstrapDirWriteable ? 'Writable' : 'Not Writable' ?>
                        </span>
                </li>
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    <?php echo ('Runtime'); ?>
                    <span class="badge badge-<?php echo $storageDirWriteable ? 'success' : 'danger' ?> badge-pill">
                            <?php echo $storageDirWriteable ? 'Writable' : 'Not Writable' ?>
                        </span>
                </li>
                <li class="list-group-item list-group-item-info"><b>PHP extension detection</b></li>
                <?php foreach($extensionRows as $name => $row) { ?>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <?php echo $name; ?>
                        <span class="badge badge-<?php echo $row ? 'success' : 'danger' ?> badge-pill">
                            <?php echo $row ? 'Detected' : 'Not Found' ?>
                        </span>
                    </li>
                <?php } ?>
            </ul>
        </div>
        <div class="col-sm-12 text-center" style="line-height: 120px;">
            <?php if ($isCross) { ?>
                <span class="alert alert-info">You can continue installation </span>
            <?php } else { ?>
                <button disabled class="btn btn-info" type="button">Can't continue</button>
            <?php } ?>
        </div>
    </div>
</div>
</body>
</html>
