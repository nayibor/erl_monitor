#What is this for

This application is for an opensource transaction monitoring system.


This system receives iso 8583 messages from diverse sources on  a tcp-ip server.  

It then extracts the iso 8583 message from the tcp server

it then passes the message through a filter using rules written in lua via the excellent [luerl](https://github.com/rvirding/luerl) erlang package

It then forwards matched messages to a websocket server for distrubition to various user browsers.   

The purpose of this application is to receive real time feedback on status of  transactions so that quick actions can be taken as opposed to polling of the database or other non real time means of monitoring.


##Components##

Backend web application/mis system for:

* creating,reading,updating users
* performing access management for users
* for creating rules which represent a filter for messages
* for adding and removing users from the rules 

Tcp Server for 

* receiving and parsing iso messages
* pass message through rule system to find if message matches rule .eg. is it a decline,balance enquiry,etc..
* sending parsed messages to websocket/email user channel for distribution based on active rule which match 


Web application and tcp server built on erlang stack(yaws,mnesia,erlydtl):  

* [yaws](http://yaws.hyber.org) is erlang web server
* [mnesia](http://erlang.org/doc/man/mnesia.html) is database management system packaged with erlang
* [erlydtl](https://github.com/erlydtl/erlydtl) erlang templating system based on django  
* [ranch](https://github.com/ninenines/ranch) socket library used for the tcp server
* [jem.js](https://github.com/inaka/jem.js/tree/master) used for the serialization of js data to erlang term format when communicating with websocket
* [luerl](https://github.com/rvirding/luerl) used for writing the rules for filtering the iso8583 messages so it can be identified/tagged and notifications sent to various users 

The ```erl_mon application``` is the web application.

The ```erlmon_sock``` is the the tcp server.

The ```erlmon_lib``` contains libraries used by ```erlmon_sock``` and ```erl_mon```.
