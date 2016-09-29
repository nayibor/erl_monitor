
-module(yapp_test_sock_serv).
-behaviour(gen_server).

-record(state, {iso_message=[],socket}). % the current socket



-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).

-include_lib("yapp_test_sock/include/yapp_test_sock_spec.hrl").


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


%%handles connections and proceses the iso messages which are sent through the connection 
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
					Mti_size = 4,
					io:format("~n~nlength is ~p ~nfull message is:~n~s", [Len-2,Rest]),
					io:format("~n~nrequest_mti:~p",[lists:sublist(Rest,Mti_size)]),
					io:format("~n~nfirst twelve integer values are:~p",[lists:sublist(Rest,1,12)]),
					io:format("~n~nin progress primary bitmap are:~p",[lists:sublist(Rest,Mti_size+1,8)]),
					%%gets whether the  first character of the bitmap is 1/0(48,49)cuz of string and then uses this to calculate size of bitmap 
					Bitmap_size = case lists:nth(1,string:right(integer_to_list(lists:nth(5,Rest),2),8,$0)) of
									48 -> 8;
									49 -> 16
									end,
					io:format("~n~nbitmap size is:~p",[Bitmap_size]),
					io:format("~n~nbitmap(pri/sec) is :~p",[lists:map(fun(X)->string:right(integer_to_list(X,2),8,$0)end,lists:sublist(Rest,Mti_size+1,Bitmap_size))]),
					io:format("~n~nflattend bitmap(pri/sec) in binary is:~p",[lists:flatten(lists:map(fun(X)->string:right(integer_to_list(X,2),8,$0)end,lists:sublist(Rest,Mti_size+1,Bitmap_size)))]),
					%%io:format("~nfirst value is ~p and first binary bitmap:~p and hex value is ~p",[lists:nth(5,Rest),string:right(integer_to_list(lists:nth(5,Rest),2),8,$0),integer_to_list(lists:nth(5,Rest),16)]),
					
					Bitmap_transaction = lists:flatten(lists:map(fun(X)->string:right(integer_to_list(X,2),8,$0)end,lists:sublist(Rest,Mti_size+1,Bitmap_size))),
					io:format("~nraw values ~w int value to use  ~p asci value code is:~p",[lists:sublist(Rest,68,8),list_to_integer(lists:sublist(Rest,68,2)),lists:sublist(Rest,68,8)]),
					
					%%next line creates new map and also adds the mti to the map 
					%%this map will be used as input to the foldr which gets the data elements
					%%field 1 will be added later after i do some checks . also means the start position will have to go back so the bitmap can be checked
					%%has to be added when i go into fields which go past 64 data elements which i will have to do soon  
					Mti_Data_Element= maps:from_list([{ftype,n},{fld_no,0},{name,<<"Mti">>},{val_list_form,lists:sublist(Rest,Mti_size)}]),
					Map_Data_Element =  maps:put(0,Mti_Data_Element,maps:new()), 
					Start_index = Mti_size+Bitmap_size+1,
					%%Bitmap_transaction_test = lists:sublist(Bitmap_transaction,5),
					OutData =lists:foldl(fun(X,_Acc={Data_for_use_in,Index_start_in,Current_index_in,Map_out_list_in}) when X =:= 49->						
											    {Ftype,Flength,Fx_var_fixed,Fx_header_length,DataElemName}=?SPEC(Current_index_in),
												case Fx_var_fixed of
													fx -> 
														Data_Element = lists:sublist(Rest,Index_start_in,Flength),
														New_Index = Index_start_in+Flength ;	
													vl ->
														Vl_value = list_to_integer(lists:sublist(Rest,Index_start_in,Fx_header_length)),
														Start_val = Index_start_in + Fx_header_length , 										
														Data_Element = lists:sublist(Rest,Start_val,Vl_value),
														New_Index = Start_val+Vl_value
												end,
												NewData  = maps:from_list([{ftype,Ftype},{fld_no,Current_index_in},{name,DataElemName},{val_list_form,Data_Element}]),
												NewMap = maps:put("_"++integer_to_list(Current_index_in),NewData,Map_out_list_in),
												Fld_num_out = Current_index_in + 1,
												{Data_for_use_in,New_Index,Fld_num_out,NewMap};
											(X,_Acc={Data_for_use_in,Index_start_in,Current_index_in,Map_out_list_in}) when X =:= 48->
												Fld_num_out = Current_index_in + 1,						
												{Data_for_use_in,Index_start_in,Fld_num_out,Map_out_list_in}
										 end,
								   {Rest,Start_index,1,Map_Data_Element},Bitmap_transaction),
					
					{_,_,_,FlData}=OutData,
					io:format("~nkeys and values so far are ~p",[FlData]),
					
					%%reponse message will have to be created here and then sent back based on the request type 
					%%will start will just changing the mti and then echoing the response back . 
					
					
					%%echo messager for now. no need for all of this .i can just echo back the message received 
					%%lnestr mti bitmap message 
					%LengthString will be sent back unc
					LenStr_Message_Back = LenStr,
					%%Mti
					Mti = lists:sublist(Rest,Mti_size),
					Mti_Message_Back = 	case  Mti of
											"1200" ->
												"1210" ;
											"1220" ->
												"1230";
											"1420" ->
												"1430";
											_ ->
												Mti
										end,			
					%%Bitmap will be sent back unchanged
					Bitmap_Message_Back = lists:sublist(Rest,Mti_size+1,Bitmap_size),							
					%%Data Elements
					Data_Message_Back = lists:sublist(Rest,Start_index,length(Rest)-(length(Mti_Message_Back)+length(Bitmap_Message_Back))),
					Send_Message_Back = LenStr_Message_Back ++ Mti_Message_Back ++ Bitmap_Message_Back ++ Data_Message_Back,
					
					%%the below statements have to be placed in some sort of block so even if an error occurs shit does not hit the fin
					send(AcceptSocket,Send_Message_Back),						
					Message_send_list = yapp_test_lib_dirtyproc:process_message(FlData),
					
					%%io:format("~n~nSending List is ~p",[Message_send_list]),
					%%have to write a function that will filter out the information that will be sent to the client 
					Status_Send = [{I, (catch gproc:send({n, l, I},{transaction_message,FlData}))} || I <- Message_send_list],
					%%io:format("~n~nSending Statuses ~p",[Status_Send]),
					
						% Display the MTI from the response.
						{noreply, S#state{iso_message=[]}};
					SizeafterHead when Len < SizeafterHead ->
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

 
