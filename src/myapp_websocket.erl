%%%
%%% @doc file for the the websocket controller.
%%%<br>this is for enabling trasaction information to be sent to the relevant users</br> 
%%%<br>myapp_websocket  module </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_websocket).
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
%%%% temporal change to allow all urls to pass through to aid in testing of mithril
out(Arg) ->
    	out(Arg,yapp_test_lib_sess:check_login(Arg,?COOKIE_VARIABLE)),
    	io:format("~n~pcookie::",[Arg]),
		out(Arg,ok,ok).
		
		
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
%%%		  only users whom have permission to access the websocket exchanges will come here 
out(Arg,ok,ok) ->
		Uri = yaws_api:request_url(Arg),
		Path = string:tokens(Uri#url.path, "/"), 
		Method = (Arg#arg.req)#http_request.method,
		outa(Arg,Method,Path).

%% @doc	this is for the index_dashboard action get method
outa(Arg,'GET',[_,"websock","setup"])->
		Data_user = yapp_test_lib_sess:get_user_websocket(Arg,?COOKIE_VARIABLE),
		CallbackMod = myapp_websocket_callback,
		Opts = [
					{origin,lists:flatten(["http://",(Arg#arg.headers)#headers.host])},
					{callback, {basic, Data_user}}
            %%{keepalive,         KeepAlive},
            %%{keepalive_timeout, Tout},
            %%{drop_on_timeout,   Drop},
            %%{close_if_unmasked, CloseUnmasked}
			   ],
		{websocket, CallbackMod, Opts};
	
	
%% @doc this page is for the mithril.js page which will be used for viewing transactions
%% @doc	this is for the index_dashboard action get method
outa(Arg,'GET',[_,"websock","mithril"])->
		{ok,UiData} = yapp_test_mithril_layout:render([{yapp_prepath,yapp:prepath(Arg)}]),
		{html,UiData};
		
%% @doc this page is for the mithril.js page which will be used for testing web services 
%% @doc	this is for the index_dashboard action get method
outa(_Arg,'GET',[_,"websock","mithril_webs"])->
		
		%%Json = json2:encode({struct,[{name,"John"},{name,"Mary"}]}),
		Struct = json2:encode({struct,[{name,"John"},{name,"Mary"}]}),
		{content,"application/json; charset=iso-8859-1",Struct};
			
		
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg,_Method,_)->
		{page,yapp:prepath(Arg)++?PG_404}.
		
