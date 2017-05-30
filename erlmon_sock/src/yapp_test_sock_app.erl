%%% 
%%% @doc yapp_test_sock application.
%%%<br>application entry point for socket server </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_sock_app).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").

-behaviour(application).

%%% API
-export([start/2,stop/1]).

%%%=============================================================================
%%% API
%%%=============================================================================
%% @doc this is for starting the application 
-spec start(term(), term()) -> {error, term()} | {ok, pid()}.
start(normal, []) ->
    {ok, Name} = application:get_env(name),
    {ok, Limit} = application:get_env(limit),  
    {ok, Port} = application:get_env(port),  
    yapp_test_sock_supersup:start_link(Name,Limit,Port).

-spec stop(term()) -> ok.	
stop(_) ->
	{ok, Name} = application:get_env(name),
	ranch:stop_listener(Name),
	ok.




