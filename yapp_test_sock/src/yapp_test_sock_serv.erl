
-module(yapp_test_sock_serv).
-behaviour(gen_server).

-record(state, {name, % player's name
                next, % next step, used when initializing
                socket}). % the current socket

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).

-define(SOCK(Msg), {tcp, _Port, Msg}).
-define(TIME, 800).
-define(EXP, 50).

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
handle_cast(accept, S = #state{socket=ListenSocket}) ->
		{ok, AcceptSocket} = gen_tcp:accept(ListenSocket),
		send(AcceptSocket, "What's your character's name?", []),
		{noreply, S#state{socket=AcceptSocket, next=name}};

%% unknown casts
handle_cast(_, S) ->
		{noreply,S}.


handle_info(?SOCK(Str), S = #state{next=name,socket=AcceptSocket}) ->
		Name = line(Str),
		io:format("My name is ~p",[Name]),
		send(AcceptSocket, "Thanks for the name.Lets begin", []),		
		{noreply, S#state{name=Name, next=stats}};


handle_info(?SOCK(Str), S = #state{socket=Socket}) ->
		%%Data = line(Str),
		io:format("Socket Information is ~n~p",[Str]),
		send(Socket, "Repeat message is : ~p~n", [Str]),
		{noreply, S};
    
    
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
    
    
terminate(_Reason, _State) ->
		io:format("terminate reason: ~p~n", [_Reason]).


send(Socket, Str, Args) ->
		ok = gen_tcp:send(Socket, io_lib:format(Str++"~n", Args)),
		ok = inet:setopts(Socket, [{active, once}]),
		ok.

%% Let's get rid of the whitespace and ignore whatever's after.
%% makes it simpler to deal with telnet.
line(Str) ->
    hd(string:tokens(Str, "\r\n")).
