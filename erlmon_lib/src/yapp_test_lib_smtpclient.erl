%%%
%%% @doc erlmon_worker_pool_smtpclient.
%%%<br>module for smtp connection pool stuff</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(yapp_test_lib_smtpclient).
-behaviour(gen_server).
-export([ start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).


-record(state, {conn_det,timeout}).
-type state() :: #state{}.


%% @doc this is the startup process which will start the odbc client and use it as part of the pool  
-spec start_link(Conn_details::tuple()) ->{ok, pid()} | {error, any()}.
start_link(Conn_details)->
    gen_server:start_link(?MODULE,Conn_details, []).


%% @doc init for starting up the gen server 
-spec init(Conn_details::tuple()) -> {ok, state()}.
init(Conn_details) ->
    %%io:format("~n my pid is ~p",[self()]),
    process_flag(trap_exit, true),
    {ok, #state{conn_det=Conn_details}}.


%% @doc this callback is used for stopping
handle_call(stop, _From, State) ->
    {stop, exit, ok,State};


%% @doc this callback is for getting the state of a worker 
handle_call(get_state, _From,S)->
	{reply,S,S};


%% @doc this callback is used for sending emails to the mail server  
handle_call({send_mail,{Subject_call,From_call,To_call,Mail_body_call,Send_List}}, _From,S = #state{conn_det=Conn_details})->
	[{Host,Username,Password,From_address,To_email_list}] = Conn_details,
	Subject = ["Subject: ",Subject_call,"\r\n"],
	From = ["From: ",From_call,"\r\n"],
	To = ["To: ",To_call,"\r\n\r\n"],
	Mail_send_body = lists:flatten([Subject,From,To,Mail_body_call]),
	Tuple_email_send = {From_address,Send_List,Mail_send_body},
	Options_email = [{relay, Host}, {username, Username}, {password, Password},{auth,always},{tls,always},{hostname,Host}],
	try gen_smtp_client:send(Tuple_email_send,Options_email) of
		{ok,_}->
			{reply,ok,S};
		{error,Reason}->
			error_logger:error_msg("~n Error Msg is ~p",[Reason]),
			{reply,{error,Reason},S}
	catch
		_:Reason ->
			error_logger:error_msg("n Error Msg is ~p",[Reason]),
			{reply, {error,Reason},S}
	end;

			
%% @doc this callback is for unknown calls
handle_call(_Msg, _From, State) ->
    {noreply, State}.
    

%% @doc this callback for unknown casts
handle_cast(_Msg, State) ->
    {noreply, State}.
    

%%for when emails are sent successfully
handle_info({'EXIT', _Pid, normal},State) ->
	error_logger:info_msg("~nEmail Sent Succesfully"),
	{noreply,State};
	
	
%%for when the down procoess is sent from the gen_smtp process due to some errors
handle_info({'EXIT', _Pid, Reason},State) ->
	error_logger:error_msg("~n Error Sending Message is ~p",[Reason]),
	{noreply,State};
	

%% @doc for unknown messages
handle_info(_Msg, State) ->
    {noreply, State}.


%% @doc for code changes
-spec code_change(string(),state(),term())->{ok,state()}|{error,any()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% @doc for termination
-spec terminate(term(),state())->ok.
terminate(_Reason,_State) ->
			ok.

