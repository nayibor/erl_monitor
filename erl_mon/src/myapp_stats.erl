%%%
%%% @doc myapp_stats module.
%%%<br>contains code for working with statistics</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_stats).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://github.com/nayibor").
-license("Apache License 2.0").





%%functions for processing pages
-export([
		 out/1
		 ]).
		 
	 
-include_lib("yaws/include/yaws_api.hrl").
-include_lib("erl_mon/include/yapp_test.hrl").


%%% @doc check to see whether use is logged in 
out(Arg) ->
		out(Arg,yapp_test_lib_sess:check_login(Arg,?COOKIE_VARIABLE)).

		
%%% @doc for redirecting users not logged in back to login  page  
out(Arg,error)->
		{page,yapp:prepath(Arg)++?INDEX_PAGE};

%%% @doc user is logged but check has to be still done as to whether user has access to pages
%%  	 all users will have access to landing page as this is waived for all users
%%   @end
out(Arg,ok) ->
		%%io:format("cookie availables.does page exist??~p~n",[yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)]),
		out(Arg,ok,yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)).


%% @doc logged in users whom dont have access to page are shown the page for restricted users (exists/no access)
out(Arg,ok,error) ->
		%%io:format("user logged in and but does not have permission to acces page"),
		{page,yapp:prepath(Arg)++?PG_401};
	
	
%%% @doc logged in users whom hav access to this page come here (exists/access)
out(Arg,ok,ok) ->
		Uri = yaws_api:request_url(Arg),
		Path = string:tokens(Uri#url.path, "/"), 
		Method = (Arg#arg.req)#http_request.method,
		outa(Arg,Method,Path).


%% @doc	this is for viewing statistics for transactions 
%%basic transaction list will have to be obtained here for viewing
outa(_Arg,'GET',[_,"stats","index_view_stats"])->
		Title_Page = "View Statistics",
		{ok,UiData} = yapp_test_content_insert:render([{title,Title_Page},{page_type,"view_stats"}]),
		{html,UiData};


%% @doc	this is for the getting institutions
outa(Arg,'GET',[_,"stats","get_stats"])->
		
		io:format("data stuff ~p",[yaws_api:parse_query(Arg)]),
		Start_date = yaws_api:queryvar(Arg,"start_date"),
		End_date = yaws_api:queryvar(Arg,"end_date"),
		case  Start_date =:= undefined orelse
		      End_date =:= undefined of
					true ->
						yapp_test_lib_util:message_client(500,"Required Field is Empty");
					_ ->
						{_,Sd}=Start_date,
						{_,Ed}=End_date,
						 Query = "SELECT * FROM realtime_data.dbo.task_uptime  where  
								  date_begin >? and date_begin<? 
								  order by date_begin DESC;",
						Param = [{{sql_varchar,10}, [Sd]},{{sql_varchar, 10}, [Ed]}],		  
						case erlmon_worker_pool:query(Query,Param) of 
							{ok,{_,_,Tasks}} ->
									%%io:format("~n First Task:~p~nSize:~p",[lists:nth(1,Tasks),erlang:length(Tasks)]),
									 {content,"application/octet-stream",erlang:term_to_binary(Tasks)};
							{error,_Reason} ->
									yapp_test_lib_util:message_client(500,"There was an error getting the data.<b>Please try again</b>")	
						end
	  end;
	
		
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg,_Method,_)->
		{page,yapp:prepath(Arg)++?PG_404}.		
		
		
		
		
				
