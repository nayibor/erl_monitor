
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
					
					%%calculate the data elements and their value 
					%%will have to actually use a formual to get the values programmatically out of message
					%%wont be too difficult but have to be careful about how i create the data elements 
					
					%%to obtain value for particular data element you need(stub of how specification will be implemented )
							%%check whether that data element exists
							%%if exists get postion to start from 
							%%atrributes of that data element to see how you will obtain data for it and calcullate value for next person in sequence 
							%%foldr will be used but have to be careful about nature of fold
							%%header file will have to be created with definitions for each fld and the attributes of that field value according to  a specification 
							%%three main features of a data item are total length,fixed or variable,padding type,data type(numeric,binary,etc..)
							%%lists:foldl(fun(X, Sum) -> X + Sum end, 0, [1,2,3,4,5]).
							
							%%listsfoldl(fun(X,Acc={Data_for_use_in,Index_start_in,Current_index_in,Map_out_list_in})->
							%%						
							%%						Fld_attr=Get_att_value(Current_index_in),
							%%						NextVal_start_pos=Fld_atttr.get_nextval(),
							%%						Fld_length=Fld_atttr.get_length()+padding_if_Avail,
							%%						get value here,
							%%						Fld_num_out=Current_index+1,
							%%						{Data_for_use_out,Index_start_out,Fld_num_out,Map_out_list_out}end,
							%%						{Data_for_use,Index_start,Fld_num,Map_out_list},
							%%						bitmap__base10_list);
							
							
					io:format("~n~n~n###below are the data elements for above bitmap###"),
					io:format("~npan digits ~p and pan is:~p",[lists:sublist(Rest,Mti_size+Bitmap_size+1,2),lists:sublist(Rest,Mti_size+Bitmap_size+3,16)]),
					io:format("~nprocessing code is:~p",[lists:sublist(Rest,31,6)]),
					io:format("~namount for trasaction is:~p",[lists:sublist(Rest,37,12)]),
					io:format("~nstan for trasaction is:~p",[lists:sublist(Rest,49,6)]),
					io:format("~ntimestamp local trasaction is:~p",[lists:sublist(Rest,55,12)]),
					io:format("~npan expiry is:~p",[lists:sublist(Rest,67,4)]),
					io:format("~npos data code is:~p",[lists:sublist(Rest,71,12)]),



					
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

 
