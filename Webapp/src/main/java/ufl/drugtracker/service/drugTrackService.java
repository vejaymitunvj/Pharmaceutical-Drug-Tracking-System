package ufl.drugtracker.service;

import java.io.IOException;
import java.util.List;

import org.hyperledger.fabric.sdk.exception.InvalidArgumentException;
import org.hyperledger.fabric.sdk.exception.ProposalException;

import com.google.protobuf.InvalidProtocolBufferException;

public interface drugTrackService {
	
	public boolean validateLogin(String p_sUsername, String p_sPassword);

	public int getNumberOfBlocks() throws ProposalException, InvalidArgumentException;

	public String getBlockBasicInfoAlert(int blockno) throws InvalidArgumentException, ProposalException, InvalidProtocolBufferException;

	public List<String> getBlockBasicInfo(int blockno) throws InvalidArgumentException, ProposalException, InvalidProtocolBufferException;

	public List<String> getTxInfoByNumber(int blockno) throws InvalidArgumentException, ProposalException, IOException;

	public String createDrug(String id, String name, String type, String num, String chemName, String nat, String sup,
			String ulab, String se, String strg) throws ProposalException, InvalidArgumentException;

	public String queryAllDrugs() throws InvalidArgumentException, ProposalException;

	public String updateDrug(String drugId, String mess) throws InvalidArgumentException, ProposalException;

	public String updateDrugGovt(String drugId, String mess) throws ProposalException, InvalidArgumentException;

	public String queryApprovedDrugs() throws InvalidArgumentException, ProposalException;

	public String createCust(String id, String fname, String lname, String age, String email, String address, String condition,
			String drug) throws ProposalException, InvalidArgumentException;

	public String queryAllCustomers() throws InvalidArgumentException, ProposalException;

	public String updateCustApproval(String custId, String mess) throws ProposalException, InvalidArgumentException;

	public String queryDrugSpecific(String drugId) throws InvalidArgumentException, ProposalException;
}
