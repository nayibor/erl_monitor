%%%
%%% @doc layout file for use by other modules.
%%%<br>myapp_dash_layout  module </br>
%%%<br>layout file</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_dash_layout).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").


%%functions for processing pages
-export([
		 out/2,
		 show_dashboard/1
		 ]).

-include_lib("yaws/include/yaws_api.hrl").
-include_lib("yapp_test/include/yapp_test.hrl").


%% @doc this is for showing only the dashboard page 
%%      all pages have access to this page/layout
show_dashboard(Arg) ->
		%%outnew(Arg,"Dashboard",[]).
		out(Arg,"Welcome to Dashboard").
		
out(Arg,Title_Page) ->
		[{_,Name},{_,Links_Allowd}] = yapp_test_lib_sess:get_user_data(Arg,?COOKIE_VARIABLE),
		{ok,UiData} = yapp_sidebar:render([{fname,Name},{title,Title_Page},{yapp_prepath,yapp:prepath(Arg)},{data,Links_Allowd}]),
		{html,UiData}.
	
