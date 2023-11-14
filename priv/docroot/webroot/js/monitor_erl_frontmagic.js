/* 
*This file is responsible for translating the messsages that come into forms that can be seen onscreen 
*will show the messages on screen and parse them and probably give them some color based on the response code 
*/


//this is for the elm inits
//var app = Elm.Main.init({node: document.getElementById('elm_div')});

//this is for other init
$("#elm_div").ready(function(){
	var app = Elm.PortTester.init({node: document.getElementById('elm_div')});
	front_magic.init(app);

	}); 


var front_magic = {
	  
	transaction_table:("#table_info tbody"),
	max_rows :15,
	current_num:0,
	message :{},

	
	//this function is for initializing the websocket object 
	//it also contains most functions for dealing with the websocket  
	init:function(elm_app){
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
			//console.log(view);
			front_magic.message = Inaka.Jem.decode(arrayBuffer);
			//console.log(front_magic.message);
			//console.log("sent message is"+data.data+" stringify"+JSON.stringify(data.data));
			//front_magic.process_message(front_magic.message);
			elm_json = {responsecode: front_magic.message[39],time:front_magic.message[12],tname: front_magic.message[41],amount: parseInt(front_magic.message[4]) }
			elm_app.ports.messageReceiver.send(elm_json);

		};
		webs.connect();
		//for sending messages to the websocket when a command is sent to the `sendmessage` port
	/**	//elm_app.ports.sendMessage.subscribe(function(message) {
			webs.send(message);
		});	
    **/	
	}
}

