#What is this for

This application is for an opensource transaction monitoring system.


This system receives iso 8583 messages from diverse sources on  a tcp-ip server.  
It forwards it to a websocket server for distrubition to user browsers whom are authorized to view those messages.   
Main purpose of this application is to receive real time feedback on status of  transactions so that quick actions can be taken as opposed to polling of the database or other non real time means of monitoring.

##Components##

   Backend web application/mis system for:

* creating,reading,updating users
* performing access management for users
* for creating rules which represent a filter for messages
* for adding and removing users from the rules 


Web application and tcp server built on erlang stack(yaws,mnesia,erlydtl):  

* [yaws](yaws.hyber.org) is erlang web server
* [mnesia](http://erlang.org/doc/man/mnesia.html) is database management system packaged with erlang
* [erlydtl](https://github.com/erlydtl/erlydtl) erlang templating system based on django  
* [ranch](https://github.com/ninenines/ranch) socket library used for the tcp server
* [jem.js](https://github.com/inaka/jem.js/tree/master) used for the serialization of js data to erlang term format when communicating with websocket


The ```erl_mon application``` is the web application.

The ```erlmon_sock``` is the the tcp server.

The ```erlmon_lib``` contains libraries used by ```erlmon_sock``` and ```erl_mon```.

A release is being worked on and will be done soon with instructions for installation as well as converting to rebar3 . 


