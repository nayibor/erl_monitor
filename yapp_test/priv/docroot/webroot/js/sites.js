
var sites ={
	
	edit_site_div:("#edit_site_div"),
	
	configure_site_div:function(){
		
		  var diag = $(sites.edit_site_div);
        
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
					sites.checkfields();
                }
               
            }
        });
    
        diag.dialog('close');
		
		
		
		},
		
	checkfields:function(){
		
		_this=this;	
		var link=$("#save_add_site").val(); 
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
			sites.saveSite(link);
		}
		else{

			settings.show_message("Please Enter All Fields In Correct Format");
		}
			
		},	
		
	saveSite:function(link){
		
		var formdata=$("#add_site_form.cmxform").serialize(); 
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
					$(sites.edit_site_div).dialog('close');	                   
					sites.load_search_sites($("#search_site_url").val()); 
				}, 2000);	
	               //$("#add_edit_user").html(Data);
	               //$(_this.add_edit_diag).dialog('close');
	       
	            },
	            error:function(Data){
	               settings.enable_okbutt_mgdialg();
	               settings.show_message(Data.responseText);      
	            }
	        }); 
		
		}
	   ,
	
	init:function(){
		
		  sites.configure_site_div();
		
	 //searching for a link when the search button is clicked
          $("#search_site_butt").live('click',function(e) {
            e.preventDefault();
            var link = $("#search_site_url").val();
              sites.load_search_sites(link); 
		}); 
        
        //for searching for a link when the enter button is presed
        $("#search_site").live('keyup',function(e) {
            e.preventDefault();
            var link = $("#search_site_url").val();
            if(e.which==13){
              sites.load_search_sites(link); 
            }
        });	
		
		
		  
         //for searching for a link when the enter button is presed
        $("#add_site").live('click',function(e) {
            e.preventDefault();
            var link = $("#get_add_site").val();
            sites.load_addsite(link); 
        }); 
		
		$(".edit_site").live('click',function(e) {
            e.preventDefault();
            var link = $(this).attr("href");
            sites.load_addsite(link); 
        }); 
		
		},
		
		load_addsite:function(link){
		
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
               $("#edit_site_div").html(Data);
               $(sites.edit_site_div).dialog('open');
       
            },
            error:function(Data){
               settings.enable_okbutt_mgdialg();
               settings.show_message("Error<br>"+"Please Try Again");      
            }
        }); 		
		
		},
		
	 load_search_sites:function(link){
		 val = $("#search_site").val();
		$.ajax({
            url: link,
            type:"GET",
            dataType:'html',
            data:(val!="") ? "filter="+val : "",
            beforeSend:function(){
               settings.disable_okbutt_mgdialg() ;
               settings.show_message("Searching Sites...");    
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
    
    sites.init();  

});

