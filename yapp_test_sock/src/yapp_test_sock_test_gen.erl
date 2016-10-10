%%%
%%% @doc yapp_test_sock_test_gen_serv module.
%%%<br>contains module for iso server tester </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(yapp_test_sock_test_gen).
-behaviour(gen_server).
   

-export([start_link/0,test_client/1,send_iso/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).   
   
   
-record(state, {iso_message=[],socket,port,state_test}). % the current socket containing the iso message  
-define(SOCK(Msg), {tcp, _Port, Msg}).
-define(BH,2).
-type state() :: #state{}.

 
 %% @doc api call for checking whether mesages can be sent through the socket
-spec test_client(atom())->ready_to_send|not_ready.
test_client(Name) ->
		gen_server:call(Name, test_client).
    
 
 %% @doc api call for sending test iso messages
-spec send_iso(atom())->message_sent|not_ready|{error,any()}.    
send_iso(Name) ->
		gen_server:call(Name, send_iso).
       
	
%%for starting the gen server 
%% @doc api call  starts up the process for monitoring the socket processes   
-spec start_link() ->{ok, pid()} | {error, any()}.
start_link() ->
		gen_server:start_link({local, tester}, ?MODULE,[], []).

%% 
%% @doc Gen server for tester 
-spec init([]) -> {ok, state()}|{error,any()}.
init([]) ->
		{ok, Port} = application:get_env(port),
		<<A:32, B:32, C:32>> = crypto:rand_bytes(12),
		random:seed({A,B,C}),
		gen_server:cast(self(), start_tester),
		{ok, #state{port=Port,state_test=bad}}.
    
   
create_message()->
		% Create a message.
		%Message = ".U123000......0000000000000001000129271610011023490641424300080000001811234567890101826" .
		Message = "0f0200B2200000001000000000000000800000201234000000010000110722183012345606A5DFGR021ABCDEFGHIJ 1234567890".
		%Message = ".g121000......000000000000002059012883161001075456064142430008000000181123456789010182608....vT2...\"3DUfw".
		
			 
%% @doc for testing for sending messages 
-spec handle_call(term(),pid(),state()) -> term().   
handle_call(send_iso, _From,S = #state{socket=Socket,state_test=State_test}) ->
		case State_test of 
			good ->
				Message = create_message(),
				io:format("~nlength of message si ~p",[length(Message)]),
				send(Socket,Message),				
				{reply,message_sent,S};
			_ ->
				{reply,not_ready,S}
		end;	
    
    
%% @doc for testing for health
handle_call(test_client, _From,S = #state{state_test=State_test})when State_test =:=good ->
%%do what you want to do 	
		case State_test of 
			good ->
				
				{reply,ready_to_send,S};
			bad ->
				{reply,not_ready,S}
		end;	
	
		
%%for unknown messages  
handle_call(_, _From,S) ->
		{reply,fuck_off,S}.
	
		
%% @doc connecting to iso  server
-spec handle_cast(term(),state()) -> {term(),state()}.   
handle_cast(start_tester, S = #state{port=Port}) ->
		{ok, Sock} = gen_tcp:connect("localhost", Port, [list, {packet, 0}, {active, true}]),
		io:format("#########connected to iso server ###########"),
		{noreply, S#state{socket=Sock,state_test=good}};		    
 
 
 %% unknown casts
handle_cast(_, S) ->
		{noreply,S}.


%% @doc this guy here is for getting messages from the socket	
-spec handle_info(term(),state()) -> {term(),state()}.  
handle_info(?SOCK(Str), S = #state{socket=Socket}) ->
		io:format("~n~n~n~nData passing through is ~p",[Str]),
		%%send(AcceptSocket, "Thanks for the name.Lets begin"),		
		{noreply, S};
      
 
%% @doc this guy here is trying to reconnect socket after socket is closed for a reason 	
handle_info({tcp_closed, _Socket}, S) ->
		gen_server:cast(self(), start_tester),
		{noreply, S#state{state_test=bad}};		    
    

%% @doc this guy here is closing the socket 	 
handle_info({tcp_error, _Socket, _}, S) ->
		{stop, normal, S};
		
		
 %%info coming in from as a result of messages received maybe from othe processes 
handle_info(_, S) ->
		{noreply, S}.		
		
    
%% @doc for code changes
-spec code_change(string(),state(),term())->{ok,state()}|{error,any()}.    
code_change(_OldVsn, State, _Extra) ->
		{ok, State}.

%% @doc for termination
-spec terminate(term(),state())->ok.
terminate(normal, #state{socket=S}) ->
		gen_tcp:close(S);
    
    
terminate(shutdown, #state{socket=S}) ->
		gen_tcp:close(S);
    
    
terminate(_Reason, _State) ->
		io:format("terminate reason: ~p~n", [_Reason]).

%% @doc for sending information through the socket
-spec send(port(),[pos_integer()])->ok|{error,any()}.
send(Socket, Str) ->
		gen_tcp:send(Socket,Str).
		
