<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
<title>Customer/Patient Interface</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
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

	<div class="container" id="cusMainCont">
		<div class="row">
			<div class="col-md-12" id="pageHeaderDiv">

				<h2 id="pageHeader">

					<b>CUSTOMER / PATIENT INTERFACE</b>
					</h3>
					<a href="logout" id="close"></a>
			</div>
		</div>

		<form>
			<div class="row" id="custFormDiv">

				<br> <br> <br>
				<div class="col-md-6">
					<h3>Please Enter Your Personal Details</h3>


					<div class="form-group">
						<label for="inputEmail4">First Name</label> <input type="text"
							class="form-control" id="fn" placeholder="Enter Your First Name">
							<span class="errorMsg">Please enter the details</span>
					</div>



					<div class="form-group">
						<label for="inputEmail4">Last Name</label> <input type="text"
							class="form-control" id="ln" placeholder="Enter Your Last Name">
							<span class="errorMsg">Please enter the details</span>
					</div>




					<div class="form-group">
						<label for="inputEmail4">Age</label> <input type="text"
							class="form-control" id="age" placeholder="Enter Your Age">
							<span class="errorMsg">Please enter the details</span>
					</div>




					<div class="form-group">
						<label for="inputEmail4">Email</label> <input type="text"
							class="form-control" id="em" placeholder="Enter Your Last Name">
							<span class="errorMsg">Please enter the details</span>
					</div>

					<div class="form-group">
						<label for="inputEmail4">Address</label>
						<textarea class="form-control" id="pAdd" rows="3"></textarea>
						<span class="errorMsg">Please enter the details</span>
					</div>


				</div>
				<div class="col-md-6">
					<h3>Please Enter Your Medical Details</h3>

					<div class="form-group">
						<label for="inputEmail4">Select your Condition</label> <select
							class="custom-select" id="con">
							<option value="" selected>Select Condition Type</option>
							<option value="Fever">Fever</option>
							<option value="Chlamydia">Chlamydia</option>
							<option value="Influenza">Influenza</option>
							<option value="Staph">Staph</option>
							<option value="Herpes">Herpes</option>
							<option value="Gonorrhea">Gonorrhea</option>
							<option value="Salmonella">Salmonella</option>
							<option value="Pneumonia">Pneumonia</option>
							<option value="Flu">Flu</option>

						</select>
						<span class="errorMsg">Please Select the details</span>
					</div>

					<div class="form-group">
						<label for="inputEmail4">Select Prescribed Medicine</label> <select
							class="custom-select" id="med">
							<option value ="-1" selected>Choose Medicine</option>
							<script type='text/javascript'>
								getDrugsForCust();
							</script>
						</select>
						<span class="errorMsg">Please Select the details</span>
					</div>

					<div class="form-group">
						<label for="inputEmail4">Additional Information</label>
						<textarea class="form-control" id="addIn" rows="5"></textarea>
						<span class="errorMsg">Please enter the details</span>
					</div>




				</div>
				<div class="col-md-12" id="btnDiv">
					<button type="button" id="verifyBtn" class="btn btn-primary">
						Verify</button>
					<button type="button" class="btn btn-danger">Cancel</button>
				</div>
				<br> <br> <br>

				<div class="col-md-12" id="orStat">
					<h2 id="oA">Order Approval Details</h2>
					<div id="custTabDiv">
						<table class="table" id="custStatus">
							<thead class="thead-dark">
								<tr>
									<th scope="col">#</th>
									<th scope="col">First Name</th>
									<th scope="col">Status</th>
								</tr>
							</thead>
							<tbody>
								<script type='text/javascript'>
									getCustStatus();
								</script>
							</tbody>
						</table>
					</div>
				</div>
				<br> <br> <br> <br> <br> <br> <br>
				<br>

				<!--modal-->
				<div class="modal fade" id="exampleModal" tabindex="-1"
					aria-labelledby="exampleModalLabel" aria-hidden="true">
					<div class="modal-dialog">
						<div class="modal-content">
							<div class="modal-header">
								<h5 class="modal-title" id="exampleModalLabel">Verify Your
									Information</h5>
								<button type="button" class="close" data-dismiss="modal"
									aria-label="Close">
									<span aria-hidden="true">&times;</span>
								</button>
							</div>
							<div class="modal-body">
								<table id="veTab">
									<tr>
										<th>First Name:</th>
										<td><span class=" tra" id="f1"></span></td>
									</tr>
									<tr>
										<th>Last Name:</th>
										<td><span id="f2" class=" tra"></span></td>
									</tr>
									<tr>
										<th>Email:</th>
										<td><span id="f3" class=" tra"></span></td>
									</tr>
									<tr>
										<th>Address:</th>
										<td><span id="f4"></span></td>
									</tr>
									<tr>
										<th>Condition:</th>
										<td><span id="f5" class=" tra"></span></td>
									</tr>
									<tr>
										<th>Medicine:</th>
										<td><span id="f6" class=" tra"></span></td>
									</tr>
									<tr>
										<th>Additional Information:</th>
										<td><span id="f7"></span></td>
									</tr>


								</table>
							</div>
							<div class="modal-footer">
								<button type="button" class="btn btn-secondary"
									data-dismiss="modal">Close</button>
								<button type="button" class="btn btn-primary"
									onclick="createCust();">Submit Details</button>
							</div>
						</div>
					</div>
				</div>
				<!--modal-->
				<!-- blocks -->
				<br> <br>
				<div id="ledger" class="col-md-12 ledDiv">
					<h2 id="blockHead">Block Details</h2>
					<span id="blocNum">Number of Blocks: ${noOfBlocks}</span>
					<div id="blocks"></div>
					<!-- Modal  -->
				</div>
				<script type='text/javascript'>
					addBlock();
				</script>

				<div class="modal fade" id="networkModal" tabindex="-1"
					role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
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
				<!-- Modal  -->



			</div>

		</form>

	</div>
	<footer>
		<span id="uflog"></span> <a href="logout" class="rht">Home</a> <a
			href="#news" class="rht">News</a> <a href="#contact" class="rht">Contact</a>

	</footer>
</body>
<SCRIPT>
	$(document).ready(function() {

		$("#verifyBtn").on('click', function() {

			var fn = $("#fn").val();
			var ln = $("#ln").val();
			var em = $("#em").val();
			var add = $("#pAdd").val();
			var con = $("#con").val();
			var med = $("#med").val();
			var ai = $("#addIn").val();

			$("#f1").text(fn);
			$("#f2").text(ln);
			$("#f3").text(em);
			$("#f4").text(add);
			$("#f5").text(con);
			$("#f6").text(med);
			$("#f7").text(ai);

			
		});

	});
	//
</SCRIPT>

	<script>
		$(document).ready(function(){
			$("#verifyBtn").on('click',function(){
				var flag = true;    
				$("input,select,textarea").each(function(){
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
					$('#exampleModal').modal('show');

				}

				});
			
			$("input,select,textarea").on('focus',function(){
				$(this).removeClass('err');
				$(this).next().hide();
			});
			
			
		});
	</script>

</html>