


var inst = {
	
	edit_inst_div:("#edit_inst_div"),
	
	
	configure_inst_div:function(){
		
		  var diag = $(inst.edit_inst_div);
        
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
					inst.checkfields();
                }
               
            }
        });
    
        diag.dialog('close');
		
		
		
		},
	
	checkfields:function(){

		
		var link=$("#save_add_inst").val(); 
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
			inst.saveInst(link);
		}
		else{

			settings.show_message("Please Enter All Fields In Correct Format");
		}
		
		},
		
		saveInst(link){
			
			var formdata=$("#add_inst_form.cmxform").serialize(); 
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
	                $(inst.edit_inst_div).dialog('close');
	                setTimeout(function() {
					inst.load_search_inst( $("#search_inst_url").val()); 
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
		
		inst.configure_inst_div();
		//searching for a link when the search button is clicked
          $("#search_inst_butt").live('click',function(e) {
            e.preventDefault();
            var link = $("#search_inst_url").val();
              sites.load_search_sites(link); 
		}); 
        
        //for searching for a link when the enter button is presed
        $("#search_inst").live('keyup',function(e) {
            e.preventDefault();
            var link = $("#search_inst_url").val();
            if(e.which==13){
              inst.load_search_inst(link); 
            }
        });	
		
		
		  
         //for searching for a link when the enter button is presed
        $("#add_inst").live('click',function(e) {
            e.preventDefault();
            var link = $("#get_add_inst").val();
            inst.load_addinst(link); 
        }); 
		
		$(".edit_inst").live('click',function(e) {
            e.preventDefault();
            var link = $(this).attr("href");
            inst.load_addinst(link); 
        }); 
		
		},
		
		load_addinst:function(link){
		
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
               $("#edit_inst_div").html(Data);
               $(inst.edit_inst_div).dialog('open');
       
            },
            error:function(Data){
               settings.enable_okbutt_mgdialg();
               settings.show_message("Error<br>"+"Please Try Again");      
            }
        }); 		
		
		}
		,
		
		load_search_inst:function(link){
		 val = $("#search_inst").val();
		$.ajax({
            url: link,
            type:"GET",
            dataType:'html',
            data:(val!="") ? "filter="+val : "",
            beforeSend:function(){
               settings.disable_okbutt_mgdialg() ;
               settings.show_message("Searching Inst...");    
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
    
    inst.init();  

});
