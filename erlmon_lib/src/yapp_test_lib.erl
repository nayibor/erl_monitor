%%% 
%%% @doc yapp_test_lib application.
%%%<br>this is the starting point for the yapp_test_lib application</br>
%%%<br>the start function starts the functions and waits for the necessary table to wake up b4 starting the top level supervisor</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_lib).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").

-behaviour(application).

%%% API
-export([start/2,stop/1,send_mail/6]).

%%%=============================================================================
%%% API
%%%=============================================================================
-spec start(term(), term()) -> {error, term()} | {ok, pid()}.
start(normal, []) ->
    mnesia:wait_for_tables([usermod_users,usermod_roles,usermod_links,usermod_users_roles,usermod_users_links], 20000),
    yapp_test_lib_sup:start_link().

-spec stop(term()) -> ok.	
stop(_) -> ok.


%% @doc used for sending emails
-spec send_mail(Subject_email::binary()|string(),From_label::binary()|string(),To_label::binary()|string(),Mail_body::binary()|string(),Send_list::[string()],Callback::fun())->{ok,pid()}|{error,term()|any()}.
send_mail(Subject_email,From_label,To_label,Mail_body,Send_list,Callback)->
	{ok,Settings} = application:get_env(erlmon_lib,mail_settings),
	Host = proplists:get_value(host,Settings),
	Username = proplists:get_value(username,Settings),
	Password = proplists:get_value(password,Settings),
	From_address = proplists:get_value(from_email_address,Settings),
	Subject = ["Subject: ",Subject_email,"\r\n"],
	From = ["From: ",From_label,"\r\n"],
	Headers = ["MIME-Version: 1.0\r\nContent-type: text/html; charset=iso-8859-1\r\nX-Priority: 1\r\n"],
	To = ["To: ",To_label,"\r\n\r\n"],
	Mail_send_body = lists:flatten([Subject,From,Headers,To,Mail_body]),
	Tuple_email_send = {From_address,Send_list,Mail_send_body},
	Options_email = [{relay, Host}, {username, Username}, {password, Password},{auth,always},{tls,always},{hostname,Host}],
	gen_smtp_client:send(Tuple_email_send,Options_email,Callback).

