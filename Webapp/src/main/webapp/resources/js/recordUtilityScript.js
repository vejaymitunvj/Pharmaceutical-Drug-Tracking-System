/**
 * This Javascript file has all the Ajax call requests to Spring controller mapping 
 * to the Fabric Java SDK to access the blockchain network.
 * Also includes all utility methods
 */


function addBlock() {

$(document).ready(
	
		function() {
			var html = "";
			var html2 = "";
			for (i = 0; i <= n; i++) {
				
				
				var click = "location.href='blocks'"
				html += "<button id ='no(" + i + ")' value=" + i
						+ " name='blockno' onclick='location.href=\"\/drugtrack-ledger/blocks/"+i+"\";'>Block" + i + "</button>";
				html2 += " <div class='card'><div class='card-header'><a class='card-link' data-toggle='collapse' href='#collapse"+i+"'>Block "+i+"</a></div><div id='collapse"+i+"' class='collapse' data-parent='#blocks'> <div id='carB"+i+"' class='card-body'><script type='text/javascript'>getblockinfo("+i+");</script> </div></div></div>";
				
				$("#blockContainer").html(html);
				$("#blocks").html(html2);
			}
		});



}


function getblockinfo(i){
	
	$.ajax({
		
		url : "blocksNew",
		data : ({
			blockno : i
		}),
		success : function(data) {
			var dataHash = data[0];
			var prevHash =data[1];
			var channelID= data[2];
			var txID=data[3];
			var txcnt = data[4];
			
			$("#carB"+i).html("<table class='table table-bordered'><tr><th>Data Hash</th><td>"+dataHash+"</td></tr><tr><th>Previous Hash</th><td>"+prevHash+"</td></tr><tr><th>Channel</th><td>"+channelID+"</td></tr><tr><th>TransactionID</th><td>"+txID+"</td></tr><tr><th>Transaction Count</th><td>"+txcnt+"</td></tr></table>");

	
		}
	}); 
}


function getDrugs(){
	
	$.ajax({
		url : "queryDrugs",
		success : function(data) {
            createTableDataForDrugs(data);
		}
	});
	
	
}
function getDrugsForManu(){
	
	$.ajax({
		url : "queryDrugs",
		success : function(data) {
			createTableDataForManu(data);
		}
	});
	
	
}

function getDrugsForGovt(){
	
	$.ajax({
		url : "queryDrugs",
		success : function(data) {
            createTableDataForDrugsGovt(data);
		}
	});
	
	
}

function getDrugsForHosp(){
	$.ajax({
		url : "queryApprovedDrugs",
		success : function(data) {
            createTableDataForDrugsHosp(data);
		}
	});
	
}

function getDrugsForCust(){
	$.ajax({
		url : "queryApprovedDrugs",
		success : function(data) {
            addToDropDownCust(data);
		}
	});
	
}

function getCustForDoctor(){
	$.ajax({
		url : "queryCustDetails",
		success : function(data) {
            addToCustTable(data);
		}
	});
}

function getDrugsForDoctor(dId){
	var drugId = dId;
	$.ajax({
		url : "queryDrugSpecific",
		data : ({
			drugId : drugId
		}),
		success : function(data) {
            addToDrugModal(data);
		}
	});
}


function getCustStatus(){
	$.ajax({
		url : "queryCustDetails",
		success : function(data) {
            addToCustTableForCust(data);
		}
	});
}


function addToDrugModal(data){
	
	let tabdat = JSON. parse(data);
	for (var i = 0; i < tabdat.length; i++) {
	
    $("#f1").text(tabdat[i].name);
    $("#f2").text(tabdat[i].amount);
    $("#f3").text(tabdat[i].nature);
    $("#f4").text(tabdat[i].chemname);
    $("#f5").text(tabdat[i].type);
    
	}

    $('#exampleModal').modal('show');
}


function addToCustTableForCust(data){
	let tabdat = JSON. parse(data);
	console.log();
	$("#custStatus tbody").empty();
	var i;
	for (i = 0; i < tabdat.length; i++) {
		let record = tabdat[i].Record;
		var key = tabdat[i].Key;
		console.log(tabdat[0].Key);
		$("#custStatus tbody").append("<tr><td>"+key+"</td><td>"+record.fname+"</td><td>"+record.doctorapproval+"</td></tr>");
	
	}
	
}


