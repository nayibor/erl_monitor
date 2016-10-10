%%%
%%% @doc yapp_test_ppool_serv module.
%%%<br>module for monitoring socket servers </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(yapp_test_ppool_serv).
-behaviour(gen_server).
-export([ start_link/3, start_socket/1,get_num_sockets/1,get_refs_socks/1,stop/1]).
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
                sup,
                connected_clients_pid=[],
                refs}).

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
	

%% @doc api call which gets you the references for the connected sockets
-spec get_refs_socks(term())-> {conn_clients,[reference()]|[]}|{error,any()}.
get_refs_socks(Name)->
	gen_server:call(Name, get_refs_socks).

%% @doc this stops this process  but it will get restarted because it is a permanent process
-spec stop(atom())->ok | {error,any()}.
stop(Name) ->
    gen_server:call(Name, stop).


%% @doc callback for genserver,accepts a limit and its supervisor as input 
-spec init({Limit::pos_integer(),Supervisor_pid::pid()}) -> {ok, state()}.
init({Limit, Sup}) ->
    %% We need to find the Pid of the worker supervisor from here,
    %% but alas, this would be calling the supervisor while it waits for us!
    self() ! {start_worker_supervisor, Sup},
    {ok, #state{limit=Limit, refs=gb_sets:empty()}}.


%% @doc this call is used for getting the number of  connected sockets,available sockets
-spec handle_call(term(),pid(),state()) -> term().
handle_call(num_sock, _From, S = #state{limit=N,connected_clients_pid=Clist}) ->
	{reply, [{avail_sockets,N},{connected_sockets,erlang:length(Clist)}],S};
	
	
%% @doc this call is used for starting a socket if number is below limit
handle_call(start_sock, _From, S = #state{limit=N, sup=Sup, refs=R}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, []),
    Ref = erlang:monitor(process, Pid),
    {reply, {ok,Pid}, S#state{limit=N-1, refs=gb_sets:add(Ref,R)}};
    
    
%% @doc this call is used for starting a socket but wont happen to limit reached 
handle_call(start_sock, _From, S = #state{limit=N}) when N =< 0 ->
    {reply, {error,max_reached}, S};    


%% @doc this callback is used for getting the references for the sockets
handle_call(get_refs_socks, _From, S=#state{connected_clients_pid=Clist}) ->
	{reply,{conn_clients,Clist},S};


%% @doc this callback is used for stopping
handle_call(stop, _From, State) ->
    {stop, normal, ok, State};


%% @doc this callback is for unknown calls
handle_call(_Msg, _From, State) ->
    {noreply, State}.
    
    
%% @doc this call is used for notifying this process if a socket gets connected
-spec handle_cast(term(),state()) -> {term(),state()}.    
handle_cast({notify_connect,Pid},State=#state{connected_clients_pid=Clist})->
	io:format("halla !!!"),
	gen_server:cast(Pid,okay_connect),
	{noreply,State#state{connected_clients_pid=[Pid|Clist]}};


%% @doc this callback for unknown casts
handle_cast(_Msg, State) ->
    {noreply, State}.
    
	
%% @doc this guy here is for handling downed workers .	
-spec handle_info(term(),state()) -> {term(),state()}.    
handle_info({'DOWN', Ref, process, Pid, _}, S = #state{refs=Refs}) ->
    io:format("received down msg from pid ~p~n",[Pid]),
    case gb_sets:is_element(Ref, Refs) of
        true ->
            handle_down_worker(Ref,Pid,S);
        false -> %% Not our responsibility
            {noreply, S}
    end;
    
    
%%t @doc this is used for starting the socket server supervisor,test gen server for sending testing messages  
%%this also  starts a  number of socket acceptors(as speficied in the .app file for the number of sockets ) once the socket supervisor has been started    
%%this also links this process to the socket server supervisor  as they depend on each other and killing one kills the other :)
%%test gen server is also started here 
handle_info({start_worker_supervisor, Sup}, S = #state{limit=N,refs=Refs}) ->
    {ok, Pid} = supervisor:start_child(Sup, ?SPEC()),
    {ok, _Test} = supervisor:start_child(Sup, ?TEST()),
    List_children=empty_listeners(Pid,N),
    Ref_list=lists:map(fun({ok,Cpid})-> erlang:monitor(process,Cpid) end,List_children),
    Mon_refs=lists:foldl(fun(X,Acc)-> gb_sets:add(X,Acc) end,Refs,Ref_list),
    link(Pid),
    {noreply, S#state{sup=Pid,limit=5,refs=Mon_refs}};


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


%% @doc for handling crashed sockets .new sockets will be added if the number is less than what is to be allowed
-spec handle_down_worker(reference(),pid(),state())->{noreply,state()}.
handle_down_worker(Ref,Pid_down,S = #state{limit=L,connected_clients_pid=Cpid ,sup=Sup, refs=Refs})when L > 0 ->
			io:format("Mayday i am down!!!:~n"),
            {ok, Pid} = supervisor:start_child(Sup, []),
            NewRef =    erlang:monitor(process, Pid),
            Conn_pids = lists:delete(Pid_down,Cpid), 
            NewRefs = gb_sets:insert(NewRef, gb_sets:delete(Ref,Refs)),
            {noreply, S#state{refs=NewRefs,connected_clients_pid=Conn_pids}};
    
    
 %% @doc for handling crashed sockets .new sockets arent added   
handle_down_worker(Ref,Pid_down,S = #state{limit=L,connected_clients_pid=Cpid, refs=Refs})when L=< 0 ->
			Conn_pids = lists:delete(Pid_down,Cpid), 
            {noreply, S#state{connected_clients_pid=Conn_pids,refs=gb_sets:delete(Ref,Refs)}}.


%% @doc for starting a socket acceptor
start_socket_child(Sup) ->
		supervisor:start_child(Sup, []).


%% @doc Start with number of  acceptors in the .app file in  so that many multiple connections can
%% be started at once, without serialization. In best circumstances,
%% a process would keep the count active at all times to insure nothing
%% bad happens over time when processes get killed too much.
empty_listeners(Sup,N) ->
		[start_socket_child(Sup) || _ <- lists:seq(1,N)].
