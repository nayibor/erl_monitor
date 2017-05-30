%%%
%%% @doc yapp_test_sock_supersup module.
%%%<br>top level supervisor for the socket server application </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
-module(yapp_test_sock_supersup).
-behaviour(supervisor).
-export([start_link/1]).
-export([init/1]).

start_link([]) ->
	    supervisor:start_link(?MODULE,[]).

%%% @doc this where supervisor for the tester process ,socket counter process,socket supervisor process is started 
-spec init({atom(),pos_integer()}) -> {ok, {supervisor:sup_flags(), [supervisor:child_spec()]}}. 
init([]) ->
		{ok, {{one_for_one, 10, 10}, []}}.
	    %%MaxRestart = 100,
	    %%MaxTime = 3600,
	    %%{ok, {{one_for_one, MaxRestart, MaxTime},
	    %%     [{serv,
	    %%         {yapp_test_ppool_serv, start_link, [Name, Limit, self()]},
	    %%         permanent,
	    %%         5000, % Shutdown time
	    %%         worker,
	    %%         [yapp_test_ppool_serv]}]}}.
	             
	
