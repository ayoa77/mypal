<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
	<head>
		<meta charset='utf-8'>
		<title>
			BLNKK - Connect Startup Minds
		</title>
		<meta content='IE=Edge,chrome=1' http-equiv='X-UA-Compatible'>
		<meta content='width=device-width, initial-scale=1' name='viewport'>
		<link href='favicon.png' rel='shortcut icon' type='image/png'>
		<link href='favicon.png' rel='apple-touch-icon' type='image/png'>
		<link href="//fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,300,400,600,700" media="all" rel="stylesheet" type="text/css">
		<link href="//fonts.googleapis.com/css?family=Bitter:400,700,400italic" media="all" rel="stylesheet" type="text/css">
		<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" type="text/css">
		<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css" type="text/css">
		<link rel="stylesheet" href="style.css" type="text/css">
</script>
	</head>
	<body>
		<div class="outer">
			<div class="inner">
				<div class="top">
					<img src="logo.png">
					<h1>
						Connect Startup Minds
					</h1>
				</div>
				<div class="bottom">
					<p class="intro">
						Coming soon (April Fools Day-ish)
					</p>
					<p class="fontawesome">
						
					</p>
					<p>
						Leave your email to take part in the most ambitious human connection project ever.
					</p>
<?php
if (isset($_GET['thank'])) {
  ?>
      		<p>
      			Thank you!
      		</p>
  <?php
}else{
  ?>
					<form method="post" name="emailform" action="form-to-email.php">
						<input type="text" name="email" id="email" placeholder="Email">	
						<input type="submit" name="submit" value="" id="buttonsubmit">	
					</form>
  <?php
}
?>
				</div>
			</div>

			<p><a href="http://blog.blnkk.com">Follow our journey on the blnkk blog</a></p>
		</div>
	</body>
</html>
