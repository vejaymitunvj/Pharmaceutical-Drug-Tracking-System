<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" isELIgnored="false"%>
<!DOCTYPE html>
<html>
<head>
<%
	String context = request.getContextPath();
%>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Pharma-Ledger</title>


<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/js/bootstrap.min.js"></script>

<link href="<%=context%>/resources/bootstrap/css/common.css"
	rel="stylesheet">
</head>
<body id="login" class="" style="">

	<header id="head">
		<h1 id="title">
			<span id="hlog"></span>PHARMA-LEDGER
		</h1>
		<div id="icon">
			<span id="fb" class="ico"> </span> <span id="twit" class="ico">
			</span> <span id="you" class="ico"> </span>

		</div>
	</header>
	<div id="mainBod" class="container-fluid">

		<div class="row">


			<div id="loginPage" class="col-md-6 col-md-offset-3">

				<div id="leftPane" class="col-md-8"></div>
				<div id="rightPane" class="col-md-4">
					<span id="sIhd">SIGN IN</span>
					<div id="logForm" class="login-form">
						<form class="form-signin" method="post" action="validate"
							autocomplete="off" enctype="multipart/form-data">
							<div class="form-group">
								<label>User Name</label> <input type="text" id="username"
									class="form-control" placeholder="User Name" name="p_sUsername"
									required autofocus>
							</div>
							<div class="form-group">
								<label>Password</label> <input type="password"
									class="form-control" placeholder="Password" id="inputPassword"
									name="p_sPassword" autocomplete="new-password" required>
							</div>
							<label for="inputFile" class="sr-only">MSP File</label> <input
								type="file" id="fileToUpload" name="file" required> <br>
							<div class="form-check">
								<input type="checkbox" class="form-check-input"
									id="materialUnchecked"> <label class="form-check-label"
									for="materialUnchecked">Remember Me</label>
							</div>
							<button id="loginbtn" type="submit" class="btn btn-primary"
								type="submit">Login</button>

						</form>
					</div>

				</div>
			</div>
		</div>
	</div>
	<footer>
		<span id="uflog"></span> <a href="logout" class="rht">Home</a> <a
			href="#news" class="rht">News</a> <a href="#contact" class="rht">Contact</a>

	</footer>
</body>
</html>