-module(yapp_test_sock_emevent).
-behaviour(gen_event).

-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3,
         terminate/2]).

init([]) ->
    {ok, []}.


%% @doc this event will send the received message to email addresses
handle_event({trans,_FlData,_Send_list}, State) ->
   {ok, State}.

handle_call(_, State) ->
    {ok, ok, State}.

handle_info(_, State) ->
    {ok, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.
