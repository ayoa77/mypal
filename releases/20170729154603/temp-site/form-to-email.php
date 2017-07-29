<?php
if(!isset($_POST['submit']))
{
	//This page should not be accessed directly. Need to submit the form.
	echo "error; you need to submit the form!";
  exit;
}
$visitor_email = $_POST['email'];

//Validate first
if(empty($visitor_email)) 
{
    echo "Please provide an email address!";
    exit;
}

if(IsInjected($visitor_email))
{
    echo "Bad email value!";
    exit;
}

$email_from = 'noreply@blnkk.com';//<== update the email address
$email_subject = "New BLNKK Form submission";
$email_body = "Someone has left their email addres on BLNKK.\n".
    "This is the address:\n $visitor_email";
    
$to = "info@blnkk.com,gerben@blnkk.com";//<== update the email address
$headers = "From: $email_from \r\n";
//Send the email!
mail($to,$email_subject,$email_body,$headers);
//done. redirect to thank-you page.
header('Location: index.php?thank=you');


// Function to validate against any email injection attempts
function IsInjected($str)
{
  $injections = array('(\n+)',
              '(\r+)',
              '(\t+)',
              '(%0A+)',
              '(%0D+)',
              '(%08+)',
              '(%09+)'
              );
  $inject = join('|', $injections);
  $inject = "/$inject/i";
  if(preg_match($inject,$str))
    {
    return true;
  }
  else
    {
    return false;
  }
}
   
?> 