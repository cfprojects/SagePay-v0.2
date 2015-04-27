<!---------------------------------------------------------------------
By Glyn Jackson                                                        
This is my first attempt at a ColdBox Plugin. The plugin is tested     
and taking payments on several sites already however the plugin        
is WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express        
or implied.                                                            
                                                                       
If you find this plugin worthy and make any changes please share them! 
---------------------------------------------------------------------->
<cfcomponent name="SagePay" 
			 hint="SagePay plugin for VSP Direct" 
			 extends="coldbox.system.plugin" 
			 output="false"
			 cache="true">
<!------------------------------------------- CONSTRUCTOR ------------------------------------------->	
<cffunction name="init" access="public" returntype="any" output="false">
    <cfargument name="controller" type="any" required="false" />
    <cfscript>
    super.Init(arguments.controller);
    setpluginName("SagePay");
    setpluginVersion("0.02");
    setpluginDescription("SagePay plugin for VSP Direct using protocol version: 2.23");
    //Set which environment to use, simulator,test or live
     setEnvironment(gateway=getSetting("gatewayEnvironment"));
    //Return instance
    return this;
    </cfscript>
</cffunction>
<!------------------------------------------- PUBLIC ------------------------------------------->
<cffunction name="getPluginDetails" output="false" access="public" returntype="string" hint="Just for information and to test my first plugin function"> 
  <!--- Get Event Context --->
  <cfset var event = controller.getRequestService().getContext()>
  <!--- Return the name in the event context --->
  <cfreturn "#getpluginDescription()#. Have a nice day.">
</cffunction>
<!--- ************************************************************* --->
<cffunction name="makeCall" access="public"  hint="Make Call" returntype="struct">
<!--- ************************************************************* --->
<!---<cfargument name="PurchaseURL" type="string" required="yes">--->
<cfargument name="VPSProtocol" type="string" required="yes">
<cfargument name="vendor" type="string" required="yes">
<cfargument name="VendorTxCode" type="string" required="yes">
<cfargument name="DefaultCurrency" type="string" default="GBP" required="no">
<cfargument name="Amount" type="any" required="yes"> 
<cfargument name="CardHolder" type="string" required="yes">
<cfargument name="CardNumber" type="string" required="yes"> 
<cfargument name="DefaultApplyAVSCV2" type="string" required="no" default="0">
<cfargument name="Basket" type="string" required="no" default="">
<cfargument name="StartDate" type="string" required="no" default="">
<cfargument name="ExpiryDate" type="string" required="yes">
<cfargument name="DeliveryAddress" type="string" required="yes" default="">
<cfargument name="CardType" type="string" required="yes">
<cfargument name="BillingPostCode" type="string" required="yes">
<cfargument name="DeliveryPostCode" type="string" required="yes">
<cfargument name="CustomerName" type="string" required="yes">
<cfargument name="ContactNumber" type="string" required="no" default="">
<cfargument name="ContactFax" type="string" required="no" default="">
<cfargument name="CustomerEmail" type="string" required="no" default="">
<cfargument name="ClientIPAddress" type="string" required="no" default="#CGI.REMOTE_ADDR#">
<cfargument name="CAVV" type="string" required="no" default="">
<cfargument name="XID" type="string" required="no" default="">
<cfargument name="ECI" type="string" required="no" default="">
<cfargument name="DSecureStatus" type="string" required="no" default=""> 
<cfargument name="CV2" type="string" required="no">
<cfargument name="referrerID" type="string" required="no" default="">
<cfargument name="DefaultDescription" type="string" required="no" default="Payment From #CustomerName#">
<cfargument name="billfirstName" type="string" required="yes">
<cfargument name="billlastName" type="string" required="yes">
<cfargument name="BillingAddress1" type="string" required="yes">
<cfargument name="billingcity" type="string" required="yes">
<cfargument name="BillingCountry" type="string" required="no" default="GB">
<cfargument name="ISSUENUMBER" type="string" required="no" default="">
<!--- ************************************************************* --->
<!--- ************************************************************* --->
  <!---Get the contents of the post from the previous page and split out the variables for sending--->
  <cfset RequestData = GetHttpRequestData()>
  <cfset Response = StructNew()>
  <cfloop list="#RequestData.content#" index="line" delimiters="&">
    <cfset line = Trim( line )>
    <cfset StructInsert( Response, Trim( ListFirst( line, "=" ) ), URLDecode(Trim(Mid(line,Find("=",line)+1,len(line)) )) )>
  </cfloop>
