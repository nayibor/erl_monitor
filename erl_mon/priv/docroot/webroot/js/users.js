
users = {
		
		
		add_edit_diag:("#add_edit_user"),
	    get_role_diag:("#get_role_div"),
	    id:"",
	    
		configure_add:function(){
				_this=this;
		        var diag = $(users.add_edit_diag);
		        diag.dialog({
					width: 500,
					height: 300,
					position:"center",
					modal:false,
		            buttons: {
						Cancel:function(){
						    $( this ).dialog( "close" );	
						},
						Save: function() {
							users.checkfields();
						
						
		                }
		               
		            }
		        });
		        diag.dialog('close');	
		},
		
		
		configure_roles:function(){
				_this=this;
		        var diag = $(users.get_role_diag);
		        var link=$("#save_roles_user").val();
		        
		        diag.dialog({
					width: 500,
					height: 300,
					position:"center",
					modal:false,
		            buttons: {
						Cancel:function(){
						    $( this ).dialog( "close" );	
						},
						Save: function() {
							users.save_roles_user(link);
						
						
		                }
		               
		            }
		        });
		    
				diag.dialog('close');
		},
	
	
		checkfields:function(){
					_this=this;	
					var link=$("#save_add_user_url").val(); 
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
						users.save_data_user(link);
					}
					else{
				
						settings.show_message("Please Enter All Fields In Correct Format");
					}					
						
		},
	
	
		//for updating a users roles
		
		save_roles_user:function(link){
					var _this=this;      
			        var roles = $.map( $('#user_roles option:selected'),
			            function(e) {
			                return $(e).val();
			            } );
			        //   console.log(roles);
			        var data="roles="+roles+"&id="+_this.id;     
					$.ajax({
			            url: link,
			            data: data,
			            type:'POST',
			            dataType: 'html',
			            beforeSend:function(){
			                settings.disable_okbutt_mgdialg() ;
			                settings.show_message("Saving...")
			            },
			            success: function(Data){
							$(users.get_role_diag).dialog('close');	                   
			                settings.show_message(Data); 
			                settings.enable_okbutt_mgdialg();
			
			            },
			            error:function(Data){
			                settings.show_message(Data.responseText);
			                settings.enable_okbutt_mgdialg();
			            }
			         
			        })    
		},
	
	
			//this is for adding a new user to the system 
	    save_data_user:function(link){
					_this=this;
					var formdata=$("#add_user_form.cmxform").serialize(); 
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
							$(users.add_edit_diag).dialog('close');	                   
							users.load_users_data($("#search_user_url").val());
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
					
					
				 users.configure_add();
				 users.configure_roles();	
					
		        //searching for a user when the search button is clicked
		          $("#search_butt").live('click',function(e) {
		            e.preventDefault();
		            var link = $("#search_user_url").val();
		              users.load_users_data(link); 
				}); 
		        
		        //for searching for a user when the enter button is presed
		        $("#search_user").live('keyup',function(e) {
		            e.preventDefault();
		            var link = $("#search_user_url").val();
		            if(e.which==13){
		              users.load_users_data(link); 
		            }
		        }); 
		        
		        //for editing  a user
			    $("#add_user").live('click',function(e) {
				  e.preventDefault();
				  var link =$("#get_add_user_url").val();
				  users.load_add_user(link);
			
				});
		
		         $(".edit_user").live('click',function(e) {
				  e.preventDefault();
				  var link=$(this).attr('href');
				  users.load_add_user(link);
			
				});
		    
		    //for gettting the roles of a user
				 $(".get_roles").live('click',function(e) {
				  e.preventDefault();
				  var link=$(this).attr('href');
				  users.id = $(this).closest("tr").attr("id");
				  users.get_roles(link);
			
				});
		    
		    //for resetting the pass of a user 
		    	 $(".reset_pass").live('click',function(e) {
				  e.preventDefault();
				  var link=$(this).attr('href');
				  users.reset_pass(link);
			
				});
		    
		    //for locking/unlocking a use 
		      	 $(".iconlock,.iconopen").live('click',function(e) {
				  e.preventDefault();
				  var link=$(this).attr('href');
				  users.lock_action(link);
			
				});
	
		},

		
		//for loading the users list when a search is made
		load_users_data:function(link){
				_this=this;
				var val=$("#search_user").val();
				 $.ajax({
		            url: link,
		            type:"GET",
		            dataType:'html',
		            data:(val!="") ? "filter="+val : "",
		            beforeSend:function(){
		               settings.disable_okbutt_mgdialg() ;
		               settings.show_message("Retrieving Users...");    
		            },
		            success:function(Data) {
		               settings.close_message_diag();
		               settings.enable_okbutt_mgdialg();
		               $("#table_info").html(Data);
		                      
		            },
		            error:function(data){
		               settings.enable_okbutt_mgdialg();
		               settings.show_message("Error<br>"+"Please Try Again");      
		            }
		        }); 	
        
		},
		
		//for loading the add user functionality
	
	    load_add_user:function(link){
					_this=this;
				//	$(_this.add_edit_diag).dialog().load(link,function(rdata){
			    //            
			    //    })
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
			               $("#add_edit_user").html(Data);
			               $(users.add_edit_diag).dialog('open');
			       
			            },
			            error:function(Data){
			               settings.enable_okbutt_mgdialg();
			               settings.show_message("Error<br>"+"Please Try Again");      
			            }
			        }); 	
        	
		},
		
				//for getting the roles for a user
		get_roles:function(link){
					_this=this;
			
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
			               $("#get_role_div").html(Data);
			               $(users.get_role_diag).dialog('open');
							$("#user_roles").pickList({});
			            },
			            error:function(data){
			               settings.enable_okbutt_mgdialg();
			               settings.show_message("Error<br>"+"Please Try Again");      
			            }
			        }); 	
			        	
		},
	
		
		//ajax link for restting the pass of the user 
		reset_pass(link){
			
				    _this=this;
			
					$.ajax({
			            url: link,
			            type:"POST",
			            dataType:'html',
			            //data:(val!="") ? "filter="+val : "",
			            beforeSend:function(){
			               settings.disable_okbutt_mgdialg() ;
			               settings.show_message("Resetting Pass...");    
			            },
			            success:function(Data) {
			             settings.enable_okbutt_mgdialg();
			             settings.show_message(Data);  
			       
			            },
			            error:function(Data){
			               settings.enable_okbutt_mgdialg();
			               settings.show_message(Data.responseText);       
			            }
			        }); 	
			        			
		},
		
		
		
		//for locking or unlocking a user f
			//ajax link for restting the pass of the user 
		lock_action(link){
						
					_this=this;
					$.ajax({
			            url: link,
			            type:"POST",
			            dataType:'html',
			            //data:(val!="") ? "filter="+val : "",
			            beforeSend:function(){
			               settings.disable_okbutt_mgdialg() ;
			               settings.show_message("Performing action ...");    
			            },
			            success:function(Data) {
			             settings.show_message(Data);    
			                 setTimeout(function() {
							users.load_users_data($("#search_user_url").val());
						}, 2000);	
			            },
			            error:function(data){
			               settings.enable_okbutt_mgdialg();
			               settings.show_message(Data.responseText);       
			            }
			        }); 		        	
			        			
		}
	
	};
						
					$(document).ready(function(){
					    
					    users.init();  
					
					});

