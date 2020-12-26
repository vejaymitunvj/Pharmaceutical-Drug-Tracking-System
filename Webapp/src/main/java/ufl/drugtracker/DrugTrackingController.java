package ufl.drugtracker;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.hyperledger.fabric.sdk.exception.CryptoException;
import org.hyperledger.fabric.sdk.exception.InvalidArgumentException;
import org.hyperledger.fabric.sdk.exception.ProposalException;
import org.hyperledger.fabric.sdk.exception.TransactionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.support.SessionStatus;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import ufl.drugtracker.service.drugTrackService;
import ufl.drugtracker.setup.BlockChainHFClient;

/* DrugTracking Controller Class:
 * This creates the web app context with the required certificates and authentication material
 * Constitutes the business logic of the entire application
 * Any call from the user interface through Ajax hits the controller server
 * Calls implementation specific to Fabric Java SDK to access network
 */

@Controller
public class DrugTrackingController {

	@Autowired
	drugTrackService drugTrackingService;

	@EventListener(ContextRefreshedEvent.class)
	public void contextRefreshedEvent() throws CryptoException, InvalidArgumentException, IllegalAccessException,
			InstantiationException, ClassNotFoundException, NoSuchMethodException, InvocationTargetException,
			TransactionException, ProposalException {
		// Sets up the crypto material for the client as a whole
		// Gets the channel information constituting all the network components
		BlockChainHFClient.getInstance().setupCrypto();
		BlockChainHFClient.getInstance().getChannel();
	}

	
	@RequestMapping(value = "/")
	public ModelAndView login(HttpSession session) throws CryptoException, InvalidArgumentException,
			IllegalAccessException, InstantiationException, ClassNotFoundException, NoSuchMethodException,
			InvocationTargetException, TransactionException, ProposalException {
		ModelAndView l_objLoginPage = new ModelAndView("/login");
		session.removeAttribute("username");
		session.invalidate();
		return l_objLoginPage;
	}

	
	@RequestMapping("/manufacturer")
	public ModelAndView manufacturer(HttpSession sess) throws Exception {
		ModelAndView l_objOrgPage = new ModelAndView("/manufacturer");
		Object uname = (String) sess.getAttribute("username");
		if (uname.equals(null) || !uname.equals("manufacturer")) {
			sess.removeAttribute("username");
			sess.invalidate();
			ModelAndView l_objLoginPage = new ModelAndView("/login");
			return l_objLoginPage;
		} else {
			int noOfBlocks = drugTrackingService.getNumberOfBlocks() - 1;
			l_objOrgPage.addObject("noOfBlocks", noOfBlocks);
			return l_objOrgPage;
		}
	}

	
	@RequestMapping("/govt")
	public ModelAndView retail(HttpSession sess) throws Exception {
		ModelAndView l_objOrgPage = new ModelAndView("/govt");
		Object uname = (String) sess.getAttribute("username");
		if (uname.equals(null) || !uname.equals("govt")) {
			sess.removeAttribute("username");
			sess.invalidate();
			ModelAndView l_objLoginPage = new ModelAndView("/login");
			return l_objLoginPage;
		} else {
			int noOfBlocks = drugTrackingService.getNumberOfBlocks() - 1;
			l_objOrgPage.addObject("noOfBlocks", noOfBlocks);
			return l_objOrgPage;
		}
	}

	
	@RequestMapping("/fda")
	public ModelAndView police(HttpSession sess) throws Exception {
		ModelAndView l_objOrgPage = new ModelAndView("/fda");
		Object uname = (String) sess.getAttribute("username");
		if (uname.equals(null) || !uname.equals("fda")) {
			sess.removeAttribute("username");
			sess.invalidate();
			ModelAndView l_objLoginPage = new ModelAndView("/login");
			return l_objLoginPage;
		} else {
			int noOfBlocks = drugTrackingService.getNumberOfBlocks() - 1;
			l_objOrgPage.addObject("noOfBlocks", noOfBlocks);
			return l_objOrgPage;
		}
	}

	
	@RequestMapping("/hospital")
	public ModelAndView hospPharma(HttpSession sess) throws Exception {
		ModelAndView l_objOrgPage = new ModelAndView("/hospital");
		Object uname = (String) sess.getAttribute("username");
		if (uname.equals(null) || !uname.equals("hosp")) {
			sess.removeAttribute("username");
			sess.invalidate();
			ModelAndView l_objLoginPage = new ModelAndView("/login");
			return l_objLoginPage;
		} else {
			int noOfBlocks = drugTrackingService.getNumberOfBlocks() - 1;
			l_objOrgPage.addObject("noOfBlocks", noOfBlocks);
			return l_objOrgPage;
		}
	}

	
	@RequestMapping("/customer")
	public ModelAndView custPatient(HttpSession sess) throws Exception {
		ModelAndView l_objOrgPage = new ModelAndView("/customer");
		Object uname = (String) sess.getAttribute("username");
		if (uname.equals(null) || !uname.equals("cust")) {
			sess.removeAttribute("username");
			sess.invalidate();
			ModelAndView l_objLoginPage = new ModelAndView("/login");
			return l_objLoginPage;
		} else {
			int noOfBlocks = drugTrackingService.getNumberOfBlocks() - 1;
			l_objOrgPage.addObject("noOfBlocks", noOfBlocks);
			return l_objOrgPage;
		}
	}

	
	@RequestMapping(value = "/medic")
	public ModelAndView docMedic(HttpSession sess) throws Exception {
		ModelAndView l_objOrgPage = new ModelAndView("/medic");

		Object uname = (String) sess.getAttribute("username");

		if (uname.equals(null) || !uname.equals("medic")) {
			sess.removeAttribute("username");
			sess.invalidate();
			ModelAndView l_objLoginPage = new ModelAndView("/login");
			return l_objLoginPage;
		} else {
			int noOfBlocks = drugTrackingService.getNumberOfBlocks() - 1;
			l_objOrgPage.addObject("noOfBlocks", noOfBlocks);
			return l_objOrgPage;
		}
	}