<!--- ************************************************************* --->  
<!---Set the required outgoing properties for the initial HTTPS post to the VPS--->
<!--- ************************************************************* --->
  <!---******************HERE IS WHERE THE ORDER GETS SENT TO PROTX VIA HTTPS*********************** --->
    <cfhttp url="#GatewaySettings.PurchaseURL#" method="post" delimiter="," throwonerror="no">
    <!---to combat IIS's compression scheme incompatible with CFHTTP this issue was fixed in MX7 but is back in CF8--->
    <cfhttpparam type="Header" name="Accept-Encoding" value="deflate;q=0">
    <cfhttpparam type="Header" name="TE" value="deflate;q=0">
    <!---end--->
    <cfhttpparam name="TxType" value="Payment" type="formfield">
     <cfhttpparam name="VPSProtocol" value="#arguments.VPSProtocol#" type="formfield">
    <cfhttpparam name="Vendor" value="#arguments.vendor#" type="formfield">
    <cfhttpparam name="VendorTxCode" value="#arguments.VendorTxCode#" type="formfield">
    <cfhttpparam name="referrerID" value="#arguments.referrerID#" type="formfield">
    <cfhttpparam name="Currency" value="#arguments.DefaultCurrency#" type="formfield">
    <cfhttpparam name="Description" value="#arguments.DefaultDescription#" type="formfield">
    <cfhttpparam name="Amount" value="#arguments.Amount#" type="formfield">
    <cfhttpparam name="CardHolder" value="#arguments.CardHolder#" type="formfield">
    <cfhttpparam name="CardNumber" value="#arguments.CardNumber#" type="formfield">
    <cfhttpparam name="GiftAidPayment" value="0" type="formfield">
    <cfhttpparam name="ApplyAVSCV2" value="#arguments.DefaultApplyAVSCV2#" type="formfield"> 
    <cfhttpparam name="BillingSurname" value="#arguments.billlastName#" type="formfield">
    <cfhttpparam name="BillingFirstnames" value="#arguments.billfirstName#" type="formfield">
    <cfhttpparam name="BillingCity" value="#arguments.billingcity#" type="formfield">
    <cfhttpparam name="BillingCountry" value="#arguments.BillingCountry#" type="formfield">
    <cfhttpparam name="DeliverySurname" value="#arguments.billlastName#" type="formfield"> 
    <cfhttpparam name="DeliveryFirstnames" value="#arguments.billfirstName#" type="formfield">
    <cfhttpparam name="DeliveryAddress1" value="#arguments.BillingAddress1#" type="formfield">
    <cfhttpparam name="DeliveryCity" value="#arguments.BillingAddress1#" type="formfield">
    <cfhttpparam name="DeliveryCountry" value="#arguments.BillingCountry#" type="formfield">
    <cfhttpparam name="Basket" value="#arguments.Basket#" type="formfield">
	<cfif #arguments.StartDate# is not "">
      <cfhttpparam name="StartDate" value="#arguments.StartDate#" type="formfield">
    </cfif>
    <cfif #arguments.ExpiryDate# is not "">
      <cfhttpparam name="ExpiryDate" value="#arguments.ExpiryDate#" type="formfield">
    </cfif>
    <cfif #arguments.DeliveryAddress# is not "">
      <cfhttpparam name="DeliveryAddress" value="#arguments.DeliveryAddress#" type="formfield">
    </cfif>
     <cfhttpparam name="BillingAddress1" value="#arguments.BillingAddress1#" type="formfield">
    <cfif #arguments.IssueNumber# is not "">
      <cfhttpparam name="IssueNumber" value="#arguments.IssueNumber#" type="formfield">
    </cfif>
    <cfhttpparam name="CV2" value="#arguments.CV2#" type="formfield">
    <cfhttpparam name="CardType" value="#arguments.CardType#" type="formfield">
    <cfhttpparam name="BillingPostCode" value="#arguments.BillingPostCode#" type="formfield">
    <cfif #arguments.DeliveryPostCode# is not "">
      <cfhttpparam name="DeliveryPostCode" value="#arguments.DeliveryPostCode#" type="formfield">
    </cfif>
    <cfhttpparam name="CustomerName" value="#arguments.CustomerName#" type="formfield">    
	<cfif #arguments.ContactNumber# is not "">
      <cfhttpparam name="ContactNumber" value="#arguments.ContactNumber#" type="formfield">
    </cfif>
    <cfif #arguments.ContactFax# is not "">
      <cfhttpparam name="ContactFax" value="#arguments.ContactFax#" type="formfield">
    </cfif>
    <cfhttpparam name="CustomerEmail" value="#arguments.CustomerEmail#" type="formfield">
    <cfif #arguments.ClientIPAddress# is not "">
      <cfhttpparam name="ClientIPAddress" value="#arguments.ClientIPAddress#" type="formfield">
    </cfif>
    <cfif #arguments.CAVV# is not "">
      <cfhttpparam name="CAVV" value="#arguments.CAVV#" type="formfield">
    </cfif>
    <cfif #arguments.XID# is not "">
      <cfhttpparam name="XID" value="#arguments.XID#" type="formfield">
    </cfif>
    <cfif #arguments.ECI# is not "">
      <cfhttpparam name="ECI" value="#arguments.ECI#" type="formfield">
    </cfif>
    <cfif #arguments.DSecureStatus# is not "">
      <cfhttpparam name="3DSecureStatus" value="#arguments.arguments.DSecureStatus#" type="formfield">
    </cfif>
  </cfhttp>
  <!--- ********************************END OF HTTPS POST TO PROTX******************************************--->
  <cfset Response = StructNew()>
  <!---if http post was ok--->
  <cfif #cfhttp.statusCode# is "200 OK">
  <cfloop list="#CFHTTP.FileContent#" index="line" delimiters="#chr(13)#">
    <cfset line = Trim( line )>
    <cfset StructInsert( Response, Trim( ListFirst( line, "=" ) ), Trim(Mid(line,Find("=",line)+1,len(line)) ) )>
  </cfloop>
  <!---if could not contact gateway--->
  <cfelse>
    <cfset StructInsert(Response, "Status", "timeout")>
    <cfset StructInsert(Response, "StatusDetail", "Timeout Error: could not contact payment gateway or header code was not 200, please contact website owner.")>
  </cfif>
  <!---retrun responce--->
  <cfreturn Response>
