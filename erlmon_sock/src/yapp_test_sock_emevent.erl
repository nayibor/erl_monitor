-module(yapp_test_sock_emevent).
-behaviour(gen_event).

-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3,
         terminate/2]).

-record(state, {callback_email}). % the current socket


init([]) ->
	Callback_email = fun({error, _Type, Message})->
										error_logger:error_msg("~n Error Sending Message is ~p",[Message]);
								  ({ok, _Receipt}) ->
										error_logger:info_msg("~nEmail Sent Succesfully ~p");
								  ({exit, _Error}) ->
										ok
										%%error_logger:error_msg("~nError With Email Process is ~p",Error)
							end,
    {ok,#state{callback_email=Callback_email}}.


%% @doc this event will send to the list of email addresses specified 
handle_event({trans,_FlData,Send_list},State=#state{callback_email=Callback_email}) ->
	Mail_list = maps:get(mail_list,Send_list),
	 case erlang:length(Mail_list) of 
		Size_send when Size_send > 0 ->
			Emails = lists:filtermap(fun(Id) -> 
								case yapp_test_lib_dirtyproc:get_email_address(Id) of 
									<<>>-> 
										false;
									 Email-> 
										{true,Email}
								end 
							end, Mail_list),
			%%io:format("~nemail addresses are ~p ",[Emails]),
			_Pid = yapp_test_lib:send_mail("Transaction Notification","Notification System","Notifier List","test-transaction-body",Emails,Callback_email),
			{ok, State};
		_ ->
			{ok, State}
	end.
  

handle_call(_, State) ->
    {ok, ok, State}.


handle_info(_, State) ->
    {ok, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
	ok.


