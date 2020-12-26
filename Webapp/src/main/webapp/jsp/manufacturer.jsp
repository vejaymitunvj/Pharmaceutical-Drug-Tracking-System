<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>

<title>Drug Tracking using Fabric</title>


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

div.scrollmenu {
	background-color: #333;
	overflow: auto;
	white-space: nowrap;
}

div.scrollmenu button {
	display: inline-block;
	text-decoration: none;
	color: #fff;
	font-weight: bold;
	background-color: #538fbe;
	padding: 20px 20px;
	font-size: 15px;
	border: 1px solid #2d6898;
	box-shadow: 0px 6px 0px #2b638f, 0px 3px 15px rgba(0, 0, 0, .4), inset
		0px 1px 0px rgba(255, 255, 255, .3), inset 0px 0px 3px
		rgba(255, 255, 255, .5);
}

div.scrollmenu button:hover {
	background-color: #777;
}

#mytable {
	font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
	border-collapse: collapse;
	width: 75px;
	margin-left: 15px;
}

#mytable td, #mytable th {
	border: 1px solid #ddd;
	padding: 8px;
}

#mytable tr:nth-child(even) {
	background-color: #f2f2f2;
}

#mytable tr:hover {
	background-color: #ddd;
}

#mytable th {
	padding-top: 12px;
	padding-bottom: 12px;
	text-align: left;
	background-color: black;
	color: white;
}

.my-custom-scrollbar {
	position: relative;
	height: 200px;
	overflow: auto;
}

.table-wrapper-scroll-y {
	display: block;
}

#tabDiv, #createQueryGuns {
	margin-top: 30px;
}
</style>

</head>
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

	<div class="container">

		<div class="row">
			<div class="col-md-12" id="pageHeaderDiv">

				<h2 id="pageHeader">

					<b>DRUG MANUFACTURER INTERFACE</b>
					</h3>
					<a href="logout" id="close"></a>
			</div>
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


		<br>


		<div class="form-row">
			<div class="form-group col-md-6">
				<label for="name">Name</label> <input type="text"
					class="form-control" id="name" placeholder="Enter Name" required />
					<span class="errorMsg">Please enter the details</span>
			</div>
			<div class="form-group col-md-6">
				<label for="inputPassword4">Type</label> <input type="text"
					class="form-control" id="type" placeholder="Enter Type" required />
					<span class="errorMsg">Please enter the details</span>
			</div>
		</div>

		<!-- 2 -->
		<div class="form-row">
			<div class="form-group col-md-6">
				<label for="inputEmail4">Amount</label> <input type="number"
					class="form-control" id="num" placeholder="Enter Amount" required />
					<span class="errorMsg">Please enter the details</span>
			</div>
			<div class="form-group col-md-6">
				<label for="inputPassword4">Chemical Name</label> <input type="text"
					class="form-control" id="chemName"
					placeholder="Enter Chemical Name">
					<span class="errorMsg">Please enter the details</span>
			</div>
		</div>
		<!-- 3 -->
		<div class="form-row">
			<div class="form-group col-md-6">
				<label for="inputEmail4">Nature</label> <input type="text"
					class="form-control" id="nat" placeholder="Nature of Chemical">
					<span class="errorMsg">Please enter the details</span>
			</div>
			<div class="form-group col-md-6">
				<label for="inputPassword4">Supplier</label> <input type="text"
					class="form-control" id="sup" placeholder="Enter Supplier Name"
					required>
					<span class="errorMsg">Please enter the details</span>
			</div>
		</div>
		<!-- 4 -->
		<div class="form-row">
			<div class="form-group col-md-6">
				<label for="inputEmail4">Unique Label</label> <input type="text"
					class="form-control" id="ulab"
					placeholder="Enter Chemical's Unique Label" required>
					<span class="errorMsg">Please enter the details</span>
			</div>
			<div class="form-group col-md-6">
				<label for="inputPassword4">Side Effect</label> <input type="text"
					class="form-control" id="se" placeholder="Enter Side Effect">
					<span class="errorMsg">Please enter the details</span>
			</div>
		</div>
		<!-- 5 -->
		<div class="form-row">
			<div class="form-group col-md-6">
				<label for="inputEmail4">Storage</label> <input type="text"
					class="form-control" id="strg" placeholder="Enter Storage Limit">
					<span class="errorMsg">Please enter the details</span>
			</div>

		</div>
		<div id="successDiv"></div>
		<button id="createBtn" class="btn btn-primary" type="submit">Create Drug</button>


		<br> <br>

		<div id="getGunsm" class="col-md-12">
			<h2 id="gunHead">Drug Details</h2>
			<button class="btn btn-lg btn-success btn-block" type="button"
				onclick="getDrugsForManu();">Get Drug Info</button>


			<div class="table-wrapper-scroll-y my-custom-scrollbar" id='tabDiv'>

				<table class="table table-bordered table-striped mb-0"
					id="drugTable">
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
						</tr>
					</thead>
					<tbody>

					</tbody>
				</table>

			</div>
		</div>
		<br>
		<div id="ledger">
			<h2 id="blockHead">Block Details</h2>
			<span id="blocNum">Number of Blocks: ${noOfBlocks}</span>
			<div id="blocks"></div>
		</div>
	</div>
	<footer>
		<span id="uflog"></span> <a href="logout" class="rht">Home</a> <a
			href="#news" class="rht">News</a> <a href="#contact" class="rht">Contact</a>

	</footer>
	
	<script>
		$(document).ready(function(){
			$("#createBtn").on('click',function(){
				var flag = true;    
				$("input").each(function(){
				    var tex = $(this).val();
				if(tex == ''){
				    $(this).addClass('err');
				    $(this).next().show();
				    flag = false;
				}
				else{
					$(this).removeClass('err');
					$(this).next().hide();
				}

				    });
				if(flag){
				    createDrug();
				}

				});
			
			$("input").on('focus',function(){
				$(this).removeClass('err');
				$(this).next().hide();
			});
			
			
		});
	</script>
</body>
</html>