	@RequestMapping(value = "/validate", consumes = "multipart/form-data")
	public String validateLogin(@RequestParam String p_sUsername, @RequestParam String p_sPassword,
			@RequestParam MultipartFile file, HttpSession session) throws IllegalStateException, IOException,
			CryptoException, InvalidArgumentException, IllegalAccessException, InstantiationException,
			ClassNotFoundException, NoSuchMethodException, InvocationTargetException {

		File tmp = File.createTempFile("cert", ".pem");
		file.transferTo(tmp);
		if (drugTrackingService.validateLogin(p_sUsername, p_sPassword)) {

			if (p_sUsername.equals("govt")) {
				BlockChainHFClient.getInstance().setupCryptoForPeer(tmp, "usgovt");
				session.setAttribute("username", p_sUsername);
				return "redirect:/govt";
			}
			if (p_sUsername.equals("manufacturer")) {
				BlockChainHFClient.getInstance().setupCryptoForPeer(tmp, "manufacturer");
				session.setAttribute("username", p_sUsername);
				return "redirect:/manufacturer";
			}
			if (p_sUsername.equals("fda")) {
				BlockChainHFClient.getInstance().setupCryptoForPeer(tmp, "fda");
				session.setAttribute("username", p_sUsername);
				return "redirect:/fda";
			}
			if (p_sUsername.equals("hosp")) {
				BlockChainHFClient.getInstance().setupCryptoForPeer(tmp, "hospitalPharma");
				session.setAttribute("username", p_sUsername);
				return "redirect:/hospital";
			}
			if (p_sUsername.equals("cust")) {
				BlockChainHFClient.getInstance().setupCryptoForPeer(tmp, "custPatient");
				session.setAttribute("username", p_sUsername);
				return "redirect:/customer";
			}
			if (p_sUsername.equals("medic")) {
				BlockChainHFClient.getInstance().setupCryptoForPeer(tmp, "medic");
				session.setAttribute("username", p_sUsername);
				return "redirect:/medic";
			}
			return "redirect:/";

		}
		return "redirect:/";
	}

	@RequestMapping(value = "/logout", method = RequestMethod.GET)
	public String logout(HttpSession session, SessionStatus status) {
		session.setAttribute("username", null);
		status.setComplete();
		session.invalidate();
		return "redirect:/";
	}

	@RequestMapping(value = "/blocksModal")
	public @ResponseBody String getBlockInfoStateBasic(@RequestParam int blockno)
			throws InvalidKeyException, NoSuchAlgorithmException, InvalidArgumentException, ProposalException,
			IOException, CryptoException, IllegalAccessException, InstantiationException, ClassNotFoundException,
			NoSuchMethodException, InvocationTargetException, TransactionException {
		String Binfo = drugTrackingService.getBlockBasicInfoAlert(blockno);
		return Binfo;
	}

