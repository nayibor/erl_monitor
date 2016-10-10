%%%
%%% @doc yapp_test_sock_serv module.
%%%<br>this module is responsible for processing iso messages</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>


-module(yapp_test_ascii_marsh).



-export([process_iso_message/1]).
-include_lib("yapp_test_sock/include/yapp_test_sock_spec.hrl").

-define(MTI_SIZE,4).
-define(PRIMARY_BITMAP_SIZE,8).


%% @doc this part accepts a message with the header removed and extracts the mti,bitmap,data elements into a map object 
%% exceptions can be thrown here if the string for the message hasnt been formatted well but they should be caught in whichever code is calling the system 
-spec process_iso_message([pos_integer()])->map().
process_iso_message(Rest)->
		
		Mti_size = ?MTI_SIZE,
		Primary_Bitmap_size = ?PRIMARY_BITMAP_SIZE,
		%io:format("~n~nlength is ~p ~nfull message is:~n~s", [Len-2,Rest]),
		%io:format("~n~nrequest_mti:~p",[lists:sublist(Rest,Mti_size)]),
		%%io:format("~n~nfirst twelve integer values are:~p",[lists:sublist(Rest,1,12)]),
		%io:format("~n~nin progress primary bitmap are:~p",[lists:sublist(Rest,Mti_size+1,8)]),
		%%gets whether the  first character of the bitmap is 1/0(48,49)cuz of string and then uses this to calculate size of bitmap 
		Bitmap_size = case lists:nth(1,string:right(integer_to_list(lists:nth(5,Rest),2),8,$0)) of
						48 -> 8;
						49 -> 16
						end,
		%io:format("~n~nbitmap size is:~p",[Bitmap_size]),
		%io:format("~n~nbitmap(pri/sec) is :~p",[lists:map(fun(X)->string:right(integer_to_list(X,2),8,$0)end,lists:sublist(Rest,Mti_size+1,Bitmap_size))]),
		%io:format("~n~nflattend bitmap(pri/sec) in binary is:~p",[lists:flatten(lists:map(fun(X)->string:right(integer_to_list(X,2),8,$0)end,lists:sublist(Rest,Mti_size+1,Bitmap_size)))]),
		%%io:format("~nfirst value is ~p and first binary bitmap:~p and hex value is ~p",[lists:nth(5,Rest),string:right(integer_to_list(lists:nth(5,Rest),2),8,$0),integer_to_list(lists:nth(5,Rest),16)]),
		Bitmap_transaction = lists:flatten(lists:map(fun(X)->string:right(integer_to_list(X,2),8,$0)end,lists:sublist(Rest,Mti_size+1,Bitmap_size))),
		%io:format("~nraw values ~w int value to use  ~p asci value code is:~p",[lists:sublist(Rest,68,8),list_to_integer(lists:sublist(Rest,68,2)),lists:sublist(Rest,68,8)]),
		
		%%add bitmap as well as mti to map which holds data elements so they can help in processing rules 
		Mti_Data_Element = maps:from_list([{ftype,ans},{fld_no,0},{name,<<"Mti">>},{val_binary_form,list_to_binary(lists:sublist(Rest,Mti_size))},{val_list_form,lists:sublist(Rest,Mti_size)}]),
		Bitmap_Data_ELement = maps:from_list([{ftype,b},{fld_no,0},{name,<<"Bitmap">>},{val_binary_form,list_to_binary(Bitmap_transaction)},{val_list_form,Bitmap_transaction}]),
		Map_Data_Element1 =  maps:put(<<"_mti">>,Mti_Data_Element,maps:new()), 
		Map_Data_Element = maps:put(<<"_bitmap">>,Bitmap_Data_ELement,Map_Data_Element1),
				
		Start_index = Mti_size+Primary_Bitmap_size+1,
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
		FlData.


%% @doc marshalls a message to be sent 
-spec marshall_message([Mti ::pos_integer()],Message_Map::[pos_integer()])->[pos_integer()].
marshall_message(Mti,Message_Map)->
		ok.
		 
	%%get the spec for the message type you are sending based on the mti of the message and maybe a spec for the kind of message being done (balance enquiry,withdrawal,etc...)
	%%ecalculate the various fields starting from field 2 and the header length which may be applied to field based on the spec of the field
	%%will generate an exception if field is supposed to be available in map but is not based on specification for that field 
	%%append primary mti,pbitmap,sbitmap(if available)
	%%calculate size of the above field and put in 2 bit message header 
	%%return function and send to interface 
