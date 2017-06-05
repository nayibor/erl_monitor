-module(yapp_test_sock_emevent).
-behaviour(gen_event).

-export([init/1, handle_event/2, handle_call/2, handle_info/2, code_change/3,
         terminate/2]).

init([]) ->
    {ok, []}.


%% @doc this event will send to the list of email addresses specified 
handle_event({trans,_FlData,Send_list}, State) ->
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
			ok = erlmon_worker_pool:send_mail("Transaction Decline Notification","Nuku Ameyibor","Notifier List","test-transaction-body",Emails),
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