function addToCustTable(data){
	let tabdat = JSON. parse(data);
	console.log();
	$("#medic tbody").empty();
	var i;
	for (i = 0; i < tabdat.length; i++) {
		let record = tabdat[i].Record;
		var key = tabdat[i].Key;
		console.log(tabdat[0].Key);
		$("#medic tbody").append("<tr><td>"+key+"</td><td>"+record.fname+"</td><td>"+record.lname+"</td><td>"+record.age+"</td><td>"+record.condition+"</td><td><button type='button' class='btn btn-info btn-lg active' value="+record.drugid+" class='approvalbutton' onclick='getDrugsForDoctor(this.value);'>"+record.drugid+" Click</button></td><td>"+record.doctorapproval+"</td><td><button class='btn btn-danger btn-lg active' value="+key+" class='rejbutton' onclick='updateApproval(this.value,this.className);'>REJECT</button><button class='btn btn-success btn-lg active' value="+key+" class='approvalbutton' onclick='updateApproval(this.value,this.className);'>APPROVE</button></td></tr>");
	
	}
	
}

function addToDropDownCust(data){
	
	let tabdat = JSON. parse(data);
	console.log(tabdat);
    var newSel = document.getElementById("med");
    //if you want to remove this default option use newSel.innerHTML=""
    newSel.innerHTML="<option value=\"\">Select</option>"; // to reset the second list everytime
    var opt;
	var i;
	for (i = 0; i < tabdat.length; i++) {
		let record = tabdat[i].Record;
		var key = tabdat[i].Key;
		opt = document.createElement("option");
        opt.value = key;
        opt.text = record.name;
        newSel.appendChild(opt);	
}
}


function  createTableDataForDrugsHosp(data){
	
	 google.charts.load('current', { 'packages': ['corechart'] });
     google.charts.setOnLoadCallback(drawChart);

  	var data1 = [
        ['init'],
        ['start'],
        ['high'],
        ['end'],
        
    ];
	
	
	let tabdat = JSON. parse(data);
	console.log();
	$("#hospTable tbody").empty();
	var i;
	for (i = 0; i < tabdat.length; i++) {
		let record = tabdat[i].Record;
		var key = tabdat[i].Key;
		console.log(tabdat[0].Key);
		$("#hospTable tbody").append("<tr><td>"+key+"</td><td>"+record.name+"</td><td>"+record.type+"</td><td>"+record.amount+"</td><td>"+record.chemname+"</td><td>"+record.nature+"</td><td>"+record.supplier+"</td><td>"+record.fdavalid+"</td><td>"+record.govtvalid+"</td></tr>");
			data1[0].push(record.name);
			data1[1].push(0);
			data1[2].push(parseInt(record.amount));
			data1[3].push(0);
		}
		console.log(data1);
	
		function drawChart() {
     	

     	
         var data = google.visualization.arrayToDataTable(data1);

         var options = {
             title: 'Drug Dosage',
             curveType: 'function',
             legend: { position: 'bottom' }
         };

         var chart = new google.visualization.LineChart(document.getElementById('curve_chart'));

         chart.draw(data, options);
     }
	
	
	
}

function createTableData(data){
	console.log(JSON. parse(data));
	let tabdat = JSON. parse(data);
	console.log();
	$("#gunTable tbody").empty();
	var i;
	for (i = 0; i < tabdat.length; i++) {
		let record = tabdat[i].Record;
		var key = tabdat[i].Key;
		console.log(tabdat[0].Key);
		$("#gunTable tbody").append("<tr><td>"+key+"</td><td>"+record.make+"</td><td>"+record.model+"</td><td>"+record.type+"</td><td>"+record.valid+"</td><td><button class='btn btn-danger' value="+key+" class='rejbutton' onclick='getV(this.value);'>REJECT</button></td></tr>");
	}
	
}

