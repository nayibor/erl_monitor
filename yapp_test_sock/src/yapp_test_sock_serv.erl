
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
		case length(State_new) of 
			Size when Size < 4 -> 
				{noreply, S#state{iso_message=State_new}};
			_  ->
				{LenStr, Rest} = lists:split(4, State_new),
				Len = list_to_integer(LenStr) + 4,
				case length(State_new) of 
					SizeafterHead when Len =:= SizeafterHead ->
						io:format("Received:~n~s~n", [Rest]),
						Response = erl8583_marshaller_ascii:unmarshal(Rest),
						% Display the MTI from the response.
						io:format("~nMTI: ~s~n", [erl8583_message:get(0, Response)]),
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

 