	@RequestMapping(value = "/createDrug")
	public @ResponseBody String createDrug(@RequestParam String id, @RequestParam String name,
			@RequestParam String type, @RequestParam String num, @RequestParam String chemName,
			@RequestParam String nat, @RequestParam String sup, @RequestParam String ulab, @RequestParam String se,
			@RequestParam String strg) throws Exception {

		String status = drugTrackingService.createDrug(id, name, type, num, chemName, nat, sup, ulab, se, strg);
		return status;

	}

	@RequestMapping(value = "/createCust")
	public @ResponseBody String createCust(@RequestParam String id, @RequestParam String fname,
			@RequestParam String lname, @RequestParam String age, @RequestParam String email, @RequestParam String addr,
			@RequestParam String condition, @RequestParam String drug) throws Exception {

		String status = drugTrackingService.createCust(id, fname, lname, age, email, addr, condition, drug);
		return status;

	}

	@RequestMapping(value = "/queryDrugs")
	public @ResponseBody String queryDrugs() throws Exception {

		String drugsData = drugTrackingService.queryAllDrugs();
		return drugsData;

	}

	@RequestMapping(value = "/queryDrugSpecific")
	public @ResponseBody String queryDrugSpecific(@RequestParam String drugId) throws Exception {

		String drugsData = drugTrackingService.queryDrugSpecific(drugId);
		return drugsData;

	}

	@RequestMapping(value = "/queryCustDetails")
	public @ResponseBody String queryCustDetails() throws Exception {

		String custData = drugTrackingService.queryAllCustomers();
		return custData;

	}

	@RequestMapping(value = "/queryApprovedDrugs")
	public @ResponseBody String queryApprovedDrugs() throws Exception {

		String drugsData = drugTrackingService.queryApprovedDrugs();
		return drugsData;

	}

	@RequestMapping(value = "/blocks/{blockno}")
	public @ResponseBody ModelAndView getBlockInfo(@PathVariable("blockno") int blockno) throws InvalidKeyException,
			NoSuchAlgorithmException, InvalidArgumentException, ProposalException, IOException {

		ModelAndView l_objBlockInfo = new ModelAndView("/TxInfo");
		List<String> Binfo = drugTrackingService.getBlockBasicInfo(blockno);

		l_objBlockInfo.addObject("bn", blockno);
		l_objBlockInfo.addObject("dataHash", Binfo.get(0));
		l_objBlockInfo.addObject("prevHash", Binfo.get(1));
		l_objBlockInfo.addObject("channelId", Binfo.get(2));
		l_objBlockInfo.addObject("txid", Binfo.get(3));
		l_objBlockInfo.addObject("txCount", Binfo.get(4));

		return l_objBlockInfo;
	}

	@RequestMapping(value = "/blocksNew")
	public @ResponseBody List<String> getBlockInfoNew(@RequestParam int blockno) throws InvalidKeyException,
			NoSuchAlgorithmException, InvalidArgumentException, ProposalException, IOException {
		List<String> Binfo = drugTrackingService.getBlockBasicInfo(blockno);

		return Binfo;
	}


	@RequestMapping(value = "/txInfo")
	public @ResponseBody List<String> getTxInfoModal(@RequestParam int blockno) throws InvalidKeyException,
			NoSuchAlgorithmException, InvalidArgumentException, ProposalException, IOException {

		List<String> Binfo = drugTrackingService.getTxInfoByNumber(blockno);

		return Binfo;
	}

	@RequestMapping(value = "/updateDrug")
	public @ResponseBody String updateDrug(@RequestParam String drugId, @RequestParam String mess)
			throws InvalidKeyException, NoSuchAlgorithmException, InvalidArgumentException, ProposalException,
			IOException {
		String Binfo = drugTrackingService.updateDrug(drugId, mess);
		return Binfo;
	}

	@RequestMapping(value = "/updateDrugGovt")
	public @ResponseBody String updateDrugGovt(@RequestParam String drugId, @RequestParam String mess)
			throws InvalidKeyException, NoSuchAlgorithmException, InvalidArgumentException, ProposalException,
			IOException {
		String Binfo = drugTrackingService.updateDrugGovt(drugId, mess);

		return Binfo;
	}

	@RequestMapping(value = "/updateCustApproval")
	public @ResponseBody String updateCustApproval(@RequestParam String custId, @RequestParam String mess)
			throws InvalidKeyException, NoSuchAlgorithmException, InvalidArgumentException, ProposalException,
			IOException {
		String Binfo = drugTrackingService.updateCustApproval(custId, mess);

		return Binfo;
	}

}
