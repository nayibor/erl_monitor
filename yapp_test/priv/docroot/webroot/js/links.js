
links = {
	
	    get_add_edit_link:("#add_edit_link"),    
		
		configure_links:function(){
		
					_this=this;
			        var diag = $(links.get_add_edit_link);
			        
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
							links.check_fields_links();				
							
			                }
			               
			            }
			        });
			    
			        diag.dialog('close');	
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
						links.save_data_link(link);
					}
					else{
				
						settings.show_message("Please Enter All Fields In Correct Format");
					}
		},
	
	
		init:function(){
		
		
					links.configure_links();

					   //searching for a link when the search button is clicked
			          $("#search_link_butt").live('click',function(e) {
			            e.preventDefault();
			            var link = $("#search_links_url").val();
			              links.load_search_data(link); 
					}); 
			        
			        //for searching for a link when the enter button is presed
			        $("#search_link").live('keyup',function(e) {
			            e.preventDefault();
			            var link = $("#search_links_url").val();
			            if(e.which==13){
			              links.load_search_data(link); 
			            }
			        }); 
					
					//for adding a link to the system 
					
					 $("#add_link").live('click',function(e) {
					  e.preventDefault();
					  var link =$("#get_add_link_url").val();
					  links.load_add_link(link);
				
					});
					
					//for adding a link to the system 
					
					 $(".edit_link").live('click',function(e) {
					  e.preventDefault();
					 var link=$(this).attr('href');
					  links.load_add_link(link);
				
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
			               settings.close_message_diag();
			               $("#add_edit_link").html(Data);
			               $(links.get_add_edit_link).dialog('open');
			       
			            },
			            error:function(Data){
			               settings.enable_okbutt_mgdialg();
			               settings.show_message("Error<br>"+"Please Try Again");      
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
			               settings.disable_okbutt_mgdialg() ;
			               settings.show_message("Saving Link...");    
			            },
			            success:function(Data) {
			                settings.show_message(Data);
				                setTimeout(function() {
								$(links.get_add_edit_link).dialog('close');	                   
								links.load_search_data($("#search_links_url").val());
							}, 2000);	
			       
			            },
			            error:function(Data){
			                settings.show_message(Data.responseText);
			                settings.enable_okbutt_mgdialg();      
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
			               settings.disable_okbutt_mgdialg() ;
			               settings.show_message("Retrieving Links...");    
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
		}
	
	};
	
	
	
$(document).ready(function(){
    
    links.init();  

});

