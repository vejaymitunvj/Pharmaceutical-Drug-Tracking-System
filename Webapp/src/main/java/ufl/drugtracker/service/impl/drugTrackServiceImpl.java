package ufl.drugtracker.service.impl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.commons.codec.binary.Hex;
import org.hyperledger.fabric.protos.ledger.rwset.kvrwset.KvRwset;
import org.hyperledger.fabric.sdk.BlockInfo;
import org.hyperledger.fabric.sdk.ChaincodeID;
import org.hyperledger.fabric.sdk.Channel;
import org.hyperledger.fabric.sdk.HFClient;
import org.hyperledger.fabric.sdk.ProposalResponse;
import org.hyperledger.fabric.sdk.QueryByChaincodeRequest;
import org.hyperledger.fabric.sdk.SDKUtils;
import org.hyperledger.fabric.sdk.TransactionProposalRequest;
import org.hyperledger.fabric.sdk.TxReadWriteSetInfo;
import org.hyperledger.fabric.sdk.exception.InvalidArgumentException;
import org.hyperledger.fabric.sdk.exception.InvalidProtocolBufferRuntimeException;
import org.hyperledger.fabric.sdk.exception.ProposalException;

import com.google.protobuf.InvalidProtocolBufferException;

import ufl.drugtracker.service.drugTrackService;
import ufl.drugtracker.setup.BlockChainHFClient;

/*
 * This class is responsible for all transaction and query to the blockchain operations
 * Functions and calls to the blockchain are done here through TransactionProposal and QueryProposal 
 * Block related information is also got from here
 */

public class drugTrackServiceImpl implements drugTrackService {

	@Override
	public boolean validateLogin(String p_sUsername, String p_sPassword) {
		if (p_sUsername.equalsIgnoreCase("medic") && p_sPassword.equalsIgnoreCase("medic")
				|| (p_sUsername.equals("fda") && p_sPassword.equals("fda"))
				|| (p_sUsername.equals("manufacturer") && p_sPassword.equals("manufacturer"))
				|| (p_sUsername.equals("govt") && p_sPassword.equals("govt"))
				|| (p_sUsername.equals("cust") && p_sPassword.equals("cust"))
				|| (p_sUsername.equals("hosp") && p_sPassword.equals("hosp")))
			return true;
		else
			return false;
	}

	@Override
	public int getNumberOfBlocks() throws ProposalException, InvalidArgumentException {
		int noOfblocks = (int) BlockChainHFClient.getInstance().getCh().queryBlockchainInfo().getHeight();
		return noOfblocks;
	}

	@Override
	public String getBlockBasicInfoAlert(int blockNumber)
			throws InvalidArgumentException, ProposalException, InvalidProtocolBufferException {

		Channel channel = BlockChainHFClient.getInstance().getCh();
		String dataHash = null;
		try {
			dataHash = Hex.encodeHexString(channel.queryBlockByNumber(blockNumber).getDataHash());
		} catch (InvalidArgumentException | ProposalException e) {
			e.printStackTrace();
			throw e;
		}

		String previousHash = null;
		try {
			previousHash = Hex.encodeHexString(channel.queryBlockByNumber(blockNumber).getPreviousHash());
		} catch (InvalidArgumentException | ProposalException e) {
			e.printStackTrace();
			throw e;
		}
		String channelName = null;
		try {
			channelName = channel.queryBlockByNumber(blockNumber).getChannelId();
		} catch (InvalidProtocolBufferException | InvalidArgumentException | ProposalException e) {
			e.printStackTrace();
			throw e;
		}
		String txId = null;
		try {
			txId = channel.queryBlockByNumber(blockNumber).getEnvelopeInfos().iterator().next().getTransactionID();
		} catch (InvalidArgumentException | ProposalException e) {
			e.printStackTrace();
			throw e;
		}

		return "\n Datahash: " + dataHash + "\nPrevioushash: " + previousHash + "\nChannelName: " + channelName
				+ "\nTransaction ID: " + txId + "\n";
	}

