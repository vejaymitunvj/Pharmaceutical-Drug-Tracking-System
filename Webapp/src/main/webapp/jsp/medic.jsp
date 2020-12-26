<html>
<head>
<title>Doctor Interface</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
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

	<div class="container" id="docMain">

		<div class="row">
			<div class="col-md-12" id="pageHeaderDiv">

				<h2 id="pageHeader">
					<b>Doctor/Medic Interface</b>
					</h3>
					<a href="logout" id="close"></a>
			</div>
		</div>


		<div class="col-md-12" id="medTabDiv">
			<table class="table" id="medic">
				<thead class="thead-dark">
					<tr>
						<th scope="col">#</th>
						<th scope="col">First Name</th>
						<th scope="col">Last Name</th>
						<th scope="col">Age</th>
						<th scope="col">Condition</th>
						<th scope="col" class="centerA">DrugId / Details</th>
						<th scope="col">Status</th>
						<th scope="col" class="centerA">Approve/Reject</th>
					</tr>
				</thead>
				<tbody>
					<script type='text/javascript'>
                getCustForDoctor();
				</script>
				</tbody>
			</table>

		</div>

		<!--modal-->
		<div class="modal fade" id="exampleModal" tabindex="-1"
			aria-labelledby="exampleModalLabel" aria-hidden="true">
			<div class="modal-dialog">
				<div class="modal-content">
					<div class="modal-header">
						<h5 class="modal-title" id="exampleModalLabel">Drug Details</h5>
						<button type="button" class="close" data-dismiss="modal"
							aria-label="Close">
							<span aria-hidden="true">&times;</span>
						</button>
					</div>
					<div class="modal-body">
						<table id="veTab">
							<tr>
								<th>Name:</th>
								<td><span class=" tra" id="f1"></span></td>
							</tr>
							<tr>
								<th>Dosage:</th>
								<td><span id="f2" class=" tra"></span></td>
							</tr>
							<tr>
								<th>Nature:</th>
								<td><span id="f3" class=" tra"></span></td>
							</tr>
							<tr>
								<th>Chemical Name:</th>
								<td><span id="f4"></span></td>
							</tr>
							<tr>
								<th>Type:</th>
								<td><span id="f5" class=" tra"></span></td>
							</tr>
						</table>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-secondary"
							data-dismiss="modal">Close</button>
					</div>
				</div>
			</div>
		</div>

		<!--modal-->

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