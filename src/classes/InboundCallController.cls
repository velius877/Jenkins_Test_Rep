/* 
	InboundCallController
	DESCRIPTION
	------------------------------------------------------------------
	Author		  |   Date		|   Description
	------------------------------------------------------------------
	Gary Alfrey	 |   4/17/2013   |   Created

*/

public without sharing class InboundCallController {

/*-----------------------------------Start Variable Definitions---------------------------------------------------------------*/	
	public List<Account> acct {get;set;}
	public List<Task> task {get;set;}
	public List<Case> cse {get;set;}
	public List<Orders__c> orders {get;set;}
	/*----------------------------------------*/
	private List<Task> taskSearchList {get;set;}
	public List<Task> taskABList {get;set;}
	private List<Task> taskABList2 {get;set;}
	public List<Task> taskAOList {get;set;}
	private List<Task> taskAOList2 {get;set;}
	/*----------------------------------------*/
	private List<Account> acctSearchList {get;set;}
	public List<Account> acctAOList {get;set;}
	public List<Account> acctABList {get;set;}
	public List<Account> acctAOList2 {get;set;}
	public List<Account> acctABList2 {get;set;}
	public Integer pageNumberAAB {get;set;}
	public Integer totalMatchesAAB {get;set;}
	public Integer totalPageNumberAAB {get;set;}
	public Integer pageNumberAAO {get;set;}
	public Integer totalMatchesAAO {get;set;}
	public Integer totalPageNumberAAO {get;set;}
	/*----------------------------------------*/
	private List<Orders__c> orderSearchList {get;set;}
	public List<Orders__c> orderABList {get;set;}
	public List<Orders__c> orderAOList {get;set;}
	/*----------------------------------------*/
	private List<Case> caseSearchList {get;set;}
	public List<Case> caseABList {get;set;}
	public List<Case> caseAOList {get;set;}
	public List<Case> caseABList2 {get;set;}
	public List<Case> caseAOList2 {get;set;}
	public Integer pageNumberCAB {get;set;}
	public Integer totalMatchesCAB {get;set;}
	public Integer totalPageNumberCAB {get;set;}
	public Integer pageNumberCAO {get;set;}
	public Integer totalMatchesCAO {get;set;}
	public Integer totalPageNumberCAO {get;set;}
	/*----------------------------------------*/
	private String jsonString {get;set;}
	public String ANI {get;set;}
	private String brand {get;set;}
	private String perVar1 {get;set;}
	private String perVar2 {get;set;}
	private String perVar3 {get;set;}
	private String perVar4 {get;set;}
	private String userId {get;set;}
	public Boolean renderTable1 {get;set;}
	public Boolean renderTable2 {get;set;}
	public Boolean renderTable3 {get;set;}
	public Boolean renderTable4 {get;set;}
	public Boolean renderOutputPanel {get;set;}
	public Boolean renderAutoRedirect {get;set;}
	public Boolean stopAjax {get;set;}
	public String autoRedirectStr {get;set;}
	public String objectType {get;set;}
	public String devName {get;set;}
	public Boolean isCall {get;set;}
	private String dnis {get;set;}
	/*----------------------------------------*/
	private Integer pageSize {get;set;}
	public Integer pageNumberAB {get;set;}
	public Integer totalMatchesAB {get;set;}
	public Integer totalPageNumberAB {get;set;}
	public Integer pageNumberAO {get;set;}
	public Integer totalMatchesAO {get;set;}
	public Integer totalPageNumberAO {get;set;}
	/*----------------------------------------*/
	public Boolean showTAB {get;set;}
	public Boolean showAAB {get;set;}
	public Boolean showAAO {get;set;}
	public Boolean showTAO {get;set;}
	public Boolean showTAB2 {get;set;}
	public Boolean showAAB2 {get;set;}
	public Boolean showAAO2 {get;set;}
	public Boolean showTAO2 {get;set;}
	public Boolean showCAB {get;set;}
	public Boolean showCAO {get;set;}
	public Boolean showOAB {get;set;}
	public Boolean showOAO {get;set;}
	public Boolean accDNIS {get;set;}
	public Boolean showCAB2 {get;set;}
	public Boolean showCAO2 {get;set;}
	
/*-----------------------------------End Variable Definitions---------------------------------------------------------------*/
	
	public InboundCallController(){
		pageSize = 8;
		pageNumberAO = 0;
		totalPageNumberAO = 0;
		pageNumberAB = 0;
		totalPageNumberAB = 0;
		pageNumberAAO = 0;
		totalPageNumberAAO = 0;
		pageNumberAAB = 0;
		totalPageNumberAAB = 0;
		pageNumberCAB  = 0;
		totalPageNumberCAB = 0;
		pageNumberCAO = 0;
		totalPageNumberCAO = 0; 
		renderTable1 = false;
		renderTable2 = false;
		renderTable3 = false;
		renderTable4 = false;
		renderOutputPanel = false;
		renderAutoRedirect = false;
		accDNIS = false;
		stopAjax = true;
		jsonString = '';
		isCall = false;
	}
	
	public void Init(){
		//renderOutputPanel = true;
		
		userId = userinfo.getUserId();
		User user = [SELECT Id, Task_Record__c FROM User WHERE Id = :userId];
		if(user.Task_Record__c != null && user.Task_Record__c != ''){
			isCall = true;
		}
		if(isCall){
			renderOutputPanel = true;
			List<ACC_DNIS__c> accDNISList = ACC_DNIS__c.getall().values();
			Set<String> accDNISSet = new Set<String>();
			for(ACC_DNIS__c acc : accDNISList){
				accDNISSet.add(acc.Name);
			}
			task = [SELECT Id, Description, IVR_Case__c, IVR_Customer__c, IVR_Order__c, IVR_Status__c, CED__c, ANI__c FROM Task WHERE Id = :user.Task_Record__c];
			system.debug('----------------------------------------------------------task: ' + task);
			if (task!=null){
				jsonString = task[0].Description;
				parseJson(jsonString);
				if(!accDNISSet.contains(dnis)){
					SearchIVR();
				}else {
					accDNIS = true;
				} 
			}
		}
	}
	
/*-------------------------------------Section 0: Standard Controller Paging Methods--------------------------------------------*/
	
	
/*--------------------------------------------------Section 0: END--------------------------------------------------------------*/

/*------------------------Section 1: Locate Associated Case/Order/Customer From Incoming Call-----------------------------------*/
	public PageReference SearchIVR(){
		Boolean isCase = IVRCase();
		if(isCase){
			//redirect to case page
			renderAutoRedirect = true;
			autoRedirectStr = '/' + perVar3;
			objectType = 'Case';
			return null;
		}
		Boolean isOrder = IVROrder();
		if(isOrder){
			//redirect or order page
			renderAutoRedirect = true;
			autoRedirectStr = '/' + perVar2;
			objectType = 'Order';
			return null;
		}
		system.debug('perVar1~~~~~~~~~'+perVar1);
		if(perVar1!=null && perVar1!=''){
			if (perVar1.startsWith('001')){
			//redirect to customer page
			renderAutoRedirect = true;
			autoRedirectStr = '/' + perVar1;
			objectType = 'Customer';
			return null;
			}
			else {
				DoSearch();
				return null;
			}
		}else{
			DoSearch();
			return null;
		}
	}
	
	public Boolean IVRCase(){
		cse = [SELECT Id FROM Case WHERE Id = :perVar3];
		if(cse.size() > 0){
			return true;
		}else{
			return false;
		}
	}
	
	public Boolean IVROrder(){
		orders = [SELECT Id FROM Orders__c WHERE Id = :perVar2];
		if(orders.size() > 0){
			return true;
		}else{
			return false;
		}
	}
	
/*--------------------------------------------------Section 1: END-------------------------------------------------------------*/
	
/*------------------------Section 2: Custom Search Ustilizing ANI & Brand From Incoming Call-----------------------------------*/   
	public void DoSearch(){
		//parseJson(jsonString);
		String a = ANI;
		
		List<List<SObject>> searchList = [FIND :ANI IN PHONE FIELDS
		RETURNING Account (Id, RecordType.DeveloperName, RecordType.Name, Name, FirstName, LastName, 
							AS_400_Customer_Number__c, Customer_Number__c, ShippingStreet, ShippingCity, ShippingState, 
							ShippingPostalCode, PersonEmail, IsPersonAccount, Phone ORDER BY Name ),
			Task (Id, ANI__c, Brand__c, DNIS__c, CNX2__UniqueCallId__c, IVR_Case__c, IVR_Customer__c, Call_Driver__c, 
							IVR_Order__c, IVR_Status__c, Subject, WhoId, WhatId, Status, OwnerId, Queue_Name__c ORDER BY Subject ),
			Orders__c (Id, Name, Order_Id__c, Order_Date__c, CTI_Search__c, Customer__c, Order_Status__c, 
							Order_Total__c, Order_Sub_Total__c, Related_Cases__c, Customer__r.RecordType.DeveloperName LIMIT 8),
			Case ( Id, CTI_Search__c, AccountId, Case_Driver__c, Status, Reason, CaseNumber, Origin, Case_Resolution__c, 
							Brand__c, CreatedDate )];
		 
		acctSearchList = searchList[0];
		taskSearchList =  searchList[1];
		orderSearchList =  searchList[2];
		caseSearchList =  searchList[3];

		
		system.debug('----------------------------------------------------------acctSearchList Size: ' + acctSearchList.size());				 
		system.debug('----------------------------------------------------------taskSearchList Size: ' + taskSearchList.size());
		system.debug('----------------------------------------------------------caseSearchList Size: ' + caseSearchList.size());				 
		system.debug('----------------------------------------------------------orderSearchList Size: ' + orderSearchList.size());
		SortSearchLists();
	}
	
	public void SortSearchLists(){
		devName = '';
		String pickListBrand = '';
		system.debug('--------------------------------------------------------------perVar4~~~'+perVar4);
		system.debug('-------------------------------------------------NBTYUtils.getRtNameToBrandMappingMap()~~~'+NBTYUtils.getRtNameToBrandMappingMap());
		Customer_Rec_Type_Brand_Mapping__c rtbm = NBTYUtils.getRtNameToBrandMappingMap().get(perVar4);
		devName = rtbm.name;
		pickListBrand = rtbm.Picklist_Brand__c;
		
		
		acctAOList2 = new List<Account>();
		acctABList2 = new List<Account>();
		if(acctSearchList.size() > 0){
			for(Account a : acctSearchList){
				system.debug('-----------------------rectypeDevName: ' + a.RecordType.DeveloperName);
				system.debug('-----------------------devname: ' + devName);
				system.debug('-----------------------Brand: ' + brand);
				system.debug('-----------------------perVar4: ' + perVar4);
				if(a.RecordType.DeveloperName == devName){
					acctABList2.add(a);
				}else{
					acctAOList2.add(a);
				}
			}
			system.debug('-------------------------------AAOList: ' + acctAOList2);
			system.debug('-------------------------------AABList: ' + acctABList2);
			pageAcctAB();
			pageAcctAO();
			
		}
		caseABList2 = new List<Case>();
		caseAOList2 = new List<Case>();
		if(caseSearchList.size() > 0){
			for(Case c : caseSearchList){
				if(c.Brand__c == pickListBrand){
					caseABList2.add(c);
				}else{
					caseAOList2.add(c);
				}
			}
			pageCaseAB();
			pageCaseAO();
		}
		orderABList = new List<Orders__c>();
		orderAOList = new List<Orders__c>();
		if(orderSearchList.size() > 0){
			for(Orders__c ord : orderSearchList){
				if(ord.Customer__r.RecordType.DeveloperName == devName){
					orderABList.add(ord);
				}else{
					orderAOList.add(ord);
				}
			}
			if(orderABList.size() > 0){
				showOAB = true;
			}else{
				showOAB = false;
			}
			
			if(orderAOList.size() > 0){
				showOAO = true;
			}else{
				showOAO = false;
			}
		}
		
		taskAOList2 = new List<Task>();
		taskABList2 = new List<Task>();
		if(taskSearchList.size() > 0){
			for(Task t : taskSearchList){
				if(t.Brand__c == perVar4){
					taskABList2.add(t);
				}else{
					taskAOList2.add(t);
				}
			}
			pageTaskAB();
			pageTaskAO();
		}
	}
	
/*--------------------------------------------------Section 2: END-------------------------------------------------------------*/   
	
/*---------------------------------------------Section 3.1: Custom Pagination Account----------------------------------------------------*/
	public void pageAcctAB(){
		if (acctABList2!=null){
			totalPageNumberAAB = acctABList2.size()/pageSize;
			Integer mod = acctABList2.size() - (totalPageNumberAAB * pageSize);
			if(mod > 0){
				totalPageNumberAAB++;
			}
			transient Integer counter = 0;
			transient Integer min = 0;
			transient Integer max = 0;
			transient Integer remaining = 0;
			transient integer lSize = acctABList2.size();
			if(acctABList2.size() > 0){
				showAAB = true;
			}else{
				showAAB = false;
			}
			if(acctABList2.size() > 8){
				showAAB2 = true;
			}else{
				showAAB2 = false;
			}
			
			system.debug('----------------------------------------------------------------------------------1AB');
			if(totalPageNumberAAB > pageNumberAAB){
				min = pageNumberAAB * pageSize;
				max = acctABList2.size() - ((totalPageNumberAAB - 1) * pageSize);
				remaining = acctABList2.size() - ((pageNumberAAB) * pageSize);
			}
			system.debug('-----------------------------------------------------------------------------------2AB');
			system.debug('--------------------------PageSize: ' + pageSize);
			system.debug('--------------------------Min: ' + min);
			system.debug('--------------------------cmPageNumber: ' + pageNumberAAB);
			system.debug('--------------------------AB Accounts Display: ' + acctABList2.size());
			system.debug('--------------------------remaining: ' + remaining);
			acctABList = new List<Account>();
			if(remaining > pageSize){
				system.debug('--------------------------MaxAB1: ' + max);
				if(acctABList2.size() > 0){
					for(Integer i = 0; i <= pageSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						acctABList.add(acctABList2[min + i]);
					}
				}
			}else if(remaining <= pageSize){
				system.debug('--------------------------MaxAB2: ' + max);
				if(acctABList2.size() > 0){
					for(Integer i = 0; i <= lSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						acctABList.add(acctABList2[min + i]);
					}
				}
			}
			system.debug('-------------------------------------------------------------------------------------3AB');
			system.debug('--------------------------AB Account Display: ' + acctABList);
		}
	}
	
	public void firstAAB(){
		pageNumberAAB = 0;
		pageAcctAB(); 
	}
	
	public void nextAAB(){
		try{
			if(pageNumberAAB < totalPageNumberAAB - 1){
				pageNumberAAB++;
				pageAcctAB();
			}
		}catch(Exception e){
			System.debug(e);
		} 
	}
	
	public void previousAAB(){
		try{
			if(pageNumberAAB > 0){
				pageNumberAAB--;
			pageAcctAB();
		}
		}catch(Exception e){
			System.debug(e);
		}
	}
	
	public void lastAAB(){
		try{
			pageNumberAAB = totalPageNumberAAB - 1;
			pageAcctAB();
		}catch(Exception e){
			System.debug(e);
		}
	}
/************************************************************************************************************************************************/
	public void pageAcctAO(){
		if (acctAOList2 != null){
			totalPageNumberAAO = acctAOList2.size()/pageSize;
			Integer mod = acctAOList2.size() - (totalPageNumberAAO * pageSize);
			if(mod > 0){
				totalPageNumberAAO++;
			}
			transient Integer counter = 0;
			transient Integer min = 0;
			transient Integer max = 0;
			transient Integer remaining = 0;
			transient integer lSize = acctAOList2.size();
			if(acctAOList2.size() > 0){
				showAAO = true;
			}else{
				showAAO = false;
			}
			if(acctABList2.size() > 8){
				showAAO2 = true;
			}else{
				showAAO2 = false;
			}
			
			system.debug('----------------------------------------------------------------------------------1AO');
			if(totalPageNumberAAO > pageNumberAAO){
				min = pageNumberAAO * pageSize;
				max = acctAOList2.size() - ((totalPageNumberAAO - 1) * pageSize);
				remaining = acctAOList2.size() - ((pageNumberAAO) * pageSize);
			}
			system.debug('-----------------------------------------------------------------------------------2AO');
			system.debug('--------------------------PageSize: ' + pageSize);
			system.debug('--------------------------Min: ' + min);
			system.debug('--------------------------cmPageNumber: ' + pageNumberAAO);
			system.debug('--------------------------AO Account Display: ' + acctAOList2.size());
			system.debug('--------------------------remaining: ' + remaining);
			acctAOList = new List<Account>();
			if(remaining > pageSize){
				system.debug('--------------------------MaxAO1: ' + max);
				if(acctAOList2.size() > 0){
					for(Integer i = 0; i <= pageSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						acctAOList.add(acctAOList2[min + i]);
					}
				}
				
			}else if(remaining <= pageSize){
				system.debug('--------------------------MaxAO2: ' + max);
				if(acctAOList2.size() > 0){
					for(Integer i = 0; i <= lSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						acctAOList.add(acctAOList2[min + i]);
					}
				}
				
			}
			system.debug('-------------------------------------------------------------------------------------3AO');
			system.debug('--------------------------AO Account Display: ' + acctAOList);
		}
	}
	
	public void firstAAO(){
		pageNumberAAO = 0;
		pageAcctAO(); 
	}
	
	public void nextAAO(){
		try{
			if(pageNumberAAO < totalPageNumberAAO - 1){
				pageNumberAAO++;
				pageAcctAO();
			}
		}catch(Exception e){
			System.debug(e);
		} 
	}
	
	public void previousAAO(){
		try{
			if(pageNumberAAO > 0){
				pageNumberAAO--;
			pageAcctAO();
		}
		}catch(Exception e){
			System.debug(e);
		}
	}
	
	public void lastAAO(){
		try{
			pageNumberAAO = totalPageNumberAAO - 1;
			pageAcctAO();
		}catch(Exception e){
			System.debug(e);
		}
	}
/*----------------------------------------------------Section 3.1: END---------------------------------------------------------------*/	
	
/*---------------------------------------------Section 3.2: Custom Pagination Task----------------------------------------------------*/	
	public void pageTaskAB(){
		if (taskABList2!=null){
			totalPageNumberAB = taskABList2.size()/pageSize;
			Integer mod = taskABList2.size() - (totalPageNumberAB * pageSize);
			if(mod > 0){
				totalPageNumberAB++;
			}
			transient Integer counter = 0;
			transient Integer min = 0;
			transient Integer max = 0;
			transient Integer remaining = 0;
			transient integer lSize = taskABList2.size();
			if(taskABList2.size() > 0){
				showTAB = true;
			}else{
				showTAB = false;
			}
			if(taskABList2.size() > 8){
				showTAB2 = true;
			}else{
				showTAB2 = false;
			}
			system.debug('----------------------------------------------------------------------------------1TAB');
			if(totalPageNumberAB > pageNumberAB){
				min = pageNumberAB * pageSize;
				max = taskABList2.size() - ((totalPageNumberAB - 1) * pageSize);
				remaining = taskABList2.size() - ((pageNumberAB) * pageSize);
			}
			system.debug('-----------------------------------------------------------------------------------2TAB');
			system.debug('--------------------------PageSize: ' + pageSize);
			system.debug('--------------------------Min: ' + min);
			system.debug('--------------------------cmPageNumber: ' + pageNumberAB);
			system.debug('--------------------------AB Task Display: ' + taskABList2.size());
			system.debug('--------------------------remaining: ' + remaining);
			taskABList = new List<Task>();
			if(remaining > pageSize){
				system.debug('--------------------------Max1111: ' + max);
				if(taskABList2.size() > 0){
					for(Integer i = 0; i <= pageSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						taskABList.add(taskABList2[min + i]);
					}
				}
			}else if(remaining <= pageSize){
				system.debug('--------------------------Max222222: ' + max);
				if(taskABList2.size() > 0){
					for(Integer i = 0; i <= lSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						taskABList.add(taskABList2[min + i]);
					}
				}
			}
			system.debug('-------------------------------------------------------------------------------------3TAB');
			system.debug('--------------------------AB Task Display: ' + taskABList);
		}
	}
	
	public void ABFirst(){
		pageNumberAB = 0;
		pageTaskAB(); 
	}
	
	public void ABNext(){
		try{
			if(pageNumberAB < totalPageNumberAB - 1){
				pageNumberAB++;
				pageTaskAB();
			}
		}catch(Exception e){
			System.debug(e);
		} 
	}
	
	public void ABPrevious(){
		try{
			if(pageNumberAB > 0){
				pageNumberAB--;
			pageTaskAB();
		}
		}catch(Exception e){
			System.debug(e);
		}
	}
	
	public void ABLast(){
		try{
			pageNumberAB = totalPageNumberAB - 1;
			pageTaskAB();
		}catch(Exception e){
			System.debug(e);
		}
	}

	public void pageTaskAO(){
		if (taskAOList2!=null){
			totalPageNumberAO = taskAOList2.size()/pageSize;
			Integer mod = taskAOList2.size() - (totalPageNumberAO * pageSize);
			if(mod > 0){
				totalPageNumberAO++;
			}
			transient Integer counter = 0;
			transient Integer min = 0;
			transient Integer max = 0;
			transient Integer remaining = 0;
			transient integer lSize = taskAOList2.size();
			if(taskAOList2.size() > 0){
				showTAO = true;
			}else{
				showTAO = false;
			}
			if(taskAOList2.size() > 8){
				showTAO2 = true;
			}else{
				showTAO2 = false;
			}
			system.debug('----------------------------------------------------------------------------------1TAO');
			if(totalPageNumberAO > pageNumberAO){
				min = pageNumberAO * pageSize;
				max = taskAOList2.size() - ((totalPageNumberAO - 1) * pageSize);
				remaining = taskAOList2.size() - ((pageNumberAO) * pageSize);
			}
			system.debug('-----------------------------------------------------------------------------------2TAO');
			system.debug('--------------------------PageSize: ' + pageSize);
			system.debug('--------------------------Min: ' + min);
			system.debug('--------------------------pageNumberAO: ' + pageNumberAO);
			system.debug('--------------------------AO Task Display: ' + taskAOList2.size());
			system.debug('--------------------------remaining: ' + remaining);
			system.debug('--------------------------lSize: ' + lSize);
			taskAOList = new List<Task>();
			if(remaining > pageSize){
				system.debug('--------------------------Max1111: ' + max);
				if(taskAOList2.size() > 0){
					for(Integer i = 0; i <= pageSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						taskAOList.add(taskAOList2[min + i]);
					}
				}
			}else if(remaining < pageSize){
				system.debug('--------------------------Max222222: ' + max);
				if(taskAOList2.size() > 0){
					for(Integer i = 0; i <= lSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						taskAOList.add(taskAOList2[min + i]);
					}
				}
			}
			system.debug('-------------------------------------------------------------------------------------3TAO');
			system.debug('--------------------------AO Task Display: ' + taskAOList);
		}
	}
	
	public void AOFirst(){
		pageNumberAO = 0;
		pageTaskAO(); 
	}
	
	public void AONext(){
		try{
			if(pageNumberAO < totalPageNumberAO - 1){
				pageNumberAO++;
				pageTaskAO();
			}
		}catch(Exception e){
			System.debug(e);
		} 
	}
	
	public void AOPrevious(){
		try{
			if(pageNumberAO > 0){
				pageNumberAO--;
			pageTaskAO();
		}
		}catch(Exception e){
			System.debug(e);
		}
	}
	
	public void AOLast(){
		try{
			pageNumberAO = totalPageNumberAO - 1;
			pageTaskAO();
		}catch(Exception e){
			System.debug(e);
		}
	}
	
/*----------------------------------------------------Section 3.2: END---------------------------------------------------------------*/
	
/*---------------------------------------------Section 3.3: Custom Pagination Case----------------------------------------------------*/
	public void pageCaseAB(){
		if (caseABList2!=null){
			totalPageNumberCAB = caseABList2.size()/pageSize;
			Integer mod = caseABList2.size() - (totalPageNumberCAB * pageSize);
			if(mod > 0){
				totalPageNumberCAB++;
			}
			transient Integer counter = 0;
			transient Integer min = 0;
			transient Integer max = 0;
			transient Integer remaining = 0;
			transient integer lSize = caseABList2.size();
			if(caseABList2.size() > 0){
				showCAB = true;
			}else{
				showCAB = false;
			}
			if(caseABList2.size() > 8){
				showCAB2 = true;
			}else{
				showCAB2 = false;
			}
			
			system.debug('----------------------------------------------------------------------------------1CAB');
			if(totalPageNumberCAB > pageNumberCAB){
				min = pageNumberCAB * pageSize;
				max = caseABList2.size() - ((totalPageNumberCAB - 1) * pageSize);
				remaining = caseABList2.size() - ((pageNumberCAB) * pageSize);
			}
			system.debug('-----------------------------------------------------------------------------------2CAB');
			system.debug('--------------------------PageSize: ' + pageSize);
			system.debug('--------------------------Min: ' + min);
			system.debug('--------------------------cmPageNumber: ' + pageNumberCAB);
			system.debug('--------------------------AB Case Display: ' + caseABList2.size());
			system.debug('--------------------------remaining: ' + remaining);
			caseABList = new List<Case>();
			if(remaining > pageSize){
				system.debug('--------------------------Max1111: ' + max);
				if(caseABList2.size() > 0){
					for(Integer i = 0; i <= pageSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						caseABList.add(caseABList2[min + i]);
					}
				}
			}else if(remaining <= pageSize){
				system.debug('--------------------------Max222222: ' + max);
				if(caseABList2.size() > 0){
					for(Integer i = 0; i <= lSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						caseABList.add(caseABList2[min + i]);
					}
				}
			}
			system.debug('-------------------------------------------------------------------------------------3CAB');
			system.debug('--------------------------AB Case Display: ' + acctABList);
		}
	}
	
	public void firstCAB(){
		pageNumberCAB = 0;
		pageCaseAB(); 
	}
	
	public void nextCAB(){
		try{
			if(pageNumberCAB < totalPageNumberCAB - 1){
				pageNumberCAB++;
				pageCaseAB();
			}
		}catch(Exception e){
			System.debug(e);
		} 
	}
	
	public void previousCAB(){
		try{
			if(pageNumberCAB > 0){
				pageNumberCAB--;
			pageCaseAB();
		}
		}catch(Exception e){
			System.debug(e);
		}
	}
	
	public void lastCAB(){
		try{
			pageNumberCAB = totalPageNumberCAB - 1;
			pageCaseAB();
		}catch(Exception e){
			System.debug(e);
		}
	}
/************************************************************************************************************************************************/
	public void pageCaseAO(){
		if (caseAOList2!=null){
			totalPageNumberCAO = caseAOList2.size()/pageSize;
			Integer mod = caseAOList2.size() - (totalPageNumberCAO * pageSize);
			if(mod > 0){
				totalPageNumberCAO++;
			}
			transient Integer counter = 0;
			transient Integer min = 0;
			transient Integer max = 0;
			transient Integer remaining = 0;
			transient integer lSize = caseAOList2.size();
			if(caseAOList2.size() > 0){
				showCAO = true;
			}else{
				showCAO = false;
			}
			if(caseAOList2.size() > 8){
				showCAO2 = true;
			}else{
				showCAO2 = false;
			}
			
			system.debug('----------------------------------------------------------------------------------1CAO');
			if(totalPageNumberCAO > pageNumberCAO){
				min = pageNumberCAO * pageSize;
				max = caseAOList2.size() - ((totalPageNumberCAO - 1) * pageSize);
				remaining = caseAOList2.size() - ((pageNumberCAO) * pageSize);
			}
			system.debug('-----------------------------------------------------------------------------------2CAO');
			system.debug('--------------------------PageSize: ' + pageSize);
			system.debug('--------------------------Min: ' + min);
			system.debug('--------------------------cmPageNumber: ' + pageNumberCAO);
			system.debug('--------------------------AB Case Display: ' + caseAOList2.size());
			system.debug('--------------------------remaining: ' + remaining);
			caseAOList = new List<Case>();
			if(remaining > pageSize){
				system.debug('--------------------------Max1111: ' + max);
				if(caseAOList2.size() > 0){
					for(Integer i = 0; i <= pageSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						caseAOList.add(caseAOList2[min + i]);
					}
				}
			}else if(remaining <= pageSize){
				system.debug('--------------------------Max222222: ' + max);
				if(caseAOList2.size() > 0){
					for(Integer i = 0; i <= lSize - 1; i++){
						system.debug('--------------------------i: ' + i);
						caseAOList.add(caseAOList2[min + i]);
					}
				}
			}
			system.debug('-------------------------------------------------------------------------------------3CAO');
			system.debug('--------------------------AB Case Display: ' + caseAOList2);
		}
	}
	
	public void firstCAO(){
		pageNumberCAO = 0;
		pageCaseAO(); 
	}
	
	public void nextCAO(){
		try{
			if(pageNumberCAO < totalPageNumberCAO - 1){
				pageNumberCAO++;
				pageCaseAO();
			}
		}catch(Exception e){
			System.debug(e);
		} 
	}
	
	public void previousCAO(){
		try{
			if(pageNumberCAO > 0){
				pageNumberCAO--;
			pageCaseAO();
		}
		}catch(Exception e){
			System.debug(e);
		}
	}
	
	public void lastCAO(){
		try{
			pageNumberCAO = totalPageNumberCAO - 1;
			pageCaseAO();
		}catch(Exception e){
			System.debug(e);
		}
	}
/*----------------------------------------------------Section 3.1: END---------------------------------------------------------------*/


	
	public void parseJson(String jsonStr){
		JSONParser parser = JSON.createParser(jsonStr);
		while (parser.nextToken() != null) {
			system.debug('------------------------------------getCurrentToken: ' + parser.getCurrentToken());
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
				String fieldName = parser.getText();
				system.debug('------------------------------------fieldName: ' + fieldName);
				// Get the value.
				parser.nextToken();
				system.debug('------------------------------------getText: ' + parser.getText());
				if(fieldName == 'Service'){
					brand = parser.getText();
				}else if(fieldName == 'Sender'){
					ANI = parser.getText();
				}else if(fieldName == 'PerVar1'){
					perVar1 = parser.getText();
				}else if(fieldName == 'PerVar2'){
					perVar2 = parser.getText();
				}else if(fieldName == 'PerVar3'){
					perVar3 = parser.getText();
				}else if(fieldName == 'PerVar4'){
					perVar4 = parser.getText();
				}else if(fieldName == 'DNIS'){
					dnis = parser.getText();
				}
			}
		}
		system.debug('------------------------------------perVar4: ' + perVar4);
	}
	 
	
	
}