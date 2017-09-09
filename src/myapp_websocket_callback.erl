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
-export([handle_info/2, handle_message/2, handle_open/2,
	 init/1, terminate/2]).

-include_lib("yaws/include/yaws_api.hrl").

-include_lib("erl_mon/include/yapp_test.hrl").

-record(user_state,
	{state_user, iso_message = [], state_test = <<"bad">>,
	 reg =
	     <<"false">>}). % the current socket containing the iso message

-type state() :: #user_state{}.

%% @doc web socket callback .
%% accepts user state_data from controlle code which it passes to the internal state of the websocket
init([_ReqArg, InitialState]) ->
    %%io:format("User State is ~p and pid is ~p ~n ",[InitialState,self()]),
    {ok, #user_state{state_user = InitialState}}.

%% @doc initial setup for user is done here with user registering itself  with gproc service so it can be passed messages.
handle_open(_WSState, State) ->
    Userid = proplists:get_value(id,
				 State#user_state.state_user),
    try register_process(Userid) of
      _Val ->
	  {ok,
	   State#user_state{state_test = <<"good">>,
			    reg = <<"true">>}}
    catch
      _:_ -> {error, <<"already_registered">>}
    end.

%% @doc for receving text mesages
handle_message({text, _Message}, State) ->
    {noreply, State};
%% @doc for receivng binary messages
handle_message({binary, _Message}, State) ->
    %%Updata = msgpack:unpack(Message),
    %%io:format("~nunpacked data is ~p~n",[Updata]),
    %%NewData  = maps:from_list(lists:map(fun(X)->{X,X}end,lists:seq(1,10))),
    %%M = #{<<"bs">>=>"testing",<<"a">> => 100,name=>"Nuku",<<"b">> => 2123423.23234, <<"c">> => NewData,<<"d">>=>list_to_binary(lists:seq(1,50))},
    %%Sample_message = msgpack:pack(M),
    {noreply, State};
%% @doc for receiving unknown messages
handle_message(_, State) -> {noreply, State}.

%% @doc for receiving close messages from other processes
handle_info(close, State) ->
    %%io:format("closing websocket bye for now"),
    {close, <<"testing">>, {text, <<"see you in a bit">>},
     State};
%% @doc for reciving transaction messages to be sent to the web browser
handle_info({<<"tdata">>, FlData}, State) ->
    {reply, {binary, FlData}, State};
%% @doc for receiving unknown messages from other processes
handle_info(_, State) -> {noreply, State}.

%% @doc for final termination of process
terminate(Reason, State) ->
    %%io:format("terminate ~p: ~p (state:~p)~n", [self(), Reason, State]),
    ok.

%% @doc for registering a user with gproc		
register_process(Userid) ->
    gproc:reg({p, l, Userid}, <<"websocket">>).
