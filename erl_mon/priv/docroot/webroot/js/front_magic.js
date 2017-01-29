/* 
*This file is responsible for translating the messsages that come into forms that can be seen onscreen 
* will show the messages on screen and parse them and probably give them some color based on the response code 
*/
//webs.send(msgpack.encode({"foo": [1,2,3,3,3,3,3,{1:2}]}));
//webs.send(msgpack.encode({"foo": [1,2,34,5,5,1,21,21,123122,{1:2}]}));
// encode from JS Object to MessagePack (Buffer)
//	var buffer = msgpack.encode({"foo": "bar"});
//	console.log("encoded object is ");
//	console.log(buffer);
// decode from MessagePack (Buffer) to JS Object
//	var data = msgpack.decode(buffer); // => {"foo": "bar"}
//	console.log("decoded object is ");
//   console.log(data);


$(document).ready(function(){

	front_magic.init();

	}); 


var front_magic = {
	  
	transaction_table:("#table_info tbody"),
	max_rows :15,
	current_num:0,

	
	//this function is for initializing the websocket object 
	//it also contains most functions for dealing with the websocket  
	init:function(){
		_this = this ;


		//click behaviour to toogle connection/disconnection
		$(".toggle_connect").live('click',function(e){
		
		});
		
		
		//var strWindowFeatures = "location=yes,height=570,width=520,scrollbars=yes,status=yes";
		//var URL = "https://www.linkedin.com/cws/share?mini=true&amp;url=" + location.href;
		//var win = window.open(URL, "_blank", strWindowFeatures);
		
		

		webs = new wsClient("localhost", "8004","erl_mon/websock/setup");
		//callbacks are being used for various printing functionality
		webs.onMessage=function(data){

		var message = msgpack.decode(new Uint8Array(data.data));
		//console.log(message);
		front_magic.process_message(message);
		};
		
		        
		webs.connect();
		
	},	
		
	//this is for building an item which can be appended to the main table div	
	build_item:function(message){
		_this = this ;
		var tr_all=document.createElement("tr");
		
		var pan=document.createElement("td");
        $(pan).html((message['_2'])? message._2.toString() : "");
     
		var pr_code=document.createElement("td");
        $(pr_code).html((message['_3'])? message._3.toString() : "");
     
		var amount=document.createElement("td");
        $(amount).html((message['_4'])? message._4.toString() : "");
     
		var stan=document.createElement("td");
        $(stan).html((message['_11'])? message._11.toString() : "");
		
		var date_time_trans=document.createElement("td");
        $(date_time_trans).html((message['_12'])? message._12.toString() : "");
		
		var pos_code=document.createElement("td");
        $(pos_code).html((message['_22'])? message._22.toString() : "");
        
        var termid=document.createElement("td");
        $(termid).html((message['_41'])? message._41.toString() : "");
		
		var term_location=document.createElement("td");
        $(term_location).html((message['_43'])? message._43.toString() : "");
        
        var response_code=document.createElement("td");
        $(response_code).html((message['_39'])? message._39.toString() : "");
				
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
			$(_this.transaction_table).append(_this.build_item(message)); 
	    }
	   else{
			$(_this.transaction_table).append(_this.build_item(message)); 
	
		}	
		//console.log("total number is "+_this.current_num);
	}
}
