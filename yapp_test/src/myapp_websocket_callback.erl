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
-export([init/1,terminate/2,handle_open/2,handle_message/2,handle_info/2]).


-include_lib("yaws/include/yaws_api.hrl").
-include_lib("yapp_test/include/yapp_test.hrl").

-record(user_state, {state_user,iso_message=[],state_test= <<"bad">> ,reg= <<"false">> }). % the current socket containing the iso message  


init( [_ReqArg,InitialState])->
		io:format("User State is ~p and pid is ~p ~n ",[InitialState,self()]),
		{ok, #user_state{state_user=InitialState}}.

handle_open(WSState, State) ->
	Userid=proplists:get_value(id,State#user_state.state_user),
	try register_process(Userid) of 
	Val -> {ok, State#user_state{state_test= <<"good">> ,reg= <<"true">> }}
	catch 
	_:_ -> {ok, State#user_state{state_test= <<"good">> }}
	end.


handle_message({text, Message},State) ->
		io:format("basic echo handler got ~p~n", [Message]),
		io:format("current user state is ~p~n",[State]),
		{reply, {text, <<Message/binary>>},State};

handle_message({binary, Message},State) ->
		Updata = msgpack:unpack(Message), 
		io:format("~nunpacked data is ~p~n",[Updata]),
		NewData  = maps:from_list(lists:map(fun(X)->{X,X}end,lists:seq(1,10))),
		M = #{<<"bs">>=>"testing",<<"a">> => 100, <<"b">> => 2123423.23234, <<"c">> => NewData,<<"d">>=>list_to_binary(lists:seq(1,50))},
		Sample_message = msgpack:pack(M),
		{reply,{binary,Sample_message},State};


handle_message({close, Status, _Reason},State) ->
		{close, Status,State}.
    

handle_info(close, State) ->
		io:format("closing message bye for now"),
		{close, <<"testing">>,{text, <<"see you in a bit">>},State};   
     
handle_info(Message, State) ->
		M = #{<<"transaction">> =>Message},
		io:format("message received is ~p~n",[M]),
		Msg_out = msgpack:pack(M),
		{reply,{binary,Msg_out},State}.

     
terminate(Reason, State) -> 
		io:format("terminate ~p: ~p (state:~p)~n", [self(), Reason, State]),
		ok.

		
register_process(Userid)->
		gproc:reg({n, l, Userid}, ignored).


