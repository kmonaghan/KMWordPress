<?php
date_default_timezone_set ('Europe/London');

define ('IMAGE_UPLOAD_DIRECTORY', '<upload-directory>');
define ('NOTIFICATION_EMAIL', '<your-email>');
define ('WWW', '<your-website>');

	function process($email, $image)
	{
		if ($image['error'])
		{
			return false;
		}
		
		$uploaddir = IMAGE_UPLOAD_DIRECTORY;
		$parts = explode('.', $image['name']);

		$uniqueName = md5($email) . '_' . '_' . date("Ymdhis") . '.' . array_pop($parts);
		$uploadfile = $uploaddir . $uniqueName;

		if (!move_uploaded_file($image['tmp_name'], $uploadfile))
		{
			$error = 'Could not move file';
			return false;
		}

		return $uniqueName;
	}
	
$status = 1;
$data = array('message' => '');

if (!$_POST['name'] && empty($_POST['name']))
{
	$status = 0;
	$data['message'] .= "No name supplied\n";
}

/*
if (!filter_var($_POST['email'], FILTER_VALIDATE_EMAIL))
{
	$status = 0;
	$data['message'] .= "Invalid email address supplied\n";
}
*/
if (!$_POST['message'] && empty($_POST['message']))
{
	$status = 0;
	$data['message'] .= "No message supplied\n";
}

if ($status)
{
	$message = "From:{$_POST['name']} ({$_POST['email']})\n{$_POST['message']}";
	
	foreach($_FILES as $key => $value)
	{
		$name = process($_POST['email'], $_FILES[$key]);
		
		if ($name)
		{
			$message .= "\n" . WWW . IMAGE_UPLOAD_DIRECTORY . $name."\n";
		}
	}
	$data['files'] = $_FILES;
	
	mail(NOTIFICATION_EMAIL, '[iPhone App] New message', $message);
	
	$data['message'] = 'Thanks for getting in touch!';
}

$return = array('status' => $status, 'response' => $data);

header('Cache-Control: no-cache, must-revalidate');
header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
header('Content-type: application/json');

echo json_encode($return);
