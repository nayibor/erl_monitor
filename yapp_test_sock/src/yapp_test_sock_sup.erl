%%% 
%%% @doc yapp_test_sock_sup supervisor module documentation.
%%%<br>top level supervisor is started here for the sockett</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_sock_sup).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").

-behaviour(supervisor).

%%% API
-export([start_link/0]).

%%% Supervisor callbacks
-export([init/1]).


-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
		supervisor:start_link(?MODULE, []).

%% This does absolutely nothing, only there to
%% allow to wait for tables.
-spec init(any()) ->
  {ok, {supervisor:sup_flags(), [supervisor:child_spec()]}}.
init([]) ->
		{ok, Port} = application:get_env(port),
		%% Set the socket into {active_once} mode.
		%% See sockserv_serv comments for more details
		io:format("#########starting the socket Server supervisor###########"),
		{ok, ListenSocket} = gen_tcp:listen(Port, [{active,once}, {packet,line}]),
		{ok, {{simple_one_for_one, 60, 3600},
        [{socket,
         {yapp_test_sock_serv, start_link, [ListenSocket]}, % pass the socket!
         temporary, 1000, worker, [yapp_test_sock_serv]}
         ]}}.


