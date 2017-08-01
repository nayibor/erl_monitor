/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 * this is a class wrapper for the websocket connection  
 */
var WS = false;
     if (window.WebSocket) WS = WebSocket;
     if (!WS && window.MozWebSocket) WS = MozWebSocket;
     if (!WS)
        alert("WebSocket not supported by this browser");

var wsClient = function(server_ip, server_port,cont_act) {
	    
	    var client =this ;    
	    this.socket=null;
	    this.url=null;
	    this.connection_options=null;
	    this.setup_timer=null;
	    
	    //this is for connecting and loading up the websocket callbacks 
	    this.connect=function(){
	        var url="ws://"+server_ip+":"+server_port;
	        client.url=url;
	        client.socket=new WS(url+"/"+cont_act);
	        client.socket.binaryType = "arraybuffer";	      
			client.setup_events();	   
		};
		
		//this is for closing the websocket connection
	    this.close=function(){			
			client.socket.close();	
			
		};
	    
	    //for setting up the websocket callbacks
	    this.setup_events=function(){
	        client.socket.onopen = client.onConnect;    
	        client.socket.onclose = client.onClose; 
	        client.socket.onmessage = client.onMessage; 
	        client.socket.onerror=client.onError;
	        
	    };
	    
	    //error callback
	    this.onError=function(error){
			console.log('WebSocket Error: ' + error);	
		};
	    //connection callback
	    this.onConnect = function() {   
			console.log("WebSocket Connected");
	    };    
	   //message callback 
	    this.onMessage = function(data) {
	    };
	  //disconnect callback  
	    this.onClose = function() {  
			console.log("WebSocket Disconnected:");		
			client.setup_timer=setTimeout(function(){
			   if(client.socket.readyState == 1)
					{clearInterval(client.setup_timer);}
			   else
			   {client.connect();}
			}, 500);		
	    };
	    //send callback
	    this.send=function(msg){    
	        if(client.socket.readyState == 1 ){          
				client.socket.send(msg);
			} 
			else{
				console.log("client not in ready state");
			}
	    }

}
