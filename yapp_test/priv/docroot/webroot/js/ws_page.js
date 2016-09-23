/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


$(document).ready(function(){

    
    webs = new wsClient("localhost", "8004","yapp_test/websock/setup");
    //callbacks are being used for various printing functionality
    webs.onMessage=function(data){
		console.log(data);
		console.log("decoded message is ");
		var message = msgpack.decode(new Uint8Array(data.data));
		console.log(message);

		

	};        

    webs.connect();

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

});


var page_test = {
	
	init:function(){
		
		
		
	}
	
	
	}
