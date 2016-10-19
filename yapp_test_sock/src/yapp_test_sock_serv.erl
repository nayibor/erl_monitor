%%%
%%% @doc yapp_test_sock_serv module.
%%%<br>this module is responsible for accepting conections from external interfaces and passing it to the asci processor for furthe processing </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>


-module(yapp_test_sock_serv).
-behaviour(gen_server).

-record(state, {iso_message=[],socket}). % the current socket



-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).
 
 %% macros for messages received on socket
-define(SOCK(Msg), {tcp, _Port, Msg}).
%%for header size of incoming message
-define(BH,4).

-type state() :: #state{}.


%% @doc this is used for starting an accepting socket with Socket Listener passed as a parameter
-spec start_link(port()) ->{ok, pid()} | {error, any()}.
start_link(Socket) ->
		gen_server:start_link(?MODULE, Socket, []).


%% @doc callback for genserver,accepts a Socket as input  
-spec init(port()) ->{ok, pid()} | {error, any()}.
init(Socket) ->
		<<A:32, B:32, C:32>> = crypto:rand_bytes(12),
		random:seed({A,B,C}),
		gen_server:cast(self(), accept),
		{ok, #state{socket=Socket}}.


%% @doc this call is for all call messages 
-spec handle_call(term(),pid(),state()) -> term().
handle_call(_E, _From, State) ->
		{noreply, State}.


%% @doc Accepting a connection
%%counter application is notified of connected client
-spec handle_cast(term(),state()) -> {term(),state()}.    
handle_cast(accept, S = #state{socket=ListenSocket}) ->
		{ok, AcceptSocket} = gen_tcp:accept(ListenSocket),	
		(catch gproc:reg({p, l,<<"conn_sock">>}, ignored)),
		{noreply, S#state{socket=AcceptSocket}};
		
		
%% unknown casts
handle_cast(_, S) ->
		{noreply,S}.


%% @doc handles connections and proceses the iso messages which are sent through the connection 
%% this function is the main entry point into the application from external sockets which are connected to it 		
-spec handle_info(term(),state()) -> {term(),state()}.    
handle_info(?SOCK(Str_Prev), State_old = #state{socket=AcceptSocket_process,iso_message=Isom_so_far}) ->

		Fun_process_trans = fun({_tcp,_Port_Numb,Msg}, S = #state{socket=AcceptSocket,iso_message=Isom})->
			State_new=Isom++Msg,
			%%io:format("~nfull message is ~n~s~nlength is ~p~n",[State_new,length(State_new)]),		
			case length(State_new) of 
				Size when Size < ?BH -> 
					%%io:format("smaller size  is ~p,~n~n~n",[State_new]),
					{noreply, S#state{iso_message=State_new}};
				_  ->
					{LenStr, Rest} = lists:split(?BH, State_new),
					%%io:format("~n --length of header string is ~p -- string for header ~w -- length of  message is ~p",[length(LenStr),LenStr,length(Rest)]),
					Len = erlang:list_to_integer(LenStr)+?BH,
					case length(State_new) of 
						SizeafterHead when Len =:= SizeafterHead ->	
							%%io:format("~nabout to process mesage"),
							FlData = yapp_test_ascii_marsh_jpos:process_iso_message(Rest),
							send(AcceptSocket,State_new),						
							Message_send_list = yapp_test_lib_dirtyproc:process_message(FlData),
						    case Message_send_list of
								{error,_Reason}->
									{noreply, S#state{iso_message=[]}};
								_ ->
									_Status_Send = [{I, (catch gproc:send({n, l, I},{transaction_message,FlData}))} || I <- Message_send_list],
									{noreply, S#state{iso_message=[]}}    	
							%%io:format("~n~nSending Statuses ~p",[Status_Send]),
							end;
						SizeafterHead when Len < SizeafterHead ->
							io:format("~nbits and pieces"),
							{noreply, S#state{iso_message=State_new}}
					end
			end
		
		
		end,
		
		try Fun_process_trans(?SOCK(Str_Prev), State_old = #state{socket=AcceptSocket_process,iso_message=Isom_so_far}) of
        S ->
			S	
		catch
			error:X ->
			%%error message has to marshalled here and sent back to sender at this point 
			%%%all of message may not have been streamed in so in the meantime a return message should be formated and sent back to sender
				send(AcceptSocket_process,Isom_so_far++Str_Prev),
				io:format("~nError Message ~p ~nwith input ~p",[erlang:get_stacktrace(),X]),
				{noreply, State_old#state{iso_message=[]}}
		end;
         
	 		 	
handle_info({tcp_closed, _Socket}, S) ->
		io:format("~nSocket Closed"),							
		{stop, normal, S};
    
    
handle_info({tcp_error, _Socket, _}, S) ->
		{stop, normal, S};
    
    
%% @doc info coming in from as a result of messages received maybe from othe processes 
handle_info(E, S) ->
		io:format("~nunexpected message: ~p", [E]),
		{noreply, S}.


%% @doc for code changes
-spec code_change(string(),state(),term())->{ok,state()}|{error,any()}.
code_change(_OldVsn, State, _Extra) ->
		io:format("~nupgrading your ass!!! " ),
		{ok, State}.


%% @doc for termination
-spec terminate(term(),state())->ok.
terminate(normal, #state{socket=S}) ->
		gen_tcp:close(S);
    
    
terminate(shutdown, #state{socket=S}) ->
		gen_tcp:close(S);

    
terminate(_Reason, #state{socket=S}) ->
		gen_tcp:close(S),
		io:format("~nterminate reason: ~p", [_Reason]).

%% @doc for sending information through the socket
-spec send(port(),[pos_integer()])->ok|{error,any()}.
send(Socket, Str) ->
		gen_tcp:send(Socket,Str).
	
