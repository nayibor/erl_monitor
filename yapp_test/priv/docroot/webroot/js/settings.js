/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


var settings={
    message_diag:("#setting_dialog-message"),
    confirm_diag:("#setting_dialog-confirm"),
    add_edit_diag:("#add_edit_user"),
    get_role_diag:("#get_role_div"),
    get_add_edit_link:("#add_edit_link"),
    save_role_id:"",
    
    
    
    
    configure_links:function(){
		_this=this;
        var diag = $(_this.get_add_edit_link);
        
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
				_this.check_fields_links();				
				
                }
               
            }
        });
    
        diag.dialog('close');	
	}
    ,
    
    configure_add:function(){
		_this=this;
        var diag = $(_this.add_edit_diag);
        
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
					_this.checkfields();
				
				
                }
               
            }
        });
    
        diag.dialog('close');	
	},
	configure_roles:function(){
		_this=this;
        var diag = $(_this.get_role_diag);
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
					_this.save_roles_user(link);
				
				
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
		_this.save_data_user(link);
	}
	else{

		settings.show_message("Please Enter All Fields In Correct Format");
	}
		
		
	}, 
	
	
	check_fields_links:function(){
		
	_this=this;	
	var link=$("#save_links_url").val(); 
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
		_this.save_data_link(link);
	}
	else{

		settings.show_message("Please Enter All Fields In Correct Format");
	}
	},
	
 
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
        $("#setting_dialog-confirm p.message").html(message);
        $(_this.confirm_diag).dialog('open');

    },
  
  
    show_message:function(message){
        _this=this;
        $(_this.message_diag).dialog('close');
        $("#setting_dialog-message p.message").html(message);
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
        _this.configure_add();
        _this.configure_roles();
        _this.configure_links();


       
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
            _this.load_content(link);  
        }); 
        
        
        //searching for a user when the search button is clicked
          $("#search_butt").live('click',function(e) {
            e.preventDefault();
            var link = $("#search_user_url").val();
              _this.load_users_data(link); 
		}); 
        
        //for searching for a user when the enter button is presed
        $("#search_user").live('keyup',function(e) {
            e.preventDefault();
            var link = $("#search_user_url").val();
            if(e.which==13){
              _this.load_users_data(link); 
            }
        }); 
        
        //for editing  a user
	    $("#add_user").live('click',function(e) {
		  e.preventDefault();
		  var link =$("#get_add_user_url").val();
		  _this.load_add_user(link);
	
		});

         $(".edit_user").live('click',function(e) {
		  e.preventDefault();
		  var link=$(this).attr('href');
		  _this.load_add_user(link);
	
		});
    
    //for gettting the roles of a user
		 $(".get_roles").live('click',function(e) {
		  e.preventDefault();
		  var link=$(this).attr('href');
		  _this.id = $(this).closest("tr").attr("id");
		  _this.get_roles(link);
	
		});
    
    //for resetting the pass of a user 
    	 $(".reset_pass").live('click',function(e) {
		  e.preventDefault();
		  var link=$(this).attr('href');
		  _this.reset_pass(link);
	
		});
    
    //for locking/unlocking a use 
      	 $(".iconlock,.iconopen").live('click',function(e) {
		  e.preventDefault();
		  var link=$(this).attr('href');
		  _this.lock_action(link);
	
		});
		
		
		    //searching for a link when the search button is clicked
          $("#search_link_butt").live('click',function(e) {
            e.preventDefault();
            var link = $("#search_links_url").val();
              _this.load_search_data(link); 
		}); 
        
        //for searching for a link when the enter button is presed
        $("#search_link").live('keyup',function(e) {
            e.preventDefault();
            var link = $("#search_links_url").val();
            if(e.which==13){
              _this.load_search_data(link); 
            }
        }); 
		
		//for adding a link to the system 
		
		 $("#add_link").live('click',function(e) {
		  e.preventDefault();
		  var link =$("#get_add_link_url").val();
		  _this.load_add_link(link);
	
		});
		
		//for adding a link to the system 
		
		 $(".edit_link").live('click',function(e) {
		  e.preventDefault();
		 var link=$(this).attr('href');
		  _this.load_add_link(link);
	
		});
		
			
		},
		
		
		//for loading the add link functionality
	
	    load_add_link:function(link){
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
               _this.close_message_diag();
               $("#add_edit_link").html(Data);
               $(_this.get_add_edit_link).dialog('open');
       
            },
            error:function(Data){
               _this.enable_okbutt_mgdialg();
               _this.show_message("Error<br>"+"Please Try Again");      
            }
        }); 	
        	
		},
		
		
		//for saving a link
		   save_data_link:function(link){
		_this=this;
		var formdata=$("#add_link_form.cmxform").serialize();
		$.ajax({
            url: link,
            data : formdata,
            type:"POST",
            dataType:'html',
            //data:(val!="") ? "filter="+val : "",
            beforeSend:function(){
               _this.disable_okbutt_mgdialg() ;
               _this.show_message("Saving Link...");    
            },
            success:function(Data) {
                _this.show_message(Data);
	                setTimeout(function() {
					$(_this.get_add_edit_link).dialog('close');	                   
					_this.load_search_data($("#search_links_url").val());
				}, 2000);	
       
            },
            error:function(Data){
                settings.show_message(Data.responseText);
                settings.enable_okbutt_mgdialg();      
            }
        }); 	
        	
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
				$(_this.get_role_diag).dialog('close');	                   
                _this.show_message(Data); 
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
	               _this.disable_okbutt_mgdialg() ;
	               _this.show_message("Saving Data");    
	            },
	            success:function(Data) {
	               //_this.close_message_diag();
	              //  _this.enable_okbutt_mgdialg();
	                _this.show_message(Data); 
	                setTimeout(function() {
					$(_this.add_edit_diag).dialog('close');	                   
					_this.load_users_data($("#search_user_url").val());
				}, 2000);	
	               //$("#add_edit_user").html(Data);
	               //$(_this.add_edit_diag).dialog('close');
	       
	            },
	            error:function(Data){
	               _this.enable_okbutt_mgdialg();
	               _this.show_message(Data.responseText);      
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
               _this.disable_okbutt_mgdialg() ;
               _this.show_message("Performing action ...");    
            },
            success:function(Data) {
             _this.show_message(Data);    
                 setTimeout(function() {
				_this.load_users_data($("#search_user_url").val());
			}, 2000);	
            },
            error:function(data){
               _this.enable_okbutt_mgdialg();
               _this.show_message(Data.responseText);       
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
               _this.disable_okbutt_mgdialg() ;
               _this.show_message("Resetting Pass...");    
            },
            success:function(Data) {
             _this.enable_okbutt_mgdialg();
             _this.show_message(Data);  
       
            },
            error:function(Data){
               _this.enable_okbutt_mgdialg();
               _this.show_message(Data.responseText);       
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
               _this.close_message_diag();
               $("#get_role_div").html(Data);
               $(_this.get_role_diag).dialog('open');
				$("#user_roles").pickList({});
            },
            error:function(data){
               _this.enable_okbutt_mgdialg();
               _this.show_message("Error<br>"+"Please Try Again");      
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
               _this.close_message_diag();
               $("#add_edit_user").html(Data);
               $(_this.add_edit_diag).dialog('open');
       
            },
            error:function(Data){
               _this.enable_okbutt_mgdialg();
               _this.show_message("Error<br>"+"Please Try Again");      
            }
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
		
		//for loading the link list when a search is made
		load_search_data:function(link){
		_this=this;
		var val=$("#search_link").val();
		 $.ajax({
            url: link,
            type:"GET",
            dataType:'html',
            data:(val!="") ? "filter="+val : "",
            beforeSend:function(){
               _this.disable_okbutt_mgdialg() ;
               _this.show_message("Retrieving Links...");    
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
		}
		
		
		
		,
		
	//for loading the content from the side links into the main viewing divs	
	load_content:function(users_url){
		
		_this=this;
		 $.ajax({
            url: users_url,
            type:"GET",
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
              // console.log(Data)
               $("#secondLevelContent").remove();
               $("#firstLevelContent").append(Data);                 
            },
            error:function(data){
                _this.enable_okbutt_mgdialg();
                _this.show_message("Error<br>"+"Please Try Again");      
            }
        }); 
		
		}	
};

$(document).ready(function(){
    
    settings.init();  

});
