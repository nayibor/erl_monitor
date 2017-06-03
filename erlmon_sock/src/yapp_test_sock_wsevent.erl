-module(yapp_test_sock_wsevent).
-behaviour(gen_event).

-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3,
         terminate/2]).

init([]) ->
    {ok, []}.

%% @doc this event will send the received message to the websocket 
handle_event({trans,FlData,Send_list}, State) ->
    Msg_out = erlang:term_to_binary(FlData),
	Socket_list = maps:get(socket_list,Send_list),
	lists:map(fun(I)-> (catch gproc:send({p, l, I},{<<"tdata">>,Msg_out})) end,Socket_list),
    {ok, State}.

handle_call(_, State) ->
    {ok, ok, State}.

handle_info(_, State) ->
    {ok, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.
