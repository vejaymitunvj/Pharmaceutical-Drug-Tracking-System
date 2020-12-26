<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Govt Interface</title>
<link rel="stylesheet"
	href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script
	src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<link href="resources/bootstrap/css/common.css" rel="stylesheet">
<script src="resources/js/recordUtilityScript.js"></script>
<script type="text/javascript">
	var n = ${noOfBlocks};
</script>
<style>
.dropbtn {
	background-color: #3498DB;
	color: white;
	padding: 16px;
	font-size: 16px;
	border: none;
	cursor: pointer;
}

.dropbtn:hover, .dropbtn:focus {
	background-color: #2980B9;
}

.dropdown {
	position: relative;
	display: inline-block;
}

.dropdown-content {
	display: none;
	position: absolute;
	background-color: #f1f1f1;
	min-width: 160px;
	overflow: auto;
	box-shadow: 0px 8px 16px 0px rgba(0, 0, 0, 0.2);
	z-index: 1;
}

.dropdown-content a {
	color: black;
	padding: 12px 16px;
	text-decoration: none;
	display: block;
}

.dropdown a:hover {
	background-color: #ddd;
}

.show {
	display: block;
}
</style>
</head>
<style>
#contTable {
	margin-top: 30px;
}
</style>

<body>
	<header id="head">
	<h1 id="title">
		<span id="hlog"></span>PHARMA-LEDGER
	</h1>
	<div id="icon">
		<span id="fb" class="ico"> </span> <span id="twit" class="ico">
		</span> <span id="you" class="ico"> </span>

	</div>
	</header>
	<br>

	<div class="container">
		 		<div class="row">
			<div class="col-md-12" id="pageHeaderDiv">

				<h2 id="pageHeader">
					<b>GOVERNMENT INTERFACE</b>
				</h3>
				  <a href="logout" id="close"></a>
			</div>
	</div>
	</div>


	<div id="getGuns" class="" style="">
	<h2 id="appDD">Drugs For Government Approval</h2>
		<button class="btn btn-lg btn-info btn-block" type="button"
			onclick="getDrugsForGovt();">Get Drug Info</button>


		<div class="table-wrapper-scroll-y my-custom-scrollbar" id='tabDiv'>

			<table class="table table-bordered table-striped mb-0" id="drugTable">
				<thead>
					<tr>
						<th>ID</th>
						<th>Name</th>
						<th>Type</th>
						<th>Dosage</th>
						<th>Chemical Name</th>
						<th>Nature</th>
						<th>Supplier</th>
						<th>Unique Label</th>
						<th>Side Effects</th>
						<th>Storage</th>
						<th>FDA Validity</th>
						<th>Govt Validity</th>
						<th class="centerA">Approval</th>
					</tr>
				</thead>
				<tbody>

				</tbody>
			</table>

		</div>
	</div>
	<div class="container">
	<div class="row">
		<div id="ledger" class="col-md-12 ledDiv">
		<h2 id="blockHead">Block Details</h2>
			<span id="blocNum">Number of Blocks: ${noOfBlocks}</span>
			<div id="blocks"></div>
		<!-- Modal  -->
		</div>
			<script type='text/javascript'>
				addBlock();
				</script>
		
				<div class="modal fade" id="networkModal" tabindex="-1" role="dialog"
			aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">
					<div class="modal-header">
					<h4 class="modal-title" id="myModalLabel">TRANSACTION INFO</h4>
						<button type="button" class="close" data-dismiss="modal"
							aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
						
					</div>
					<div class="modal-body" id="getCode" style="overflow-x: scroll;">
					</div>
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