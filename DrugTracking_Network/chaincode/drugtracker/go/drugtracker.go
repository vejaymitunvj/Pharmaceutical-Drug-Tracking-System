/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/*
 * Smart contract for adding/updating/querying drug info to and from the blockchain state
 * 
 */

package main

/* Imports
 * 5 utility libraries for formatting, handling bytes, reading and writing JSON, and string manipulation
 * 2 specific Hyperledger Fabric specific libraries for Smart Contracts
 */
import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	sc "github.com/hyperledger/fabric/protos/peer"
)

// SmartCOntract Struct definition
type SmartContract struct {
}

// Define drug structure
type Drug struct {
     Name   string `json:"name"`
	 Type   string `json:"type"`
	 Amount   string `json:"amount"`
	 Chemname   string `json:"chemname"`
	 Nature   string `json:"nature"`
	 Supplier   string `json:"supplier"`
	 Ulabel   string `json:"ulabel"`
	 Sides   string `json:"sides"`
	 Storage   string `json:"storage"`
	 FdaValid   string `json:"fdavalid"`
	 GovtValid   string `json:"govtvalid"`
}

// Define customer structure
type Cust struct {
	Fname   string `json:"fname"`
	Lname  string `json:"lname"`
	Age string `json:"age"`
	Email  string `json:"email"`
	Address  string `json:"address"`
	Condition  string `json:"condition"`
	DoctorApproval  string `json:"doctorapproval"`
	DrugId  string `json:"drugid"`
}
/*
 * Init
 * 
 */
func (s *SmartContract) Init(APIstub shim.ChaincodeStubInterface) sc.Response {
	return shim.Success(nil)
}

/*
 * Invoke to call functionalities
 */
func (s *SmartContract) Invoke(APIstub shim.ChaincodeStubInterface) sc.Response {

	// Retrieve the requested Smart Contract function and arguments
	function, args := APIstub.GetFunctionAndParameters()
	// Route to the appropriate handler function to interact with the ledger appropriately
	if function == "initDrug" {
	    return s.initDrug(APIstub)	
	} else if function == "initCust" {
	    return s.initCust(APIstub)	
	}  else if function == "createDrug" {
	    return s.createDrug(APIstub, args)
	} else if function == "createCust" {
	    return s.createCust(APIstub, args)
	} else if function == "queryAllDrugs" {
	     return s.queryAllDrugs(APIstub)
    } else if function == "queryAllcusts" {
	     return s.queryAllcusts(APIstub)
    } else if function == "verifyUpdateDrug" {
	    return s.verifyUpdateDrug(APIstub, args)
	} else if function == "verifyUpdateDrugByGovt" {
	    return s.verifyUpdateDrugByGovt(APIstub, args)
	} else if function == "queryAllApprovedDrugs" {
	    return s.queryAllApprovedDrugs(APIstub) 
	} else if function == "approveCust" {
	    return s.approveCust(APIstub, args) 
	} else if function == "queryDrugSpecific" {
	    return s.queryDrugSpecific(APIstub, args) 
	}

	return shim.Error("Invalid Smart Contract function name.")
}


// inititalizing drug details function
func (s *SmartContract) initDrug(APIstub shim.ChaincodeStubInterface) sc.Response {
	drugs := []Drug{
		Drug{Name: "Saridon", Type: "Antibiotic", Amount: "200", Chemname: "Sulphatemethyne", Nature: "painkiller", Supplier: "Maanaa", Ulabel: "2354q30", Sides: "sleep", Storage: "ice", FdaValid: "true", GovtValid: "true"},
	}

	i := 0
	for i < len(drugs) {
		fmt.Println("i is ", i)
		drugsAsBytes, _ := json.Marshal(drugs[i])
		//PutState() adds the key-value pair to the blockchain state
		APIstub.PutState("Drug"+strconv.Itoa(i), drugsAsBytes)
		fmt.Println("Added", drugs[i])
		i = i + 1
	}

	return shim.Success(nil)
}