	public List<String> getBlockBasicInfo(int blockNumber)
			throws InvalidArgumentException, ProposalException, InvalidProtocolBufferException {

		List<String> info = new ArrayList<String>();
		Channel channel = BlockChainHFClient.getInstance().getCh();

		String dataHash = null;
		try {
			dataHash = Hex.encodeHexString(channel.queryBlockByNumber(blockNumber).getDataHash());
			info.add(dataHash);
		} catch (InvalidArgumentException | ProposalException e) {
			e.printStackTrace();
			throw e;
		}

		String previousHash = null;
		try {
			previousHash = Hex.encodeHexString(channel.queryBlockByNumber(blockNumber).getPreviousHash());
			info.add(previousHash);
		} catch (InvalidArgumentException | ProposalException e) {
			e.printStackTrace();
			throw e;
		}
		String channelName = null;
		try {
			channelName = channel.queryBlockByNumber(blockNumber).getChannelId();
			info.add(channelName);
		} catch (InvalidProtocolBufferException | InvalidArgumentException | ProposalException e) {
			e.printStackTrace();
			throw e;
		}
		String txId = null;
		try {
			txId = channel.queryBlockByNumber(blockNumber).getEnvelopeInfos().iterator().next().getTransactionID();
			String txCount = Integer.toString(channel.queryBlockByNumber(blockNumber).getTransactionCount());
			info.add("<a href='javascript:void(0);' onclick='returnTxData(" + blockNumber + ");'>" + txId + "</a>");
			info.add(txCount);
		} catch (InvalidArgumentException | ProposalException e) {
			e.printStackTrace();
			throw e;
		}

		return info;
	}

	/**
	 * Get transaction specific information for the particular block
	 */
	public List<String> getTxInfoByNumber(int number) throws InvalidArgumentException, ProposalException, IOException {

		ArrayList<String> blockList = new ArrayList<String>();
		try {

			Channel channel = BlockChainHFClient.getInstance().getCh();
			HFClient client = BlockChainHFClient.getInstance().getClient();
			BlockInfo blockInfo = null;
			try {
				blockInfo = channel.queryBlockByNumber(number);
			} catch (InvalidArgumentException | ProposalException e) {
				e.printStackTrace();
			}
			final long blockNumber = blockInfo.getBlockNumber();

			blockList.add("DATA HASH: " + Hex.encodeHexString(blockInfo.getDataHash()));
			blockList.add("PREVIOUS HASH: " + Hex.encodeHexString(blockInfo.getPreviousHash()));
			try {
				blockList.add("CALCULATED HASH: " + Hex.encodeHexString(SDKUtils.calculateBlockHash(client, blockNumber,
						blockInfo.getPreviousHash(), blockInfo.getDataHash())));
			} catch (InvalidArgumentException | IOException e) {
				e.printStackTrace();
				throw e;
			}

			// Transaction Count
			blockList.add(Integer.toString(blockInfo.getTransactionCount()));
			for (BlockInfo.EnvelopeInfo envelopeInfo : blockInfo.getEnvelopeInfos()) {

				// Transaction ID
				blockList.add(envelopeInfo.getTransactionID());
				final String channelId = envelopeInfo.getChannelId();

				// Channel Name
				blockList.add(channelId);
				// Time Stamp
				blockList.add(envelopeInfo.getTimestamp().toString());
				// Transaction Type
				blockList.add(envelopeInfo.getType().toString());

				if (envelopeInfo.getType().TRANSACTION_ENVELOPE != null) {
					BlockInfo.TransactionEnvelopeInfo transactionEnvelopeInfo = (BlockInfo.TransactionEnvelopeInfo) envelopeInfo;

					// Transaction Validity
					blockList.add(String.valueOf(transactionEnvelopeInfo.isValid()));

					for (BlockInfo.TransactionEnvelopeInfo.TransactionActionInfo transactionActionInfo : transactionEnvelopeInfo
							.getTransactionActionInfos()) {
						// Transaction Response Status
						blockList.add(Integer.toString(transactionActionInfo.getResponseStatus()));
						try {
							blockList.add("RESPONSE MESSAGE: " + printableString(
									new String(transactionActionInfo.getResponseMessageBytes(), "UTF-8")));
						} catch (UnsupportedEncodingException e) {
							e.printStackTrace();
							throw e;
						}
						// Endorsement Count
						blockList.add(Integer.toString(transactionActionInfo.getEndorsementsCount()));

						List<String> endorserList = new ArrayList<String>();
						for (int n = 0; n < transactionActionInfo.getEndorsementsCount(); ++n) {
							BlockInfo.EndorserInfo endorserInfo = transactionActionInfo.getEndorsementInfo(n);
							endorserList.add(endorserInfo.getMspid());
						}
						// Endorser List
						blockList.add(endorserList.toString());
						// Chain code Argument Count
						blockList.add(Integer.toString(transactionActionInfo.getChaincodeInputArgsCount()));
						for (int z = 0; z < transactionActionInfo.getChaincodeInputArgsCount(); ++z) {
							try {
								// Chain code Argument
								blockList.add(printableString(
										new String(transactionActionInfo.getChaincodeInputArgs(z), "UTF-8")));
							} catch (UnsupportedEncodingException e) {
								e.printStackTrace();
								throw e;
							}
						}

						blockList.add("PROPOSAL RESPONSE STATUS: "
								+ Integer.toString(transactionActionInfo.getProposalResponseStatus()));
						blockList.add("PROPOSAL RESPONSE PAYLOAD: "
								+ printableString(new String(transactionActionInfo.getProposalResponsePayload())));

						TxReadWriteSetInfo rwsetInfo = transactionActionInfo.getTxReadWriteSet();
						if (null != rwsetInfo) {

							for (TxReadWriteSetInfo.NsRwsetInfo nsRwsetInfo : rwsetInfo.getNsRwsetInfos()) {

								KvRwset.KVRWSet rws = null;
								try {
									rws = nsRwsetInfo.getRwset();
								} catch (InvalidProtocolBufferException e) {
									e.printStackTrace();
								}

								for (KvRwset.KVWrite writeList : rws.getWritesList()) {

									String valAsString = null;
									try {
										valAsString = printableString(
												new String(writeList.getValue().toByteArray(), "UTF-8"));
									} catch (UnsupportedEncodingException e) {
										e.printStackTrace();
										throw e;
									}

									// Read / Write List
									blockList.add(
											"<b>Key</b> " + writeList.getKey() + " has <b>value</b> " + valAsString);

								}
							}
						}
					}
				}
			}
		} catch (InvalidProtocolBufferRuntimeException e) {
			throw e.getCause();
		}

		return blockList;
	}

