#What is this for

This application is for an opensource transaction monitoring system.


This system receives iso8583 financial  messages from diverse sources on  a tcp-ip server.

it filters those messages based on rules but rules have to be written in erlang and also must return a boolean true or false.

If a rule matches,it's forwarded to a websocket server for distrubition to user browsers whom are authorized to view those messages.

browser will display transaction fields including field 39  which will show code which shows why transaction decline.

Main purpose of this application is to receive real time feedback on status of  financial transactions.
This is  so quick actions can be taken as opposed to polling of the database or other non real time means of monitoring.

application can be used for checking for declines,suspicious transactions,timeout etc...


##Components##

Backend web application/mis system for:

* creating,reading,updating users
* performing access management for users
* for creating rules which represent a filter for financial messages


Tcp Server for 

* receiving and parsing iso messages
* pass message through rule system to find if message matches rule .eg. is it a decline,balance enquiry,etc..
* sending parsed messages to websocket/email user channel for distribution based on active rule which match 


Web Sockets Server for

* for relaying filtered messages to browser screen so quick action can be taken if websocket channel is selected for rule

Web application,tcp server,Web Sockets  built on erlang stack(yaws,mnesia,erlydtl):  

* [yaws](http://yaws.hyber.org) is erlang web server
* [mnesia](http://erlang.org/doc/man/mnesia.html) is database management system packaged with erlang
* [erlydtl](https://github.com/erlydtl/erlydtl) erlang templating system based on django  
* [ranch](https://github.com/ninenines/ranch) socket library used for the tcp server
* [jem.js](https://github.com/inaka/jem.js/tree/master) used for the serialization of js data to erlang term format when communicating with websocket


The ```erl_mon application``` is the web application.

The ```erlmon_sock``` is the the tcp server.

The ```erlmon_lib``` contains libraries used by ```erlmon_sock``` and ```erl_mon```.

A release is being worked on and will be done soon with instructions for installation as well as converting to rebar3 . 


