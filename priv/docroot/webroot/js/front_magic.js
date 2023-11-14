/* 
*This file is responsible for translating the messsages that come into forms that can be seen onscreen 
*will show the messages on screen and parse them and probably give them some color based on the response code 
*/

$(document).ready(function(){

	front_magic.init();

	}); 


var front_magic = {
	  
	transaction_table:("#table_info tbody"),
	max_rows :15,
	current_num:0,
	message :{},

	
	//this function is for initializing the websocket object 
	//it also contains most functions for dealing with the websocket  
	init:function(){
		_this = this ;


		//click behaviour to toogle connection/disconnection
		$(".toggle_connect").live('click',function(e){
		
		});
		
		webs = new wsClient("localhost", "8004","erl_mon/websock/setup");
		var arrayBuffer;
		var view;
		webs.onMessage=function(data){
		arrayBuffer = data.data;
		view = new Uint8Array(arrayBuffer);
		front_magic.message = Inaka.Jem.decode(arrayBuffer);
		front_magic.process_message(front_magic.message);
		};
		webs.connect();
		
	},	
		
	//this is for building an item which can be appended to the main table div	
	//have to sanitize data before putting in browser
	build_item:function(message){
		_this = this ;
		
		var tr_all=document.createElement("tr");
		var pan=document.createElement("td");
        $(pan).html((message[2])? message[2] : "");
     
		var pr_code=document.createElement("td");
        $(pr_code).html((message[3])? message[3] : "");
     
		var amount=document.createElement("td");
        $(amount).html((message[4])? message[4] : "");
     
		var stan=document.createElement("td");
        $(stan).html((message[11])? message[11] : "");
		
		var date_time_trans=document.createElement("td");
        $(date_time_trans).html((message[12])? message[12] : "");
		
		var pos_code=document.createElement("td");
        $(pos_code).html((message[22])? message[22] : "");
        
        var termid=document.createElement("td");
        $(termid).html((message[41])? message[41] : "");
		
		var term_location=document.createElement("td");
        $(term_location).html((message[43])? message[43] : "");
        
        var response_code=document.createElement("td");
        $(response_code).html((message[39])? message[39] : "");
				
		$(tr_all).append(pan).append(pr_code).append(amount)
				 .append(stan).append(date_time_trans)
				 .append(pos_code).append(termid)
				 .append(term_location).append(response_code);
		return tr_all; 
       
	},
	//this function is for processing the messags as they come through 
	process_message:function(message){
	   _this = this ;
	   _this.current_num++;
	   if (_this.current_num>=_this.max_rows){
		   //console.log("limit reached");
		    $(_this.transaction_table+" tr:first").remove();
			$(_this.transaction_table).prepend(_this.build_item(message)); 
	    }
	   else{
			$(_this.transaction_table).prepend(_this.build_item(message)); 
	
		}	
		//console.log("total number is "+_this.current_num);
	}
}
