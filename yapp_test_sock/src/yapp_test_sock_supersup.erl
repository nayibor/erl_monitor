-module(yapp_test_sock_supersup).
-behaviour(supervisor).
-export([start_link/2]).
-export([init/1]).

start_link(Name, Limit) ->
	    supervisor:start_link(?MODULE,{Name, Limit}).

%%%c@doc this where the test server,the socket serrver counter server  as well as the socket server itself may be startedd  
init({Name, Limit}) ->
	    MaxRestart = 1,
	    MaxTime = 3600,
	    {ok, {{one_for_all, MaxRestart, MaxTime},
	          [{serv,
	             {yapp_test_ppool_serv, start_link, [Name, Limit, self()]},
	             permanent,
	             5000, % Shutdown time
	             worker,
	             [yapp_test_ppool_serv]}]}}.
	             
	
