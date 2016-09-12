
var rules ={
	
		edit_rule_div:("#edit_rule_div"),
		edit_rulelist_div:("#edit_rulelist_div"),

		configure_rulelist_div:function(){
			
						  var diag = $(rules.edit_rulelist_div);
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
								rules.save_rule_members($("#save_members_url").val());
				                }
				               
				            }
				        });
				    
				        diag.dialog('close');	
	        
			},
			
			
		configure_rule_div:function(){
			
						  var diag = $(rules.edit_rule_div);
				        
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
									rules.checkfields();
				                }
				               
				            }
				        });
				    
				        diag.dialog('close');	
	        
			},	
		checkfields:function(){
			
					var link=$("#save_add_rule").val(); 
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
						rules.saveRule(link);
					}
					else{
			
						settings.show_message("Please Enter All Fields In Correct Format");
					}
			
			},
			
		saveRule:function(link){
						var formdata=$("#add_rule_form.cmxform").serialize(); 
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
				             
				                settings.show_message(Data); 
				                setTimeout(function() {
								$(rules.edit_rule_div).dialog('close');	                   
								rules.load_rule($("#search_rules_url").val()); 
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
		
		save_rule_members(link){
					
					var ruleid = $("#ruleid").val();
					var rules = $.map( $('#user_roles option:selected'),
					function(e) {
						return $(e).val();
					});
					var formdata="rules="+rules+"&id="+ruleid;     
					$.ajax({
				            url: link,
				            type:"POST",
				            dataType:"html",
				            data:formdata,
				            //data:(val!="") ? "filter="+val : "",
				            beforeSend:function(){
				               settings.disable_okbutt_mgdialg() ;
				               settings.show_message("Saving Rule Members");    
				            },
				            success:function(Data) {
				                settings.show_message(Data);
				                $(rules.edit_rulelist_div).dialog('close');
				            },
				            error:function(Data){
				               settings.enable_okbutt_mgdialg();
				               settings.show_message(Data.responseText);      
				            }
				        }); 
					
					
					
			
			},
		
		init:function(){
				
					rules.configure_rule_div();	
					rules.configure_rulelist_div();
				 //searching for a link when the search button is clicked
			          $("#search_rule_butt").live('click',function(e) {
			            e.preventDefault();
			            var link = $("#search_rules_url").val();
			              rules.load_rule(link); 
					}); 
					
					   //for searching for a link when the enter button is presed
			        $("#search_rule").live('keyup',function(e) {
			            e.preventDefault();
			            var link = $("#search_rules_url").val();
			            if(e.which==13){
			              rules.load_rule(link); 
			            }
			        });	
			        
			             //for searching for a link when the enter button is presed
			        $("#add_rules").live('click',function(e) {
			            e.preventDefault();
			            var link = $("#get_add_rule").val();
			            rules.load_addrule(link); 
			        }); 
			        
			        
			         $(".edit_rule").live('click',function(e) {
			            e.preventDefault();
			            var link =  $(this).attr( "href");
			            rules.load_addrule(link); 
			        }); 
			           $(".get_members").live('click',function(e) {
			            e.preventDefault();
			            var link =  $(this).attr( "href");
			            rules.load_rule_members(link); 
			        }); 
			        
		
		},
		
		
		load_rule_members:function(link){
			
			
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
			               $("#edit_rulelist_div").html(Data);
			               $(rules.edit_rulelist_div).dialog('open');
			               $("#user_roles").pickList({});

			       
			            },
			            error:function(Data){
			               settings.enable_okbutt_mgdialg();
			               settings.show_message("Error<br>"+"Please Try Again");      
			            }
			        }); 	
			
					},
		
		load_addrule:function(link){
			
			
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
			               $("#edit_rule_div").html(Data);
			               $(rules.edit_rule_div).dialog('open');
			       
			            },
			            error:function(Data){
			               settings.enable_okbutt_mgdialg();
			               settings.show_message("Error<br>"+"Please Try Again");      
			            }
			        }); 	
			
					},
		
		
		load_rule:function(link){
		
					 val = $("#search_rule").val();
					 $.ajax({
			            url: link,
			            type:"GET",
			            dataType:'html',
			            data:(val!="") ? "filter="+val : "",
			            beforeSend:function(){
			               settings.disable_okbutt_mgdialg() ;
			               settings.show_message("Searching Rules...");    
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
		        	
		}
	
	}
	
	
	
		
$(document).ready(function(){
    
    rules.init();  

});

