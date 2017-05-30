%%%
%%% @doc yapp_test_sock_serv module.
%%%<br>this module is responsible for accepting conections from external interfaces and passing it to the asci processor for furthe processing </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>


-module(yapp_test_sock_serv).
-behaviour(gen_server).
-behaviour(ranch_protocol).

-record(state, {iso_message=[],socket,transport}). % the current socket
 

%%for ranch stuff
-export([start_link/4]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).
 
 %% macros for messages received on socket
-define(SOCK(Msg), {tcp, _Port, Msg}).
%%for header size of incoming message
-define(BH,2).

-type state() :: #state{}.

%%ranch stuff
-define(TIMEOUT, 5000).


%% @doc this is used for starting an accepting socket with Socket Listener passed as a parameter
%%-spec start_link(port()) ->{ok, pid()} | {error, any()}.
%%start_link(Socket) ->
%%		gen_server:start_link(?MODULE, Socket, []).

%% @doc this is used for starting up the ranch accepting socket 
start_link(Ref, Socket, Transport, Opts) ->
	{ok, proc_lib:spawn_link(?MODULE, init, [{Ref, Socket, Transport, Opts}])}.

%% @doc callback for genserver,accepts a Socket as input  
%%-spec init(port()) ->{ok, pid()} | {error, any()}.
%%init({Socket}) ->
%%		<<A:32, B:32, C:32>> = crypto:rand_bytes(12),
%%		random:seed({A,B,C}),
%%		gen_server:cast(self(), accept),
%%		{ok, #state{socket=Socket}}.

%% @doc this is the init for starting up the socket using ranch
init({Ref, Socket, Transport, _Opts = []}) ->
	ok = ranch:accept_ack(Ref),
	ok = Transport:setopts(Socket,[list, {packet, 0}, {active, once}]),
	(catch gproc:reg({p, l,<<"conn_sock">>}, ignored)),
	gen_server:enter_loop(?MODULE, [],#state{socket=Socket,iso_message=[],transport=Transport},?TIMEOUT).

%% @doc this call is for all call messages 
-spec handle_call(term(),pid(),state()) -> term().
handle_call(_E, _From, State) ->
		{noreply, State}.


%% @doc Accepting a connection
%%counter application is notified of connected clientt
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
handle_info(?SOCK(Str_Sock), State_old = #state{socket=AcceptSocket_process,iso_message=Isom_so_far,transport=Transport}) ->
		try process_transaction(?SOCK(Str_Sock),State_old) of
	        S ->
				Transport:setopts(AcceptSocket_process, [{active, once}]),
				S	
		catch
			error:X ->
			%%error message has to marshalled here and sent back to sender at this point 
			%%%all of message may not have been streamed in so in the meantime a return message should be formated and sent back to sender
			ok = send(AcceptSocket_process,[Isom_so_far,Str_Sock],Transport),
			ok = Transport:setopts(AcceptSocket_process, [{active, once}]),
			error_logger:error_msg("~nError Message ~p ~nwith input ~p",[erlang:get_stacktrace(),X]),
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

%% @doc ranch termination
terminate(_Reason, #state{socket=AcceptSocket_process,transport=Transport}) ->
		ok = Transport:close(AcceptSocket_process),
		io:format("~nterminate reason: ~p", [_Reason]),
		ok.


%% @doc for termination
%%-spec terminate(term(),state())->ok.
%%terminate(normal, #state{socket=S}) ->
%%		ok = gen_tcp:close(S);
    
    
%%terminate(shutdown, #state{socket=S}) ->
%%		ok = gen_tcp:close(S);

    
%%terminate(_Reason, #state{socket=S}) ->
%%		ok = gen_tcp:close(S),
%%		io:format("~nterminate reason: ~p", [_Reason]).

%% @doc for sending information through the socket
-spec send(port(),[pos_integer()],port())->ok|{error,any()}.
send(Socket, Str,Transport) ->
		ok = Transport:send(Socket,Str).

%% @doc this is for processing the transactions which come through the system 
%% transction data will be also given to a throwaway process whic which will save the data in mnesia for statistics ,if possible do other stuff b4 dying 
%%this will be done b4 after the message is sent to all involved but in a seperaate process  
process_transaction({_tcp,_Port_Numb,Msg}, S = #state{socket=AcceptSocket,iso_message=Isom,transport=Transport})->
		State_new = lists:flatten([Isom,Msg]), 
		%%io:format("~nfull snet  message is ~n~s~nlength is ~p~n",[State_new,length(State_new)]),		
		case length(State_new) of 
			Size when Size < ?BH -> 
				{noreply, S#state{iso_message=State_new}};
			_  ->
				{LenStr, Rest} = lists:split(?BH, State_new),
				%%io:format("~n--length of header string is ~p ~n--string for header ~w ~n--fake sum ~p --~n length of  message is ~p",[length(LenStr),LenStr,lists:sum(LenStr),length(Rest)]),
				Len = lists:sum(LenStr)+?BH,
				case length(State_new) of 
					SizeafterHead when Len =:= SizeafterHead ->	
						FlData = iso8583_erl:unpack(list,post,Rest),
						ok = send(AcceptSocket,State_new,Transport),	
						Message_send_list = yapp_test_lib_dirtyproc:process_message(FlData),
						%%io:format("~nmessage to be sent in the future is ~p",[Message_send_list]), 
						 case Message_send_list of
							{error,_Reason}->
								{noreply, S#state{iso_message=[]}};
							Send_list ->
								Msg_out = erlang:term_to_binary(FlData),
								Socket_list = maps:get(socket_list,Send_list),
								lists:map(fun(I)-> (catch gproc:send({p, l, I},{<<"tdata">>,Msg_out})) end,Socket_list),	 							
								{noreply, S#state{iso_message=[]}}    	
						end;
					SizeafterHead when Len < SizeafterHead ->
						%%io:format("~nbits and pieces"),
						{noreply, S#state{iso_message=State_new}}
				end
		end.
