<!-----------------------------------------------------------------------
Author      : Glyn Jackson                                               
Date        : June 15, 2009                                              
Description :  This is just an example of how you can use the SagePay.cfc 
within your own handlers. This handler is an example (cut and paste) 
of something I have used a few times. You may find this handler is not 
for you, do with it as you will.
------------------------------------------------------------------------>
<cfcomponent name="examplehandler" extends="coldbox.system.eventhandler" output="false">
	<!--- Event Caching Suffix: It will be appended to every event cached key. This can be a locale, dynamic, etc. --->
	<cfset this.EVENT_CACHE_SUFFIX = "">
	<!--- Pre Handler Execute only if action in this list --->
	<cfset this.PREHANDLER_ONLY = "">
	<!--- Pre Handler Do not execute if action in this except list --->
	<cfset this.PREHANDLER_EXCEPT = "">
	<!--- Post Handler Execute only if action in this list --->
	<cfset this.POSTHANDLER_ONLY = "">
	<!--- Post Handler Do not execute if action in this except list --->
	<cfset this.POSTHANDLER_EXCEPT = "">
<!------------------------------------------- CONSTRUCTOR ------------------------------------------>
	<!--- This init is mandatory, including the super.init(). ---> 
  <cffunction name="init" access="public" returntype="examplehandler" output="false">
    <cfargument name="controller" type="any">
    <cfset super.init(arguments.controller)>
    <!--- Any constructor code here --->
    <cfreturn this>
  </cffunction>
  <!------------------------------------------- PUBLIC EVENTS ------------------------------------------>      
   <!--- SagePay CheckOut Process Start Page -
    This function would be called to process the actual payment it comes after the check page. --->
  <cffunction name="sagePayProcessPage" access="public" returntype="void" output="false">
    <cfargument name="Event" type="any">
    <cfscript>
     var rc = event.getCollection();// RC reference
	 SagePayPlugin = getPlugin(plugin="SagePay",customPlugin=true,newInstance=true); //create the sagepay cfc plugin
     
       //SagePay gateway make the CFHTTP call, you will need all the form posts from the check
	   response = SagePayPlugin.makeCall(
							VendorTxCode = #SESSION.protx.TxCode#, //your transaction code **This is not optional and needs to be unique, this is very important! It will also need to be set into a session as when using 3D Secure we need to get it again to match the transaction up!  
							vendor = "newebialimited",//
							VPSProtocol = "2.23",
							referrerID = "", //optional
							amount=rc.Amount,//transaction account
							CardHolder=rc.cardHolder,//customer name and name on card
							CardNumber=cardNumber,//card number
							StartDate=rc.startDate1&rc.startDate2,//card start date
							ExpiryDate=rc.expiryDate1&rc.expiryDate2,//card expiry date
							DeliveryAddress=rc.billaddress1,//DeliveryAddress same as billing address
							CardType=rc.cardtype,//type of card being used
							BillingPostCode=rc.billPostCode,//card post code
							DeliveryPostCode=rc.billPostCode,//DeliveryAddress same as billing address
							CustomerName=rc.cardHolder,//card holders name
							CV2=rc.CV2,//security code
							billfirstName=rc.fname,//billing first name
							billlastName=rc.lname,//billing last name
							BillingAddress1=rc.billaddress1,//billing address
							billingcity=rc.billcity//billing city
							);
	  
	  
