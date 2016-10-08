%%%
%%% @doc yapp_test_sock_serv module.
%%%<br>this module is responsible for accepting conections from external interfaces and passing it to the asci processor </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>


-module(yapp_test_sock_serv).
-behaviour(gen_server).

-record(state, {iso_message=[],socket}). % the current socket



-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).
 
 
-define(SOCK(Msg), {tcp, _Port, Msg}).
-define(BH,4).



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


%%handles connections and proceses the iso messages which are sent through the connection 
handle_info(?SOCK(Str), S = #state{socket=AcceptSocket,iso_message=Isom}) ->
		State_new=Isom++Str,
		io:format("~nfull message is ~n~s~nlength is ~p~n",[State_new,length(State_new)]),
		case length(State_new) of 
			Size when Size < ?BH -> 
				%%io:format("smaller size  is ~p,~n~n~n",[State_new]),
				{noreply, S#state{iso_message=State_new}};
			_  ->
				{LenStr, Rest} = lists:split(?BH, State_new),
				io:format("~n --length of header string is ~p -- string for header ~w -- length of  message is ~p",[length(LenStr),LenStr,length(Rest)]),
				%%Len = lists:nth(?BH,LenStr) + ?BH,
				Len = erlang:list_to_integer(LenStr)+?BH,
				case length(State_new) of 
					SizeafterHead when Len =:= SizeafterHead ->	
						io:format("~nabout to process mesage"),
						try yapp_test_ascii_marsh_jpos:process_iso_message(Rest) of 
							FlData ->
								send(AcceptSocket,State_new),						
								Message_send_list = yapp_test_lib_dirtyproc:process_message(FlData),
								_Status_Send = [{I, (catch gproc:send({n, l, I},{transaction_message,FlData}))} || I <- Message_send_list],
								
								%%io:format("~n~nSending Statuses ~p",[Status_Send]),
								% Display the MTI from the response.
						
								{noreply, S#state{iso_message=[]}}
						catch
							error:X ->
								send(AcceptSocket,State_new),
								io:format("~nError Message ~p ~nwith input ~p",[erlang:get_stacktrace(),X]),
								{noreply, S#state{iso_message=[]}}
						end;
					SizeafterHead when Len < SizeafterHead ->
						io:format("~nbits and pieces"),
						{noreply, S#state{iso_message=State_new}}
				end
		end;
	 		 	
 
    
handle_info({tcp_closed, _Socket}, S) ->
		io:format("~nSocket Closed~n"),							
		{stop, normal, S};
    
handle_info({tcp_error, _Socket, _}, S) ->
		{stop, normal, S};
    
 %%info coming in from as a result of messages received maybe from othe processes 
handle_info(E, S) ->
		io:format("unexpected message: ~p~n", [E]),
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

 
 
 
		%%LenStr_Message_Back = LenStr,
		%%Mti
		%%Mti = lists:sublist(Rest,?MTI_SIZE),
		%%Mti_Message_Back = 	case  Mti of
		%%						"1200" ->
		%%							"1210" ;
		%%						"1220" ->
		%%							"1230";
		%%						"1420" ->
		%%							"1430";
		%%						_ ->
		%%							Mti
		%%					end,			
		%%Bitmap will be sent back unchanged
		%%Bitmap_Message_Back = lists:sublist(Rest,?MTI_SIZE+1,?PRIMARY_BITMAP_SIZE),	
		%%Start_index = ?MTI_SIZE+?PRIMARY_BITMAP_SIZE+1,
		%%Data Elements
		%%Data_Message_Back = lists:sublist(Rest,Start_index,length(Rest)-(length(Mti_Message_Back)+length(Bitmap_Message_Back))),
		%%Send_Message_Back = LenStr_Message_Back ++ Mti_Message_Back ++ Bitmap_Message_Back ++ Data_Message_Back,
		%%the below statements have to be placed in some sort of block so even if an error occurs shit does not hit the fin
		%%send(AcceptSocket,Send_Message_Back), 
	
