%%% 
%%% @doc yapp_test_lib_sup supervisor module documentation.
%%%<br>top level supervisor is started here</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_lib_sup).
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
    {ok, {{one_for_one, 1, 1}, []}}.
