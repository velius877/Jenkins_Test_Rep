/* 
	CiscoIVR_ComplexTypes
	DESCRIPTION
	------------------------------------------------------------------
	Author		|	Date		|	Description
	------------------------------------------------------------------
	Gary Alfrey |	4/29/2013	|	Created

*/

global class CiscoIVR_ComplexTypes {
	
	global class Cisco_IVR {
		webservice String searchType;
		webservice String brand;
		webservice String CED;
	}
	
	global class Response {
		webservice Boolean isValid;
		webservice String status;
		webservice String objectId;
	}
	
}