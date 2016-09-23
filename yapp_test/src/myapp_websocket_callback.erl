%%%
%%% @doc this is the callback for processing websocket requests
%%%<br>websocket handling will go on in this module</br> 
%%%<br>myapp_websocket_callback  module </br>
%% <br>all messages will be based on the messagepack binary encoding format </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_websocket_callback).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").



%% Export for websocket callbacks
-export([init/1,terminate/2,handle_open/2,handle_message/2,say_hi/1,handle_info/2]).


-include_lib("yaws/include/yaws_api.hrl").
-include_lib("yapp_test/include/yapp_test.hrl").

-record(user_state, {state_user,iso_message=[],state_test=bad}). % the current socket containing the iso message  


init( [_ReqArg,InitialState])->
		io:format("User State is ~p and pid is ~p ~n ",[InitialState,self()]),
		{ok, #user_state{state_user=InitialState}}.

handle_open(WSState, State) ->
	io:format("connection upgraded"),
    {ok, State#user_state{state_test=good}}.

handle_message({text, <<"bye">>},State) ->
		io:format("User said bye.~n", []),
		{close, normal,State};

handle_message({text, <<"something">>},State) ->
		io:format("Some action without a reply~n", []),
		{noreply,State};

handle_message({text, <<"say hi later">>},State) ->
		io:format("saying hi in 3s.~n", []),
		timer:apply_after(3000, ?MODULE, say_hi, [self()]),
		{reply, {text, <<"I'll say hi in a bit...">>},State};

handle_message({text, Message},State) ->
		io:format("basic echo handler got ~p~n", [Message]),
		io:format("current user state is ~p~n",[State]),
		{reply, {text, <<Message/binary>>},State};

handle_message({binary, Message},State) ->
		Updata = msgpack:unpack(Message), 
		io:format("~nunpacked data is ~p~n",[Updata]),
		NewData  = maps:from_list(lists:map(fun(X)->{X,X}end,lists:seq(1,10))),
		M = #{<<"a">> => 100, <<"b">> => 2123423.23234, <<"c">> => NewData,<<"d">>=>list_to_binary(lists:seq(1,50))},
		Sample_message = msgpack:pack(M),
		{reply,{binary,Sample_message},State};

handle_message({close, Status, _Reason},State) ->
		{close, Status,State}.
    

handle_info(close, State) ->
		io:format("closing message bye for now"),
		{close, <<"testing">>,{text, <<"see you in a bit">>},State};   
     
handle_info(Message, State) ->
		io:format("message received is ~p~n",[Message]),
		Frwder = list_to_binary(Message),
		{reply, {text, <<Frwder/binary>>},State}.
	
     
terminate(Reason, State) -> 
		io:format("terminate ~p: ~p (state:~p)~n", [self(), Reason, State]),
		ok.

          
say_hi(Pid) ->
		io:format("asynchronous greeting~n", []),
		yaws_api:websocket_send(Pid, {text, <<"hi there!">>}).

