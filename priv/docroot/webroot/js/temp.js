
var temp = {
	
//for add_temp/edit_temp div
edit_temp_div:("#edit_temp_div"),


//fo configuring the temp div
configure_temp_div:function(){
		
					  var diag = $(temp.edit_temp_div);
			        
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
								temp.checkfields();
			                }
			               
			            }
			        });
			    
			        diag.dialog('close');	
        
		},
		
		
//for validation form fields before template is sent to the server 		
checkfields:function(){
	
					_this=this;	
					var link=$("#save_add_temp").val(); 
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
						temp.saveTemp(link);
					}
					else{
			
						settings.show_message("Please Enter All Fields In Correct Format");
					}
	
		},		
		
		
//for saving the template
saveTemp:function(link){
		
					var formdata=$("#add_temp_form.cmxform").serialize(); 
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
								$(temp.edit_temp_div).dialog('close');	                   
								temp.load_temp($("#search_temp_url").val()); 
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


//initializes various events for elements 
init:function(){
	
	
					 temp.configure_temp_div();
		
				 //searching for a link when the search button is clicked
			          $("#search_temp_butt").live('click',function(e) {
			            e.preventDefault();
			            var link = $("#search_temp_url").val();
			              temp.load_temp(link); 
					}); 
			        
			       
			        
			           //for searching for a link when the enter button is presed
			        $("#add_temp").live('click',function(e) {
			            e.preventDefault();
			            var link = $("#get_add_temp").val();
			            temp.load_addtemp(link); 
			        }); 
			        
			        //for editing templates
			        $(".edit_temp").live('click',function(e) {
			            e.preventDefault();
			            var link = $(this).attr("href");
			            temp.load_addtemp(link); 
			        }); 
			        
			        
			           
			         //for searching for a link when the enter button is presed
			        $("#search_template").live('keyup',function(e) {
			            e.preventDefault();
			            var link = $("#search_temp_url").val();
			            if(e.which==13){
			              temp.load_temp(link); 
			            }
			        });	
			        
			        
			          //for deleting a template and rules associated with the template
			        $(".del_temp").live('click',function(e) {
			            e.preventDefault();
			            var link =  $(this).attr( "href");
			            settings.confirmation_action=function(){
							temp.del_temp(link);
							}
			            settings.show_confirmation("Are You Sure You Want To Delete Template ?<br>"+
									"Deleting Templates Deletes All Rules Associated With Template");
			            
			        });
			        
			        
				},
			
				
//for deleting templates				
del_temp:function(link){
					$.ajax({
			            url: link,
			            type:"DELETE",
			            dataType:'html',
			            beforeSend:function(){
			               settings.disable_okbutt_mgdialg() ;
			               settings.show_message("Deleting Template...");    
			            },
			            success:function(Data) {
							settings.show_message(Data); 
							settings.confirmation_action=function(){};
				                setTimeout(function() {
								temp.load_temp($("#search_temp_url").val()); 
							}, 2000);
			       
			            },
			            error:function(Data){
							settings.enable_okbutt_mgdialg();
							settings.show_message(Data.responseText);      
				                  
			            }
			        });
			
		},
		
				
//for loading the div for adding templates				
load_addtemp:function(link){
		
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
			               $("#edit_temp_div").html(Data);
			               $(temp.edit_temp_div).dialog('open');
			       
			            },
			            error:function(Data){
			               settings.enable_okbutt_mgdialg();
			               settings.show_message("Error<br>"+"Please Try Again");      
			            }
			        }); 		
					
				},
					
        
 //for loading the div when a seach is made for a template        
load_temp:function(link){
		
					 val = $("#search_template").val();
					 $.ajax({
			            url: link,
			            type:"GET",
			            dataType:'html',
			            data:(val!="") ? "filter="+val : "",
			            beforeSend:function(){
			               settings.disable_okbutt_mgdialg() ;
			               settings.show_message("Searching Templates...");    
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
    
    temp.init();  

});

	

