%%% 
%%% @doc yapp_test_lib application.
%%%<br>this is the starting point for the yapp_test_lib application</br>
%%%<br>the start function starts the functions and waits for the necessary table to wake up b4 starting the top level supervisor</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_lib).
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
    mnesia:wait_for_tables([usermod_users,usermod_roles,usermod_links,usermod_users_roles,usermod_users_links], 20000),
    yapp_test_lib_sup:start_link().

-spec stop(term()) -> ok.	
stop(_) -> ok.


