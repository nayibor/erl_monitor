%%%
%%% @doc yapp_test_ppool_serv module.
%%%<br>module for monitoring socket servers </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(yapp_test_ppool_serv).
-behaviour(gen_server).
-export([ start_link/3, start_socket/1,get_num_sockets/1,stop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         code_change/3, terminate/2]).

%% The friendly supervisor is started dynamicallyy
-define(SPEC(),
        {sock_sup,
         {yapp_test_sock_sup, start_link, []},
          permanent,
          10000,
          supervisor,
          [yapp_test_sock_sup]}).


%%spec for tester 
-define(TEST(),
        {test_serv,
         {yapp_test_sock_test_gen, start_link, []},
          permanent,
          10000,
          worker,
          [yapp_test_sock_test_gen]}).




-record(state, {limit=0,
                sup
                }).

-type state() :: #state{}.


%% @doc api call  starts up the process for monitoring the socket processes as well as passes the parent supervisor for the sockets so more sockets can be created  
-spec start_link(term(), pos_integer(),pid()) ->{ok, pid()} | {error, any()}.
start_link(Name, Limit, Sup) when is_atom(Name), is_integer(Limit) ->
    gen_server:start_link({local, Name}, ?MODULE, {Limit,Sup}, []).


%% @doc api call for adding more socket acceptors to the socket pool in case more sockets are needed later on in the program
-spec start_socket(atom())->{ok,pid()}|{error,any()}.
start_socket(Name) ->
    gen_server:call(Name, start_sock).


%% @doc api call which  gets you the number of available sockets/connected sockets
-spec get_num_sockets(term())->[tuple()] | {error,any()}.
get_num_sockets(Name)->
	gen_server:call(Name, num_sock).
	

%% @doc this stops this process  but it will get restarted because it is a permanent process
-spec stop(atom())->ok | {error,any()}.
stop(Name) ->
    gen_server:call(Name, stop).


%% @doc callback for genserver,accepts a limit and its supervisor as input 
-spec init({Limit::pos_integer(),Supervisor_pid::pid()}) -> {ok, state()}.
init({Limit, Sup}) ->
    %% We need to find the Pid of the worker supervisor from here,
    %% but alas, this would be calling the supervisor while it waits for us!
    %%self() ! {start_worker_supervisor, Sup},
    gen_server:cast(self(),{start_worker_supervisor, Sup}),
    {ok, #state{limit=Limit}}.


%% @doc this call is used for getting the number of  connected sockets,available sockets
%% it will come  from gproc which will keep info about connected sockets and other such info
-spec handle_call(term(),pid(),state()) -> term().
handle_call(num_sock, _From, S = #state{limit=N}) ->
	MatchHead = {'_', '_', <<"websocket">>},
	Guard = [],
	Result = ['$$'],
	Pids_web =  (gproc:select([{MatchHead, Guard, Result}])),
	Pids_sock= (catch gproc:lookup_pids({p, l,<<"conn_sock">>})),
	{reply, [{avail_sockets,N},{pid_conn_web,Pids_web},{pid_conn_sock,Pids_sock}],S};
	
	
%% @doc this call is used for starting an extra socket if number is below limit
handle_call(start_sock, _From, S = #state{limit=N, sup=Sup}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, []),
    {reply, {ok,Pid}, S#state{limit=N-1}};
    
    
%% @doc this call is used for starting extra sockets socket but wont happen to limit reached 
handle_call(start_sock, _From, S = #state{limit=N}) when N =< 0 ->
    {reply, {error,max_reached}, S};    


%% @doc this callback is used for stopping
handle_call(stop, _From, State) ->
    {stop, normal, ok, State};


%% @doc this callback is for unknown calls
handle_call(_Msg, _From, State) ->
    {noreply, State}.
    

%%t @doc this is used for starting the socket server supervisor,test gen server for sending testing messages  
%%this also  starts a  number of socket acceptors(as speficied in the .app file for the number of sockets ) once the socket supervisor has been started    
%%this also links this process to the socket server supervisor  as they depend on each other and killing one kills the other :)
%%test gen server is also started here
%%user can add five extra sockets to the number of sockets allowed
handle_cast({start_worker_supervisor, Sup}, S = #state{limit=N}) ->
    {ok, Pid} = supervisor:start_child(Sup, ?SPEC()),
    {ok, _Test} = supervisor:start_child(Sup, ?TEST()),
    _List_children=empty_listeners(Pid,N),
    link(Pid),
    {noreply, S#state{sup=Pid,limit=5}};


%% @doc this callback for unknown casts
handle_cast(_Msg, State) ->
    {noreply, State}.
    

%% @doc for unknown messages
handle_info(Msg, State) ->
    io:format("Unknown msg: ~p~n", [Msg]),
    {noreply, State}.


%% @doc for code changes
-spec code_change(string(),state(),term())->{ok,state()}|{error,any()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% @doc for termination
-spec terminate(term(),state())->ok.
terminate(_Reason, _State) ->
    ok.


%% @doc for starting a socket acceptor
start_socket_child(Sup) ->
		supervisor:start_child(Sup, []).


%% @doc Start with number of  acceptors in the .app file in  so that many multiple connections can
%% be started at once, without serialization. In best circumstances,
%% a process would keep the count active at all times to insure nothing
%% bad happens over time when processes get killed too much.
empty_listeners(Sup,N) ->
		[start_socket_child(Sup) || _ <- lists:seq(1,N)].
