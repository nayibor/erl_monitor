#What is this for

This application is for an opensource transaction monitoring system.


This system receives iso 8583 messages from diverse sources on  a tcp-ip server.  
It forwards it to a websocket server for distrubition to user browsers whom are authorized to view those messages.   
Main purpose of this application is to receive real time feedback on status of  transactions so that quick actions can be taken as opposed to polling of the database or other non real time means of monitoring.

##Components##
   There is also a backend web application/mis system for:

* creating,reading,updating users
* performing access management for users
* for creating rules which represent a filter for messages
* for adding and removing users from the rules 


Web application and tcp server built on erlang stack(yaws,mnesia,erlydtl):  

* yaws is erlang web server
* mnesia is database management system packaged with erlang
* erlydtl is django templating done using erlang  
* messagepack,djnago templates for message format,templating


The ```erl_mon application``` is the web application.

The ```erlmon_sock``` is for now the tcp server.

The ```erlmon_lib``` contains libraries used by ```erlmon_sock``` and ```erl_mon```.

A release is being worked on and will be done soon with instructions for installation as well as converting to rebar3 . 


