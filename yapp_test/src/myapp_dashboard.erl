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
-include_lib("yapp_test/include/yapp_test.hrl").



%%% @doc check to see whether use is logged in 
out(Arg) ->
		out(Arg,yapp_test_lib_sess:check_login(Arg,?COOKIE_VARIABLE)).

		
%%% @doc for redirecting users not logged in back to login  page  
out(Arg,error) ->
		{page,yapp:prepath(Arg)++?INDEX_PAGE};

%%% @doc user is logged but check has to be still done as to whether user has access to pages
%%  	 all users will have access to landing page as this is waived for all users
%%       check wont be done here on users right to view dashboard . it will however be done on other controllers
%%   @end
out(Arg,ok) ->
		%%io:format("cookie availables.does page exist??~p~n",[yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)]),
		%%out(Arg,ok,yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)).
		out(Arg,ok,ok).
		
		

%% @doc logged in users whom dont have access to page are shown the page for restricted users (exists/no access)
%%  	this page is okay .
%%       users are always looged in when they get here come here so a div with content is okay
%% @end
out(Arg,ok,error) ->
		{page,yapp:prepath(Arg)++?PG_401};
	
	
%%% @doc logged in users whom hav access to this page come here (exists/access)
out(Arg,ok,ok) ->
		Uri = yaws_api:request_url(Arg),
		Path = string:tokens(Uri#url.path, "/"), 
		Method = (Arg#arg.req)#http_request.method,
		outa(Arg,Method,Path).
	
	
%% @doc	this is for the index_dashboard action get method
outa(Arg,'GET',["yapp_test","dashboard","index_dashboard"])->
		myapp_dash_layout:show_dashboard(Arg);
		%%myapp_dash_layout:out(Arg,Title_Page,gen_content(Arg));


%% @doc for unknown pages which may be specialized for this layout/controller
%% 		logged in users entering in fake urls	
outa(Arg,_Method,_)->
		{page,yapp:prepath(Arg)++?PG_404}.


