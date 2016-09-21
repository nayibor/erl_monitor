%%% 
%%% @doc yapp_test_sock application.
%%%This is the socket server which will process all messages
%%%<br>this is the starting point for the yapp_test_sock application</br>
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
-spec start(term(), term()) -> {error, term()} | {ok, pid()}.
start(normal, []) ->
    %%mnesia:wait_for_tables([usermod_users,usermod_roles,usermod_links,usermod_users_roles,usermod_users_links], 20000),
    %%these three variables will have to be declared by static means or in the app file as an env variable ***
    {ok, Name} = application:get_env(name),
    {ok, Limit} = application:get_env(limit),    
    yapp_test_sock_supersup:start_link(Name, Limit).

-spec stop(term()) -> ok.	
stop(_) -> ok.




