/********************************************************************************
 ********************************************************************************    
 *	Class            : NBTYWSUtil
 *	Author		     : Acumen Solutions: Rahul Badal
 *	Version History  : 1.0
 *	Creation         : 03/22/13
 *	Description      : Data Structure for Parsed Product and Rank response received from Agileone
 *						
 ********************************************************************************
 ********************************************************************************/

public with sharing class ProductRank implements Comparable {
public NBTYproduct recProduct;
public Integer Rank;

public	class NBTYproduct
	{
		 public string Id;
		 public string name;
		 public string description;
		 public string imageURL;
		 public string productURL;
		 public string brand;
		 public string availability;
		 public string saleCondition;
		 public string price;
		 public string salePrice;
		 public string gtin;
		 public string mpn; 
	 
	 
	 public NBTYproduct()
	 {
		  this.availability = '';
		  this.brand = '' ;
		 this.description = '' ;
		 this.gtin = '' ;
		 this.Id = '' ;
		 this.imageURL = '' ;
		 this.mpn = '' ;
		 this.name = '' ;
		 this.price = '' ;
		 this.productURL = '' ;
		 this.saleCondition = '' ;
		 this.salePrice = '' ;
	 }
	 
	}
	
Public Integer compareTo(Object compareTo) {
	ProductRank compareToEmp = (ProductRank)compareTo;
	if (Rank == compareToEmp.Rank) return 0;
	if (Rank > compareToEmp.Rank) return 1;
    	return -1;        
 }	

}