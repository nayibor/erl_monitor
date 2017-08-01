/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


var Login={


    init:function(){
        $("#login").click(function(event){
            Login.checkLogin();
          event.preventDefault();
        })
    },

    checkLogin:function()
    {
        if($("#username").val()=='' || $("#password").val()=='')
        {
         $("span.install").css("color","red !important").html("Please Enter Correct Username And Password To Login");
         return false;
        }  
        
        $("#login_form").submit();
     
    }
}

$(document).ready(function() {
    Login.init();

})