</cffunction>
<!---3D Secure - New responce to sort out with 3D Secure info in it. sort ready to determine next action--->
<cffunction name="DSecureCallBack" access="public"  hint="Make Call" returntype="struct">
<cfargument name="MD" type="string" required="yes">
<cfargument name="PARes" type="string" required="yes">
<cfscript>
var Response= 0;
</cfscript>
 <cfhttp url="#GatewaySettings.callbackURL#" method="post" delimiter="," throwonerror="no">
   <cfhttpparam type="Header" name="charset" value="utf-8" />'<!---had some issues on CF8 with compression MX7 seem to be fine--->
    <cfhttpparam name="MD" value="#arguments.MD#" type="formfield">
    <cfhttpparam name="PARes" value="#arguments.PARes#" type="formfield">
  </cfhttp>
  <cfset Response = StructNew()>
  <cfloop list="#CFHTTP.FileContent#" index="line" delimiters="#chr(13)#">
    <cfset line = Trim( line )>
    <cfset StructInsert( Response, Trim( ListFirst( line, "=" ) ), Trim(Mid(line,Find("=",line)+1,len(line)) ) )>
  </cfloop>
 <!---retrun responce--->
 <cfreturn Response>
</cffunction>
<!------------------------------------------- PRIVATE ------------------------------------------->
<cffunction name="setEnvironment" access="private" hint="Set which gateway ULR's are to be used, simulator, test or live" output="false" returntype="struct">
<!--- ************************************************************* --->
<cfargument name="gateway" type="string" required="true" default="simulator"/>
<!--- ************************************************************* --->
<cfset  GatewaySettings = StructNew() />
<cfscript>
  if (arguments.gateway is "simulator") {  
 StructInsert(GatewaySettings, "Verify", "false");
 StructInsert(GatewaySettings, "PurchaseURL", "https://test.sagepay.com/Simulator/VSPDirectGateway.asp");
 StructInsert(GatewaySettings, "RefundURL", "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorRefundTx");
 StructInsert(GatewaySettings, "ReleaseURL", "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorReleaseTx");
 StructInsert(GatewaySettings, "RepeatURL", "https://test.sagepay.com/Simulator/VSPServerGateway.asp?Service=VendorRepeatTx");
 StructInsert(GatewaySettings, "callbackURL", "https://test.sagepay.com/Simulator/VSPDirectCallback.asp");
  }
 if (arguments.gateway is "test") {  
 StructInsert(GatewaySettings, "Verify", "false");
 StructInsert(GatewaySettings, "PurchaseURL", "https://test.sagepay.com/gateway/service/vspdirect-register.vsp");
 StructInsert(GatewaySettings, "RefundURL", "https://test.sagepay.com/gateway/service/refund.vsp");
 StructInsert(GatewaySettings, "ReleaseURL", "https://test.sagepay.com/gateway/service/release.vsp");
 StructInsert(GatewaySettings, "RepeatURL", "https://test.sagepay.com/gateway/service/repeat.vsp");
 StructInsert(GatewaySettings, "callbackURL", "https://test.sagepay.com/gateway/service/direct3dcallback.vsp");
 }
 if (arguments.gateway is "live") { 
 StructInsert(GatewaySettings, "Verify", "false");
 StructInsert(GatewaySettings, "PurchaseURL", "https://live.sagepay.com/gateway/service/vspdirect-register.vsp");
 StructInsert(GatewaySettings, "RefundURL", "https://live.sagepay.com/gateway/service/refund.vsp");
 StructInsert(GatewaySettings, "ReleaseURL", "https://live.sagepay.com/gateway/service/release.vsp");
 StructInsert(GatewaySettings, "RepeatURL", "https://live.sagepay.com/gateway/service/repeat.vsp");
 StructInsert(GatewaySettings, "callbackURL", "https://live.sagepay.com/gateway/service/direct3dcallback.vsp");
 }
</cfscript>
  <cfreturn GatewaySettings>
</cffunction>

</cfcomponent>