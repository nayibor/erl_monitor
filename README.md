##What is this for

This application is for an opensource transaction monitoring system.


This system receives iso 8583 messages from diverse sources on  a tcp-ip server. 
Iforwards it to a websocket server for distrubition to user browsers whom are authorized to view those messages.
Main purpose of this application is to receive realtime feedback on status of transactions so that quick actions.
Can be taken as opposed to polling of the database or other non real time means of monitoring.
Monitoring system will give visual and audio cues in case of important events and may support basic analytics.


There is also a backend web application/mis system for 
*creating,reading,updating users
*performing access management for users
*for creating rules which represent a filter for messages
*for adding and removing users from the rules 


Web application and tcp server built on erlang stack(yaws,mnesia,erlydtl)
*yaws is erlang web server
*mnesia is database management system packaged with erlang
*erlydtl is django templating done using erlang  
*messagepack,djnago templates for message format,templating


The erl_mon applicaton is the web application.
The erlmon_sock is for now the tcp server.
The erlmon_lib contains libraries used by erlmon_sock and erl_mon.

A release is being worked on and will be done soon with instructions for installation as well as converting to rebar3 . 


