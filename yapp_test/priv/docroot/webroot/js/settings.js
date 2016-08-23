/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


var settings={
    message_diag:("#setting_dialog-message"),
    confirm_diag:("#setting_dialog-confirm"),
    
    configure_message_dialog:function(){
        _this=this;
        var diag = $(_this.message_diag);
        
        diag.dialog({
            modal: true,
            buttons: {
                Ok: function() {
                    _this.perfrom_message_close_action();
                    $( this ).dialog( "close" );
                }
            }
        });
    
        diag.dialog('close');
    },
    
    configure_confirmation:function(){
     
        _this=this;
       
        var diag = $(_this.confirm_diag);
        
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
        $(_this.confirm_diag).dialog('close');
        //   $("#dialog-confirm").attr("title",message);
        $("#setting_dialog-confirm p.messsage").html(message);
        $(_this.confirm_diag).dialog('open');

    },
  
  
    show_message:function(message){
        _this=this;
        $(_this.message_diag).dialog('close');
        $("#setting_dialog-message p.messsage").html(message);
        $(_this.message_diag).dialog('open');

    },
   
    perfrom_message_close_action:function(){
       
    },
    close_message_diag:function(){
        _this=this;
        $(_this.message_diag).dialog('close');
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
    
        _this.configure_message_dialog();
        _this.configure_confirmation();
       
        
        $("#A_128").live('click',function(e){
                
            settings.disable_okbutt_mgdialg();    
            settings.show_message("Logging Out");
        })
        
        
        $("#A_116").live('click',function(e){
            $("#UL_120").toggle(); 
            $("#UL_81").hide(); 
        });
        
        $("#A_78").live('click',function(e){
            $("#UL_120").hide(); 
            $("#UL_81").toggle(); 
        });      
        
        $(".load_content").live('click',function(e){
            e.preventDefault();
            var link=$(this).attr('href');
            //alert("content page has been clicked");
            _this.load_content(link);  
        }); 
        
        
        
          $("#search_butt").live('click',function(e) {
            e.preventDefault();
            var link = $("#search_user_url").val();
              _this.load_users_data(link); 
		}); 
        
          $("#search_user").live('keyup',function(e) {
            e.preventDefault();
            var link = $("#search_user_url").val();
            if(e.which==13){
              _this.load_users_data(link); 
            }
        }); 
        
		},
		
		
	load_users_data:function(link){
		_this=this;
		var val=$("#search_user").val();
		 $.ajax({
            url: link,
            method:"GET",
            dataType:'html',
            data:(val!="") ? "filter="+val : "",
            beforeSend:function(){
               _this.disable_okbutt_mgdialg() ;
               _this.show_message("Retrieving Users...");    
            },
            success:function(Data) {
               _this.close_message_diag();
               _this.enable_okbutt_mgdialg();
               $("#table_info").html(Data);
                      
            },
            error:function(data){
               _this.enable_okbutt_mgdialg();
               _this.show_message("Error<br>"+"Please Try Again");      
            }
        }); 
        
        
			
		},	
		
	load_content:function(users_url){
		
		_this=this;
		var val=$("#search_user").val();
		 $.ajax({
            url: users_url,
            method:"GET",
            dataType:'html',
            beforeSend:function(){
                    _this.disable_okbutt_mgdialg() ;
                    _this.show_message("Retrieving Users...");    
            },
            success:function(Data) {
                //  console.log(data);
                //  alert("data has been loaded");
                
                _this.close_message_diag();
                _this.enable_okbutt_mgdialg();
               console.log(Data)
               $("#secondLevelContent").remove();
               $("#firstLevelContent").append(Data);                 
            },
            error:function(data){
                _this.enable_okbutt_mgdialg();
                _this.show_message("Error<br>"+"Please Try Again");      
            }
        }); 
		
		}	
}

$(document).ready(function(){
    
    settings.init();  

})