function createTableDataForDrugs(data){
	let tabdat = JSON. parse(data);
	console.log();
	$("#drugTable tbody").empty();
	var i;
	for (i = 0; i < tabdat.length; i++) {
		let record = tabdat[i].Record;
		var key = tabdat[i].Key;
		console.log(tabdat[0].Key);
		$("#drugTable tbody").append("<tr><td>"+key+"</td><td>"+record.name+"</td><td>"+record.type+"</td><td>"+record.amount+"</td><td>"+record.chemname+"</td><td>"+record.nature+"</td><td>"+record.supplier+"</td><td>"+record.ulabel+"</td><td>"+record.sides+"</td><td>"+record.storage+"</td><td>"+record.fdavalid+"</td><td>"+record.govtvalid+"</td><td><button class='btn btn-danger' value="+key+" class='rejbutton' onclick='updateDrug(this.value,this.className);'>REJECT</button><button class='btn btn-success' value="+key+" class='approvalbutton' onclick='updateDrug(this.value,this.className);'>APPROVE</button></td></tr>");
	}
	
}

function createTableDataForManu(data){
	let tabdat = JSON. parse(data);
	console.log();
	$("#drugTable tbody").empty();
	var i;
	for (i = 0; i < tabdat.length; i++) {
		let record = tabdat[i].Record;
		var key = tabdat[i].Key;
		console.log(tabdat[0].Key);
		$("#drugTable tbody").append("<tr><td>"+key+"</td><td>"+record.name+"</td><td>"+record.type+"</td><td>"+record.amount+"</td><td>"+record.chemname+"</td><td>"+record.nature+"</td><td>"+record.supplier+"</td><td>"+record.ulabel+"</td><td>"+record.sides+"</td><td>"+record.storage+"</td><td>"+record.fdavalid+"</td><td>"+record.govtvalid+"</td></tr>");	}
	
}

function createTableDataForDrugsGovt(data){
	let tabdat = JSON. parse(data);
	console.log();
	$("#drugTable tbody").empty();
	var i;
	for (i = 0; i < tabdat.length; i++) {
		let record = tabdat[i].Record;
		var key = tabdat[i].Key;
		console.log(tabdat[0].Key);
		$("#drugTable tbody").append("<tr><td>"+key+"</td><td>"+record.name+"</td><td>"+record.type+"</td><td>"+record.amount+"</td><td>"+record.chemname+"</td><td>"+record.nature+"</td><td>"+record.supplier+"</td><td>"+record.ulabel+"</td><td>"+record.sides+"</td><td>"+record.storage+"</td><td>"+record.fdavalid+"</td><td>"+record.govtvalid+"</td><td><button class='btn btn-danger' value="+key+" class='rejbutton' onclick='updateDrugGovt(this.value,this.className);'>REJECT</button><button class='btn btn-success' value="+key+" class='approvalbutton' onclick='updateDrugGovt(this.value,this.className);'>APPROVE</button></td></tr>");
	}
	
}


function updateDrug(dId,dname){
	var drugId = dId;
	console.log(drugId);
	console.log(dname);
	var mess;
	if (dname.includes("btn btn-success")){
		mess = "Approved";
	} else
	{
		mess = "Rejected";
	}
	$.ajax({
		url : "updateDrug",
		data : ({
			drugId : drugId,
			mess : mess
		}),
		success : function(data) {
			if(data.includes("SUCCESS")){
				alert("Approval Updated " + data);
				} else 
					alert("Something went wrong. Check block ! "+ data)
			setTimeout(function(){
				location.reload(true);
			},2000)
		}
	});
	
}

function updateApproval(cId,cname){
	var custId = cId;
	console.log(custId);
	console.log(cname);
	var mess;
	if (cname.includes("btn btn-success")){
		mess = "Approved";
	} else
	{
		mess = "Rejected";
	}
	console.log(mess);
	$.ajax({
		url : "updateCustApproval",
		data : ({
			custId : custId,
			mess : mess
		}),
		success : function(data) {
		if(data.includes("SUCCESS")){
				alert("Approval Updated " + data);
				} else 
					alert("Something went wrong. Check block ! " + data)
			setTimeout(function(){
				location.reload(true);
			},2000)
		}
	});
	
}

function updateDrugGovt(dId,dname){
	var drugId = dId;
	console.log(drugId);
	console.log(dname);
	var mess;
	if (dname.includes("btn btn-success")){
		mess = "Approved";
	} else
	{
		mess = "Rejected";
	}
	$.ajax({
		url : "updateDrugGovt",
		data : ({
			drugId : drugId,
			mess : mess
		}),
		success : function(data) {
			if(data.includes("SUCCESS")){
			alert("Approval Updated " + data);
			} else 
				alert("Something went wrong. Check block ! " + data)
			setTimeout(function(){
				location.reload(true);
			},2000)
		}
	});
	
}



