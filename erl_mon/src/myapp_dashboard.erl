%%%
%%% @doc myapp_dashboard module.
%%%<br>dashboard module </br>
%%%<br>this will be used for user management</br>
%%%<br>lots of links to other functionality can be found here</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_dashboard).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
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
out(Arg,error) ->
		{page,yapp:prepath(Arg)++?INDEX_PAGE};

%%% @doc user is logged but check has to be still done as to whether user has access to pages
%%  	 all users will have access to landing page as this is waived for all users
%%   @end
out(Arg,ok) ->
		%%io:format("cookie availables.does page exist??~p~n",[yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)]),
		%%out(Arg,ok,yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)).
		out(Arg,ok,ok).
	
	
%%% @doc logged in users whom hav access to this page come here (exists/access)
out(Arg,ok,ok) ->
		Uri = yaws_api:request_url(Arg),
		Path = string:tokens(Uri#url.path, "/"), 
		Method = (Arg#arg.req)#http_request.method,
		outa(Arg,Method,Path).


%% @doc	this is for the index_dashboard_view action which is  what they get when they click the view transactions button
outa(_Arg,'GET',[_,"dashboard","index_dashboard_view"])->
		Title_Page = "Welcome to Monitor",
		{ok,UiData} = yapp_test_content_insert:render([{title,Title_Page},{page_type,"welcome"}]),
		{html,UiData};

	
%% @doc	this is for the index_dashboard action get method. default page users get to see when loggin
outa(Arg,'GET',[_,"dashboard","index_dashboard"])->
		Title_Page = "Welcome to Monitor",
		[{_,Name},{_,Links_Allowd}] = yapp_test_lib_sess:get_user_data(Arg,?COOKIE_VARIABLE),
		{ok,UiData} = yapp_sidebar:render([{fname,Name},{title,Title_Page},{yapp_prepath,yapp:prepath(Arg)},{data,Links_Allowd},{page_type,"welcome"}]),
		{html,UiData};

%% @doc	this is for viewing statistics for transactions 
outa(_Arg,'GET',[_,"dashboard","index_view_stats"])->
		Title_Page = "View Statistics",
		{ok,UiData} = yapp_test_content_insert:render([{title,Title_Page},{page_type,"view_stats"}]),
		{html,UiData};


%% @doc for unknown pages which may be specialized for this layout/controller
%% 		logged in users entering in fake urls	
outa(Arg,_Method,_)->
		{page,yapp:prepath(Arg)++?PG_404}.


