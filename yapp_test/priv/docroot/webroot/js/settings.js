/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


var settings={
    message_diag:("#setting_dialog-message"),
    confirm_diag:("#setting_dialog-confirm"),    
   
    configure_message_dialog:function(){
		
			        _this=this;
			        var diag = $(settings.message_diag);
			        
			        diag.dialog({
			            modal: true,
			            buttons: {
			                Ok: function() {
			                    settings.perfrom_message_close_action();
			                    $( this ).dialog( "close" );
			                }
			            }
			        });
			    
			        diag.dialog('close');
    },
    
    configure_confirmation:function(){
     
			        _this=this;
			        var diag = $(settings.confirm_diag);
			        
			        diag.dialog({
			            modal: true,
			            buttons: {
			                "Cancel":function(){
			                    $( this ).dialog( "close" ); 
			                },
			                "Ok": function() {
			                    _this.confirmation_action() ;
			                    $( this ).dialog( "close" ); 
			
			                }
			           
			              
			            }
			        });
			    
			        diag.dialog('close');
     
    },
    
    confirmation_action:function(){
		
		
	},
		
    show_confirmation:function(message){
			        
			        _this=this;
			        $(settings.confirm_diag).dialog('close');
			        //   $("#dialog-confirm").attr("title",message);
			        $("#setting_dialog-confirm p.message").html(message);
			        $(_this.confirm_diag).dialog('open');

    },
  
  
    show_message:function(message){
			        
			        _this=this;
			        $(settings.message_diag).dialog('close');
			        $("#setting_dialog-message p.message").html(message);
			        $(settings.message_diag).dialog('open');

    },
   
    perfrom_message_close_action:function(){
       
    },
    close_message_diag:function(){
					
					_this=this;
					$(settings.message_diag).dialog('close');
    },
   
   
    disable_okbutt_mgdialg:function(){
    
					$(".ui-dialog-buttonpane button:contains('Ok')").attr("disabled", true).addClass("ui-state-disabled"); 

    },
   
    enable_okbutt_mgdialg:function(){
    
					$(".ui-dialog-buttonpane button:contains('Ok')").attr("disabled", false).removeClass("ui-state-disabled"); 

    },
   
    setup_ajax:function(){
					
			        $(document).bind("ajaxSend",function(){
			            $(".ui-dialog-buttonpane button:contains('Save')").attr("disabled",true).addClass("ui-state-disabled")
			
			        }).bind("ajaxSuccess",function(){
			            $(".ui-dialog-buttonpane button:contains('Save')").attr("disabled",false).removeClass("ui-state-disabled")
			
			        }).bind("ajaxError",function(){
			            $(".ui-dialog-buttonpane button:contains('Save')").attr("disabled",false).removeClass("ui-state-disabled")
			
			             
			        });
    },
	
            
    init:function(){
        
			        _this=this;
			        settings.configure_message_dialog();
			        settings.configure_confirmation();
			
			
			       
			        //for loggin out a user 
			        $("#A_128").live('click',function(e){
			                
			            settings.disable_okbutt_mgdialg();    
			            settings.show_message("Logging Out");
			        })
			        
			        //for opening the logout div 
			        $("#A_116").live('click',function(e){
			            $("#UL_120").toggle(); 
			            $("#UL_81").hide(); 
			        });
			        
			        //for opening the notification div
			        $("#A_78").live('click',function(e){
			            $("#UL_120").hide(); 
			            $("#UL_81").toggle(); 
			        });      
			        
			        //for loading content from the left hand div to the inner view 
			        $(".load_content").live('click',function(e){
			            e.preventDefault();
			            var link=$(this).attr('href');
			            //alert("content page has been clicked");
			            settings.load_content(link);  
			        }); 
			        
					 
			
		},
		
		
	//for loading the content from the side links into the main viewing divs	
	load_content:function(users_url){
		
					_this=this;
					 $.ajax({
			            url: users_url,
			            type:"GET",
			            dataType:'html',
			            beforeSend:function(){
			                    settings.disable_okbutt_mgdialg() ;
			                    settings.show_message("Retrieving Content...");    
			            },
			            success:function(Data) {
			                //  console.log(data);
			                //  alert("data has been loaded");
			                
			                settings.close_message_diag();
			                settings.enable_okbutt_mgdialg();
			              // console.log(Data)
			               $("#secondLevelContent").remove();
			               $("#firstLevelContent").append(Data);                 
			            },
			            error:function(data){
			                settings.enable_okbutt_mgdialg();
			                settings.show_message("Error<br>"+"Please Try Again");      
			            }
			        }); 
					
			}	
		}

$(document).ready(function(){
    
    settings.init();  

});
