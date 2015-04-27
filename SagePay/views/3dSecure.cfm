<center><img src="../includes/images/core/checkoutStageGif.gif" alt="Process Payment" /></center>
<cfoutput>
<script type='text/javascript'>
  window.onload = function() {
    document.myform.submit()
  }
</script>
<form name="myform" method="POST" action="#rc.responseSettings.ACSURL#" target="3dseucre"/>
      <input type="hidden" name="PaReq" value="#rc.responseSettings.PaReq#"/>
      <input type="hidden" name="TermUrl" value="https://#CGI.HTTP_HOST#/exampleHandler/sagePay3DcallBack.cfm"/>
      <input type="hidden" name="MD" value="#rc.responseSettings.MD#"/>
      
</form>

<!---
You can put 3d secure in a iFrame if you want to make sure that customer say on your website but you will need to use a different layout for 3d secure transactions on the return 
<iframe name="3dseucre" id="frame1" src="#rc.responseSettings.ACSURL#" width="100%" height="500" style="border:0;"></iframe>--->
</cfoutput>







