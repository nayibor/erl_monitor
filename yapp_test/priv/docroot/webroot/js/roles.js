
var roles={
	get_role_sys_diag:("#role_div"),
	edit_role_div:("#edit_role_div"),
	id:"",
	
	configure_roles_link:function(){
		

        var diag = $(roles.get_role_sys_diag);
        
        diag.dialog({
			width: 500,
			height: 400,
			position:"center",
			modal:false,
            buttons: {
				Cancel:function(){
				    $( this ).dialog( "close" );	
				},
				Save: function() {
					roles.saverolelinks();
                }
               
            }
        });
    
        diag.dialog('close');
		
		
		},
		
	configure_edit:function(){
		
		   var diag = $(roles.edit_role_div);
        
        diag.dialog({
			width: 500,
			height: 400,
			position:"center",
			modal:false,
            buttons: {
				Cancel:function(){
				    $( this ).dialog( "close" );	
				},
				Save: function() {
					roles.checkfields();
                }
               
            }
        });
    
        diag.dialog('close');
		
		},	
	
	saverolelinks:function(){
		
		var link=$("#save_role_links").val(); 
		var role_id=roles.id;
		 var links_role = $.map( $('#user_roles option:selected'),
            function(e) {
                return $(e).val();
            } );
		
		formdata="roleid="+role_id+"&new_links="+links_role;
		
		$.ajax({
	            url: link,
	            type:"POST",
	            dataType:"html",
	            data:formdata,
	            beforeSend:function(){
	               settings.disable_okbutt_mgdialg() ;
	               settings.show_message("Saving Data");    
	            },
	            success:function(Data) {
	               //_this.close_message_diag();
	              //  _this.enable_okbutt_mgdialg();
	                settings.show_message(Data); 
	                setTimeout(function() {
					$(roles.get_role_sys_diag).dialog('close');	                   
					roles.load_search_roles( $("#search_roles").val());
				}, 2000);	
	               //$("#add_edit_user").html(Data);
	               //$(_this.add_edit_diag).dialog('close');
	       
	            },
	            error:function(Data){
	               settings.enable_okbutt_mgdialg();
	               settings.show_message(Data.responseText);      
	            }
	        });
		
		},
	
	checkfields:function(){
		
		_this=this;	
		var link=$("#save_add_role").val(); 
		var counter=0;
		$(".ca").each(function(){
			if(!(document.getElementById($(this).attr("id")).checkValidity())){
				$(this).css("border","solid #F44 2px"); 
				counter++;
			}else
			{
				$(this).css("border","solid grey 1px");       
			}
		});
		  
		if(counter==0)
		{
			roles.save_add_role(link);
		}
		else{

			settings.show_message("Please Enter All Fields In Correct Format");
		}
			
		},
		
	save_add_role:function(link){
		
		
		  var formdata=$("#add_role_form.cmxform").serialize(); 
			$.ajax({
	            url: link,
	            type:"POST",
	            dataType:"html",
	            data:formdata,
	            //data:(val!="") ? "filter="+val : "",
	            beforeSend:function(){
	               settings.disable_okbutt_mgdialg() ;
	               settings.show_message("Saving Data");    
	            },
	            success:function(Data) {
	               //_this.close_message_diag();
	              //  _this.enable_okbutt_mgdialg();
	                settings.show_message(Data); 
	                setTimeout(function() {
					$(roles.edit_role_div).dialog('close');	                   
					roles.load_search_roles( $("#search_roles").val());
				}, 2000);	
	               //$("#add_edit_user").html(Data);
	               //$(_this.add_edit_diag).dialog('close');
	       
	            },
	            error:function(Data){
	               settings.enable_okbutt_mgdialg();
	               settings.show_message(Data.responseText);      
	            }
	        }); 
		},
	
	init:function(){

		
		roles.configure_roles_link();
		roles.configure_edit();
		
		   //searching for a link when the search button is clicked
          $("#search_role_butt").live('click',function(e) {
            e.preventDefault();
            var link = $("#search_roles").val();
              roles.load_search_roles(link); 
		}); 
        
        //for searching for a link when the enter button is presed
        $("#search_role").live('keyup',function(e) {
            e.preventDefault();
            var link = $("#search_roles").val();
            if(e.which==13){
              roles.load_search_roles(link); 
            }
        }); 
        
        //for loading add/edit role div
        
         //for searching for a link when the enter button is presed
        $("#add_role").live('click',function(e) {
            e.preventDefault();
            var link = $("#get_add_role").val();
            roles.load_addrole(link); 
        }); 
        
        //for searching for a link when the enter button is presed
        $(".edit_role").live('click',function(e) {
            e.preventDefault();
            var link = $(this).attr("href");
            roles.load_addrole(link); 
        }); 
        
        
         //for getting role links 
        $(".get_role_links").live('click',function(e) {
            e.preventDefault();
            roles.id = $(this).closest("tr").attr("id");
            var link = $(this).attr("href");
            roles.load_role_links(link); 
        }); 
        
        
        
		},
		
	load_role_links:function(link){	
		
		$.ajax({
	            url: link,
	            type:"GET",
	            dataType:'html',
	            //data:(val!="") ? "filter="+val : "",
	            beforeSend:function(){
	              // _this.disable_okbutt_mgdialg() ;
	              // _this.show_message("Retrieving Add Modal...");    
	            },
	            success:function(Data) {
	               settings.close_message_diag();
	               $("#role_div").html(Data);
	               $(roles.get_role_sys_diag).dialog('open');
					$("#user_roles").pickList({});
	            },
	            error:function(data){
	               settings.enable_okbutt_mgdialg();
	               settings.show_message("Error<br>"+"Please Try Again");      
	            }
	        }); 	
		
	},
		
	 load_search_roles:function(link){
		 val = $("#search_role").val();
		$.ajax({
            url: link,
            type:"GET",
            dataType:'html',
            data:(val!="") ? "filter="+val : "",
            beforeSend:function(){
               settings.disable_okbutt_mgdialg() ;
               settings.show_message("Searching Roles...");    
            },
            success:function(Data) {
                settings.close_message_diag();
               settings.enable_okbutt_mgdialg();
               $("#table_info").html(Data);
       
            },
            error:function(Data){
               settings.enable_okbutt_mgdialg();
               settings.show_message("Error<br>"+"Please Try Again");      
            }
        }); 	
        	
		},
		load_addrole:function(link){
		
		$.ajax({
            url: link,
            type:"GET",
            dataType:'html',
            beforeSend:function(){
              // _this.disable_okbutt_mgdialg() ;
              // _this.show_message("Retrieving Add Modal...");    
            },
            success:function(Data) {
               settings.close_message_diag();
               $("#edit_role_div").html(Data);
               $(roles.edit_role_div).dialog('open');
       
            },
            error:function(Data){
               settings.enable_okbutt_mgdialg();
               settings.show_message("Error<br>"+"Please Try Again");      
            }
        }); 		
		
		}
		
		};
		
		
$(document).ready(function(){
    
    roles.init();  

});
