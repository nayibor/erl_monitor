
-module(yapp_test_sock_serv).
-behaviour(gen_server).

-record(state, {iso_message=[],socket}). % the current socket



-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).

-define(SOCK(Msg), {tcp, _Port, Msg}).
-define(TIME, 800).
-define(EXP, 50).
-define(BH,2).


start_link(Socket) ->
		gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
		<<A:32, B:32, C:32>> = crypto:rand_bytes(12),
		random:seed({A,B,C}),
		gen_server:cast(self(), accept),
		{ok, #state{socket=Socket}}.

handle_call(_E, _From, State) ->
		{noreply, State}.


%% Accepting a connection
%%counter application is notified of connected client
handle_cast(accept, S = #state{socket=ListenSocket}) ->
		{ok, AcceptSocket} = gen_tcp:accept(ListenSocket),
		{ok, Name} = application:get_env(name),
		gen_server:cast(Name, {notify_connect,self()}),
		{noreply, S#state{socket=AcceptSocket}};

handle_cast(okay_connect,S)->
		{noreply,S};
		
%% unknown casts
handle_cast(_, S) ->
		{noreply,S}.


handle_info(?SOCK(Str), S = #state{socket=AcceptSocket,iso_message=Isom}) ->
		State_new=Isom++Str,
		%%io:format("~nfull message is ~n~s~nlength is ~p~n",[State_new,length(State_new)]),
		case length(State_new) of 
			Size when Size < 2 -> 
				%%io:format("smaller size  is ~p,~n~n~n",[State_new]),
				{noreply, S#state{iso_message=State_new}};
			_  ->
				{LenStr, Rest} = lists:split(2, State_new),
				%%io:format("clength is ~p~n~w~n~s~n",[length(LenStr),LenStr,Rest]),
				Len = lists:nth(2,LenStr) + 2,
				case length(State_new) of 
					SizeafterHead when Len =:= SizeafterHead ->
					io:format("~nlength is ~p ~nfull message is:~n~s", [Len-2,Rest]),
					io:format("~nrequest_mti:~s",[lists:sublist(Rest,4)]),
					io:format("~nin progress primary bitmap is ~p ",[lists:sublist(Rest,5,16)]),
					io:format("~nprimary is ~p ",[lists:map(fun(X)->string:right(integer_to_list(X,2),8,$0)end,lists:sublist(Rest,5,8))]),
					io:format("~nflattend primary bitmap in binary  is ~p ",[lists:flatten(lists:map(fun(X)->string:right(integer_to_list(X,2),8,$0)end,lists:sublist(Rest,5,8)))]),
					io:format("~nfirst value is ~p and first binary bitmap:~p and hex value is ~p",[lists:nth(5,Rest),string:right(integer_to_list(lists:nth(5,Rest),2),8,$0),integer_to_list(lists:nth(5,Rest),16)]),
						% Display the MTI from the response.
						{noreply, S#state{iso_message=[]}};
					SizeafterHead when Len < SizeafterHead ->
						{noreply, S#state{iso_message=State_new}}
				end
		end;
	 		 	
 
    
handle_info({tcp_closed, _Socket}, S) ->
		{stop, normal, S};
    
    
handle_info({tcp_error, _Socket, _}, S) ->
		{stop, normal, S};
    
 %%info coming in from as a result of messages received maybe from othe processes 
handle_info(E, S) ->
		io:format("unexpected: ~p~n", [E]),
		{noreply, S}.

code_change(_OldVsn, State, _Extra) ->
		{ok, State}.


terminate(normal, #state{socket=S}) ->
		gen_tcp:close(S);
    
terminate(shutdown, #state{socket=S}) ->
		gen_tcp:close(S);

    
terminate(_Reason, _State) ->
		io:format("terminate reason: ~p~n", [_Reason]).


send(Socket, Str) ->
		ok = gen_tcp:send(Socket,Str).

 
