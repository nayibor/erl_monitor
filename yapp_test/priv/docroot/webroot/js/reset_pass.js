/***
 * 
 *this is a file for handling password resets  
 * 
 **/
 


$(document).ready(function(){

	reset_pass_usr.init();

	});


var reset_pass_usr = {
	
	
	//this is used for initializin the various events for the reset pass functionality 
	init:function(){
		
			$("#reset_pass_usr_butt").live('click',function(e){
				e.preventDefault();
				if($("#new_password").val()!=$("#repeat_password").val() || ($("#repeat_password").val() =="" || $("#password_old").val()=="") )
				{
					settings.show_message("Old Password Empty Or New Password And Repeat Password Not The Same");
				}
				else 
				{
					old_pass=$("#password_old").val();
					new_pass=$("#new_password").val();
					repeat_new_pass=$("#repeat_password").val();
					settings.show_message("about to reset passs");
					reset_pass_usr.update_password(old_pass,new_pass,repeat_new_pass);
				}
		});      		
		},
	//this is for updating the password once all the criteria has been met 
	    update_password:function(old_pass,new_pass,repeat_new_pass){
				var _this=this;
		        var formurl=$("#reset_pass_user").val();
		        var formdata="old_pass="+old_pass+"&new_pass="+new_pass+"&repeat_new="+repeat_new_pass+"&reset_pass=reset_user";      
		        $.ajax({
		            url: formurl,
		            data:formdata,
		            type: 'POST',
		            dataType:'html',
		            beforeSend:function(){
		                settings.disable_okbutt_mgdialg() ;
		                settings.show_message("Updating Password...");
		                document.href = formurl;
		            },
					success:function(Data) {
				        settings.show_message(Data);
				        settings.enable_okbutt_mgdialg();
					},
					error:function(Data){
				        settings.enable_okbutt_mgdialg();
				        settings.show_message(Data.responseText);      
				    }
				});
        }
	}