function createDrug(e){

	
	var id = n+1;
	var name = $("#name").val();
	var type = $("#type").val();
	var num = $("#num").val();
	var chemName = $("#chemName").val();
	var nat = $("#nat").val();
	var sup = $("#sup").val();
	var ulab = $("#ulab").val();
	var se = $("#se").val();
	var strg = $("#strg").val();
	
	$.ajax({
		url : "createDrug",
		data : ({
			id: id,
			name : name,
			type : type,
			num : num,
			chemName : chemName,
			nat : nat,
			sup : sup,
			ulab : ulab,
			se : se,
			strg : strg
		}),
		success : function(data) {
			
			if(data.includes("200"))
            {
			
			document.getElementById("name").val = "";
			document.getElementById("type").val = "";
			document.getElementById("num").val = "";
			document.getElementById("chemName").val = "";
			document.getElementById("nat").val = "";
			document.getElementById("sup").val = "";
			document.getElementById("ulab").val = "";
			document.getElementById("se").val = "";
			document.getElementById("strg").val = "";
			setTimeout(function(){
				alert("Success " + data);
				location.reload(true);
			},2000);	
			
            }
		}
	});
	

}

function createCust(){
	var id = n+1;
	var fname = $("#fn").val();
	var lname = $("#ln").val();
	var age = $("#age").val();
	var email = $("#em").val();
	var addr = $("#pAdd").val();
	var condition = $( "#con" ).val();
	var drug = $( "#med" ).val();

	$.ajax({
		url : "createCust",
		type: "POST",
		data : ({
			id: id,
			fname: fname,
			lname : lname,
			age : age,
			email : email,
			addr : addr,
			condition : condition,
			drug : drug
		}),
		success : function(data) {
			if(data.includes("200"))
            {
			alert("Sent for Approval from Medic " + data);
			setTimeout(function(){
				location.reload(true);
			},2000)	
			
            }
		}
	});
    
}





function addBlockBasic(){
	$(document).ready(function () {
		var html = "";
	    for (i = 0 ; i < n ; i++){
	    	var click = "location.href='blocks'"
	      	html += "<button id ='no("+i+")' value="+i+" name='blockno' onclick='basicBlockInfo("+i+");'>Block"+i+"</button>";
	    
	      	$("#blockContainer").html(html);}
	});
	
}
function basicBlockInfo(i){
	var blockno;

	blockno = document.getElementById("no("+i+")").value;
	$.ajax({
		
		url : "blocksModal",
		data : ({
			blockno : blockno
		}),
		success : function(data) {
			alert(data);

	
		}
	}); 
	
	
}

function returnTxData(bno){
	console.log(bno);
	var blockno = bno;
	console.log(blockno);
	$.ajax({
		
		url : "txInfo",
		data : ({
			blockno : blockno
		}),
		success : function(data) {
			var disp;
			if (data[19] == undefined || !data[19].includes("Key") || !data[19].includes("value")) {
				disp = data[29];
			}
			else{
				disp = data[19];
			}
			$("#getCode").html("<table><tr><th>Transaction ID:</th><td>"+data[4]+"</td></tr><tr><th>Block Hash:</th><td>"+data[2]+"</td></tr><tr><th>Channel Name:</th><td>"+data[5]+"</td></tr><tr><th>TimeStamp:</th><td>"+data[6]+"</td></tr><tr><th>TransactionType:</th><td>"+data[7]+"</td></tr><tr><th>Transaction Validity:</th><td>"+data[8]+"</td></tr><tr><th>Transaction Response Status:</th><td>"+data[9]+"</td></tr><tr><th>Endorsement Count:</th><td>"+data[11]+"</td></tr><tr><th>Endorsers:</th><td>"+data[12]+"</td></tr><tr><th style=\"color:green;\">Read/WriteSet:</th><td>"+disp+"</td></tr></table>");
			$("#networkModal").modal('show');
			console.log(data[0]);

		}
	}); 

}

function emptyDiv() {
	document.getElementById("div3").innerHTML = "";

}