	/**
	 * Utility Method for converting stream to string
	 * 
	 * @param is
	 * @return converted String
	 * @throws IOException
	 */
	private String convertStreamToString(InputStream is) throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(is));
		StringBuilder sb = new StringBuilder();
		String line = null;

		try {
			while ((line = reader.readLine()) != null) {
				sb.append(line + "\n");
			}
		} catch (IOException e) {
			throw e;
		} finally {
			try {
				is.close();
			} catch (IOException e) {
				throw e;
			}
		}

		return sb.toString();
	}

	/**
	 * Utility method to make string printable in a specific format
	 * 
	 * @param string
	 * @return printableString
	 */
	private String printableString(final String string) {
		int maxLogStringLength = 10000;
		if (string == null || string.length() == 0) {
			return string;
		}

		String ret = string.replaceAll("[^\\p{Print}]", "\n");

		ret = ret.substring(0, Math.min(ret.length(), maxLogStringLength))
				+ (ret.length() > maxLogStringLength ? "..." : "");

		return ret;

	}

	@Override
	public String createDrug(String id, String name, String type, String num, String chemName, String nat, String sup,
			String ulab, String se, String strg) throws ProposalException, InvalidArgumentException {
		// TODO Auto-generated method stub
		TransactionProposalRequest req = BlockChainHFClient.getInstance().getClient().newTransactionProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID cid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		req.setChaincodeID(cid);
		req.setFcn("createDrug");
		req.setArgs(new String[] { "Drug" + id, name, type, num, chemName, nat, sup, ulab, se, strg, "Approval Pending",
				"Aprroval Pending" });

		Collection<ProposalResponse> resps = channel.sendTransactionProposal(req);
		int status = 0;
		String txId = null;
		channel.sendTransaction(resps);
		for (ProposalResponse pres : resps) {
			status = pres.getChaincodeActionResponseStatus();
			txId = pres.getTransactionID();
		}

		return Integer.toString(status) + "Transaction ID: " +txId;
	}

	@Override
	public String queryAllDrugs() throws InvalidArgumentException, ProposalException {
		QueryByChaincodeRequest request = BlockChainHFClient.getInstance().getClient().newQueryProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID ccid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		request.setChaincodeID(ccid);
		request.setFcn("queryAllDrugs");
		String args = null;
		if (args != null)
			request.setArgs(args);

		Collection<ProposalResponse> response = channel.queryByChaincode(request,
				BlockChainHFClient.getInstance().getAdminPeer());
		String stringResponse = null;
		for (ProposalResponse pres : response) {
			stringResponse = new String(pres.getChaincodeActionResponsePayload());
		}
		return stringResponse;
	}

	@Override
	public String updateDrug(String drugId, String mess) throws InvalidArgumentException, ProposalException {
		// TODO Auto-generated method stub
		TransactionProposalRequest req = BlockChainHFClient.getInstance().getClient().newTransactionProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID cid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		req.setChaincodeID(cid);
		req.setFcn("verifyUpdateDrug");

		req.setArgs(new String[] { drugId, mess });

		Collection<ProposalResponse> resps = channel.sendTransactionProposal(req);

		channel.sendTransaction(resps);
		String stringResponse = null;
		for (ProposalResponse pres : resps) {
			stringResponse = pres.getStatus().name() + " Transaction ID: "+ pres.getTransactionID();
		}
		return stringResponse;

	}

	@Override
	public String updateDrugGovt(String drugId, String mess) throws ProposalException, InvalidArgumentException {
		// TODO Auto-generated method stub
		TransactionProposalRequest req = BlockChainHFClient.getInstance().getClient().newTransactionProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID cid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		req.setChaincodeID(cid);
		req.setFcn("verifyUpdateDrugByGovt");

		req.setArgs(new String[] { drugId, mess });

		Collection<ProposalResponse> resps = channel.sendTransactionProposal(req);

		channel.sendTransaction(resps);
		String stringResponse = null;
		for (ProposalResponse pres : resps) {
			stringResponse = pres.getStatus().name() + " Transaction ID: "+ pres.getTransactionID();
		}
		return stringResponse;
	}

	@Override
	public String queryApprovedDrugs() throws InvalidArgumentException, ProposalException {
		QueryByChaincodeRequest request = BlockChainHFClient.getInstance().getClient().newQueryProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID ccid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		request.setChaincodeID(ccid);
		request.setFcn("queryAllApprovedDrugs");
		String args = null;
		if (args != null)
			request.setArgs(args);

		Collection<ProposalResponse> response = channel.queryByChaincode(request,
				BlockChainHFClient.getInstance().getAdminPeer());
		String stringResponse = null;
		for (ProposalResponse pres : response) {
			stringResponse = new String(pres.getChaincodeActionResponsePayload());
		}
		return stringResponse;
	}

	@Override
	public String createCust(String id, String fname, String lname, String age, String email, String address,
			String condition, String drug) throws ProposalException, InvalidArgumentException {
		TransactionProposalRequest req = BlockChainHFClient.getInstance().getClient().newTransactionProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID cid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		req.setChaincodeID(cid);
		req.setFcn("createCust");
		req.setArgs(new String[] { "Cust" + id, fname, lname, age, email, address, condition, "Pending", drug });

		Collection<ProposalResponse> resps = channel.sendTransactionProposal(req);
		int status = 0;
		String txId = null;
		channel.sendTransaction(resps);
		for (ProposalResponse pres : resps) {
			status = pres.getChaincodeActionResponseStatus();
			txId = pres.getTransactionID();
		}

		return Integer.toString(status) + "Transaction ID: " +txId;
	}

	@Override
	public String queryAllCustomers() throws InvalidArgumentException, ProposalException {
		QueryByChaincodeRequest request = BlockChainHFClient.getInstance().getClient().newQueryProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID ccid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		request.setChaincodeID(ccid);
		request.setFcn("queryAllcusts");
		String args = null;
		if (args != null)
			request.setArgs(args);

		Collection<ProposalResponse> response = channel.queryByChaincode(request,
				BlockChainHFClient.getInstance().getAdminPeer());
		String stringResponse = null;
		for (ProposalResponse pres : response) {
			stringResponse = new String(pres.getChaincodeActionResponsePayload());
		}
		return stringResponse;
	}

	@Override
	public String updateCustApproval(String custId, String mess) throws ProposalException, InvalidArgumentException {
		TransactionProposalRequest req = BlockChainHFClient.getInstance().getClient().newTransactionProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID cid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		req.setChaincodeID(cid);
		req.setFcn("approveCust");
		req.setArgs(new String[] { custId, mess });
		Collection<ProposalResponse> resps = channel.sendTransactionProposal(req);

		channel.sendTransaction(resps);
		String stringResponse = null;
		for (ProposalResponse pres : resps) {
			stringResponse = pres.getStatus().name() + " Transaction ID: "+ pres.getTransactionID();
		}
		return stringResponse;
	}

	@Override
	public String queryDrugSpecific(String drugId) throws InvalidArgumentException, ProposalException {
		QueryByChaincodeRequest request = BlockChainHFClient.getInstance().getClient().newQueryProposalRequest();
		Channel channel = BlockChainHFClient.getInstance().getCh();
		ChaincodeID ccid = ChaincodeID.newBuilder().setName("drugtracker_chaincode").build();
		request.setChaincodeID(ccid);
		request.setFcn("queryDrugSpecific");
		request.setArgs(new String[] { drugId });

		Collection<ProposalResponse> response = channel.queryByChaincode(request);
		String stringResponse = null;
		for (ProposalResponse pres : response) {
			stringResponse = new String(pres.getChaincodeActionResponsePayload());
		}
		return "[" + stringResponse + "]";
	}

}