if (response.status neq "INVALID") {
//------------------------------------------------------------------------------------------------
//Do your database stores here, this is a good place to setup the order, I normally insert the order here and give it a status as authorisation pending
//------------------------------------------------------------------------------------------------
 }

	  //if responce back was ok do DB stores and send customer to thank you page 
	  if (response.status is "OK" OR response.status IS "ATTEMPTONLY") {
		 	 	 
      //update order
	  structclear(session['cartItem']);//***very important*** we need to clear the cart session so this order can not be processed again	 
		 getPlugin("messagebox").setMessage("info","Order successfully, receipt below.");//<---need message box plugin 
		 setNextEvent("secure.checkoutComplete");//all done take customer to payment complete page
		
	  }
	  
	  //responce back was that this card is in 3D secure
	  else if (response.status IS "3DAUTH"){
		  getPlugin("messagebox").setMessage("warning","You are enrolled in the 'Verified by Visa' or 'MasterCard SecureCode' service. Please enter your details below."); 
		 rc.responseSettings = StructNew();
		 rc.responseSettings  = response;
         Event.setView("3dsecure");	//show 3D Secure view
		 
	  }
	  //responce was none of above
	  else {
		  getPlugin("messagebox").setMessage("error",Response.Status&"<br />"&Response.StatusDetail&" To try again  <a href='#getSetting('sesBaseURL')#/secure/sagePayTryAgin.cfm'>click here</a>"); 
		 
		 //------------------------------------------------------------------------------------------------
		 //update the database here to show faild status you can use the responce above and store that also
		 //------------------------------------------------------------------------------------------------
          Event.setView("checkoutPaymentError");//show payment error view	
	  }
     </cfscript>
  </cffunction>     
<!---Deals with the 3D Secure Call Back--->
<cffunction name="sagePay3DcallBack" access="public" returntype="void" output="false" hint="deals with the reply for 3D secure">
<cfargument name="Event" type="any">
<cfscript>
      var rc = event.getCollection();// RC reference
	  var newresponse = "";
	  
  SagePayPlugin = getPlugin(plugin="SagePay",customPlugin=true,newInstance=true);
  newresponse = SagePayPlugin.DSecureCallBack(MD=rc.md,
											PARes=rc.PARes
											);
 
   if (newresponse.status is "OK" OR newresponse.status IS "ATTEMPTONLY") {
	    //------------------------------------------------------------------------------------------------
	    // do your database store here update status  
	   //------------------------------------------------------------------------------------------------
		 structclear(session['cartItem']);//***very important*** we need to clear the cart session so this order can not be done again	
		 getPlugin("messagebox").setMessage("info","Order successfully complete <a href='#getSetting('sesBaseURL')#/secure/checkoutComplete.cfm' target='_parent'>click here</a> to view receipt</p>"); 
		 setNextEvent("secure.checkoutComplete3DSecure");//all done take customer to payment complete page
		
	  }
	  else {
	    //------------------------------------------------------------------------------------------------
	    // do your database store here update status  
	   //------------------------------------------------------------------------------------------------
		  getPlugin("messagebox").setMessage("error",newresponse.Status&"<br />"&newresponse.StatusDetail);  
          Event.setView("checkoutPaymentError");//show payment error view	
		  
	  }
</cfscript>  
  
</cffunction>  
<!---Allows a user to Try Again with Payment--->
<cffunction name="sagePayTryAgin" access="public" returntype="void" output="false" hint="Try again">
<cfargument name="Event" type="any">
<cfscript>
  var rc = event.getCollection();// RC reference
  structclear(session['protx']);//very important in order to try again you need to clear the txt code session or it will be a repeate transaction and will not be accpeted!
  setNextEvent("secure.sagePayGateway");
</cfscript>  
</cffunction>        
<!--- Complete For 3D Secure--->
<cffunction name="checkoutComplete3DSecure" access="public" returntype="void" output="false">
    <cfargument name="Event" type="any">
    <cfscript>
      var rc = event.getCollection();// RC reference
      Event.setView("checkoutOrderComplete3D");	
     </cfscript>
  </cffunction>   
<!--- Customer Receipt Page--->
<cffunction name="checkoutComplete" access="public" returntype="void" output="false">
    <cfargument name="Event" type="any">
    <cfscript>
      var common = populateModel("common").init(); //create object  
      var rc = event.getCollection();// RC reference
	  //------------------------------------------------------------------------------------------------
	    // show invoice on to customer how every you like 
	   //------------------------------------------------------------------------------------------------
     </cfscript>
  </cffunction>   
</cfcomponent>