// initializing customer information
func (s *SmartContract) initCust(APIstub shim.ChaincodeStubInterface) sc.Response {
	custs := []Cust{
		
		Cust{Fname: "Ashwath", Lname: "Venkat", Age: "24", Email: "ash@gmail.com", Address: "EE312 Stoneridge", Condition: "Fever", DoctorApproval: "Pending", DrugId : "Drug03"},
	}

	i := 0
	for i < len(custs) {
		fmt.Println("i is ", i)
		custsAsBytes, _ := json.Marshal(custs[i])
		APIstub.PutState("Cust"+strconv.Itoa(i), custsAsBytes)
		fmt.Println("Added", custs[i])
		i = i + 1
	}

	return shim.Success(nil)
}

// Drug creation function
func (s *SmartContract) createDrug(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 12 {
		return shim.Error("Invalid no. of arguments. Expecting 12")
	}

	var drug = Drug{Name: args[1], Type: args[2], Amount: args[3], Chemname: args[4], Nature: args[5], 
	                Supplier: args[6], Ulabel: args[7], Sides: args[8], Storage: args[9], FdaValid: args[10], GovtValid: args[11] }


	drugAsBytes, _ := json.Marshal(drug)
	APIstub.PutState(args[0], drugAsBytes)

	return shim.Success(nil)
}

// create customer entries
func (s *SmartContract) createCust(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 9 {
		return shim.Error("Invalid no. of arguments. Expecting 9")
	}

	var cust = Cust{Fname: args[1], Lname: args[2], Age: args[3], Email: args[4], Address: args[5], Condition: args[6], DoctorApproval: args[7], DrugId: args[8]}

	custAsBytes, _ := json.Marshal(cust)
	APIstub.PutState(args[0], custAsBytes)

	return shim.Success(nil)
}


// Get all drug details to be displayed 
func (s *SmartContract) queryAllDrugs(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "Drug0"
	endKey := "Drug999"

    // GetState Retrieves state from the blockchain
	resIter, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resIter.Close()

	
	var queryResultArray bytes.Buffer
	queryResultArray.WriteString("[")

	qArrayWritten := false
	for resIter.HasNext() {
		queryResponse, err := resIter.Next()
		if err != nil {
			return shim.Error(err.Error())
		}

		if qArrayWritten == true {
			queryResultArray.WriteString(",")
		}
		queryResultArray.WriteString("{\"Key\":")
		queryResultArray.WriteString("\"")
		queryResultArray.WriteString(queryResponse.Key)
		queryResultArray.WriteString("\"")

		queryResultArray.WriteString(", \"Record\":")
		
		queryResultArray.WriteString(string(queryResponse.Value))
		queryResultArray.WriteString("}")
		qArrayWritten = true
	}
	queryResultArray.WriteString("]")

	fmt.Printf("- queryAllDrugs:\n%s\n", queryResultArray.String())

	return shim.Success(queryResultArray.Bytes())
}


// Get details of the customer to be displayed
func (s *SmartContract) queryAllcusts(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "Cust0"
	endKey := "Cust999"

	resIter, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resIter.Close()


	var queryResultArray bytes.Buffer
	queryResultArray.WriteString("[")

	qArrayWritten := false
	for resIter.HasNext() {
		queryResponse, err := resIter.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		
		if qArrayWritten == true {
			queryResultArray.WriteString(",")
		}
		queryResultArray.WriteString("{\"Key\":")
		queryResultArray.WriteString("\"")
		queryResultArray.WriteString(queryResponse.Key)
		queryResultArray.WriteString("\"")

		queryResultArray.WriteString(", \"Record\":")
	
		queryResultArray.WriteString(string(queryResponse.Value))
		queryResultArray.WriteString("}")
		qArrayWritten = true
	}
	queryResultArray.WriteString("]")

	fmt.Printf("- queryAllCusts:\n%s\n", queryResultArray.String())

	return shim.Success(queryResultArray.Bytes())
}


// verfiy the drug by the FDA peer
func (s *SmartContract) verifyUpdateDrug(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Invalid no. of args . Expecting 2")
	}

	drugAsBytes, _ := APIstub.GetState(args[0])
	drug := Drug{}

    // Get State from the blockchain, update and then put state, very simple ! 
	json.Unmarshal(drugAsBytes, &drug)
	drug.FdaValid = args[1]

	drugAsBytes, _ = json.Marshal(drug)
	APIstub.PutState(args[0], drugAsBytes)

	return shim.Success(nil)
}

// verify the drug by the Government interface

func (s *SmartContract) verifyUpdateDrugByGovt(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Invalid no. of args. Expecting 2")
	}

	drugAsBytes, _ := APIstub.GetState(args[0])
	drug := Drug{}

	json.Unmarshal(drugAsBytes, &drug)
	drug.GovtValid = args[1]

	drugAsBytes, _ = json.Marshal(drug)
	APIstub.PutState(args[0], drugAsBytes)

	return shim.Success(nil)
}

// Get the drug information of all the drugs approved by both the Government and FDA peers

func (s *SmartContract) queryAllApprovedDrugs(APIstub shim.ChaincodeStubInterface) sc.Response {

	startKey := "Drug0"
	endKey := "Drug999"

	resIter, err := APIstub.GetStateByRange(startKey, endKey)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resIter.Close()

	
	var queryResultArray bytes.Buffer
	queryResultArray.WriteString("[")

	qArrayWritten := false
	for resIter.HasNext() {
		queryResponse, err := resIter.Next()
		
		if err != nil {
			return shim.Error(err.Error())
		}

		checkString1 := "\"fdavalid\":\"Approved\""
		checkString2 := "\"govtvalid\":\"Approved\""
		if strings.Contains(string(queryResponse.Value), checkString1) && strings.Contains(string(queryResponse.Value), checkString2){
		if qArrayWritten == true {
			queryResultArray.WriteString(",")
		}
		queryResultArray.WriteString("{\"Key\":")
		queryResultArray.WriteString("\"")
		
		queryResultArray.WriteString(queryResponse.Key)
		queryResultArray.WriteString("\"")

		queryResultArray.WriteString(", \"Record\":")
		
		queryResultArray.WriteString(string(queryResponse.Value))
		queryResultArray.WriteString("}")
		qArrayWritten = true
	}
	}
	queryResultArray.WriteString("]")
     
	fmt.Printf("- queryAllDrugs:\n%s\n", queryResultArray.String())

	return shim.Success(queryResultArray.Bytes())
}

// For medic to approve the customer request to purchase the drug

func (s *SmartContract) approveCust(APIstub shim.ChaincodeStubInterface, args []string) sc.Response {

	if len(args) != 2 {
		return shim.Error("Invalid no. of args. Expecting 2")
	}

	custAsBytes, _ := APIstub.GetState(args[0])
	cu := Cust{}

	json.Unmarshal(custAsBytes, &cu)
	cu.DoctorApproval = args[1]

	custAsBytes, _ = json.Marshal(cu)
	APIstub.PutState(args[0], custAsBytes)

	return shim.Success(nil)
}

// To display the information of the drugs for the medic on the modals

func (s *SmartContract) queryDrugSpecific(APIstub shim.ChaincodeStubInterface, args []string) sc.Response{
	/* drugId := args[0];
	getDrugAsBytes,err := APIstub.GetState(drugId)
	// Get the state from the ledger
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + drugId + "\"}"
		return nil, errors.New(jsonResp)
	}
	if getDrugAsBytes == nil {
		jsonResp := "{\"Error\":\"Nil info for " + drugId + "\"}"
		return nil, errors.New(jsonResp)
	}
	jsonResp := "[{\"Key\":\"" + string(getDrugAsBytes.Key) + "\",\"Record\":\"" + string(getDrugAsBytes.Value) + "\"}]"
	fmt.Printf("Query Response:%s\n", jsonResp)
	
	
	return getDrugAsBytes, nil */
	
		if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	drugAsBytes, _ := APIstub.GetState(args[0])
	return shim.Success(drugAsBytes)
}


// For test purposes only
func main() {

	// Create a new Smart Contract
	err := shim.Start(new(SmartContract))
	if err != nil {
		fmt.Printf("Smart contract creation had an error: %s", err)
	}
}
