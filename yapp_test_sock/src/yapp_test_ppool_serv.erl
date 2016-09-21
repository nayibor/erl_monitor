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



start_link(Name, Limit, Sup) when is_atom(Name), is_integer(Limit) ->
    gen_server:start_link({local, Name}, ?MODULE, {Limit,Sup}, []).

start_socket(Name) ->
    gen_server:call(Name, start_sock).

get_num_sockets(Name)->
	gen_server:call(Name, num_sock).
	
get_refs_socks(Name)->
		gen_server:call(Name, get_refs_socks).


stop(Name) ->
    gen_server:call(Name, stop).

%% Gen server
init({Limit, Sup}) ->
    %% We need to find the Pid of the worker supervisor from here,
    %% but alas, this would be calling the supervisor while it waits for us!
    self() ! {start_worker_supervisor, Sup},
    {ok, #state{limit=Limit, refs=gb_sets:empty()}}.

handle_call(num_sock, _From, S = #state{limit=N}) ->
	{reply, {avail_sockets,N},S};
	
	
handle_call(start_sock, _From, S = #state{limit=N, sup=Sup, refs=R}) when N > 0 ->
    {ok, Pid} = supervisor:start_child(Sup, []),
    Ref = erlang:monitor(process, Pid),
    {reply, {ok,Pid}, S#state{limit=N-1, refs=gb_sets:add(Ref,R)}};
    

handle_call(start_sock, _From, S = #state{limit=N}) when N =< 0 ->
    {reply, {error,max_reached}, S};    


handle_call(get_refs_socks, _From, S=#state{connected_clients_pid=Clist}) ->
	{reply,{conn_clients,Clist},S};


handle_call(stop, _From, State) ->
    {stop, normal, ok, State};

handle_call(_Msg, _From, State) ->
    {noreply, State}.
    
handle_cast({notify_connect,Pid},State=#state{connected_clients_pid=Clist})->
	io:format("halla !!!"),
	gen_server:cast(Pid,okay_connect),
	{noreply,State#state{connected_clients_pid=[Pid|Clist]}};


handle_cast(_Msg, State) ->
    {noreply, State}.
    
	
handle_info({'DOWN', Ref, process, Pid, _}, S = #state{refs=Refs}) ->
    io:format("received down msg from pid ~p~n",[Pid]),
    case gb_sets:is_element(Ref, Refs) of
        true ->
            handle_down_worker(Ref,Pid,S);
        false -> %% Not our responsibility
            {noreply, S}
    end;
    
    
%%this is used for starting the socket server supervisor   
%%socket server should start a default of 20 sockets when created  
%%hasnt been done yet but will be done here soon
%%test gen server is also started here 
handle_info({start_worker_supervisor, Sup}, S = #state{limit=N,refs=Refs}) ->
    {ok, Pid} = supervisor:start_child(Sup, ?SPEC()),
    {ok, _Test} = supervisor:start_child(Sup, ?TEST()),
    List_children=empty_listeners(Pid,N),
    Ref_list=lists:map(fun({ok,Cpid})-> erlang:monitor(process,Cpid) end,List_children),
    Mon_refs=lists:foldl(fun(X,Acc)-> gb_sets:add(X,Acc) end,Refs,Ref_list),
    link(Pid),
    {noreply, S#state{sup=Pid,limit=5,refs=Mon_refs}};


handle_info(Msg, State) ->
    io:format("Unknown msg: ~p~n", [Msg]),
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.

%%for handling crashed sockets .new sockets will be added if the number is less than what is to be allowed
handle_down_worker(Ref,Pid_down,S = #state{limit=L,connected_clients_pid=Cpid ,sup=Sup, refs=Refs})when L > 0 ->
			io:format("Mayday i am down!!!:~n"),
            {ok, Pid} = supervisor:start_child(Sup, []),
            NewRef =    erlang:monitor(process, Pid),
            Conn_pids = lists:delete(Pid_down,Cpid), 
            NewRefs = gb_sets:insert(NewRef, gb_sets:delete(Ref,Refs)),
            {noreply, S#state{refs=NewRefs,connected_clients_pid=Conn_pids}};
    
handle_down_worker(Ref,Pid_down,S = #state{limit=L,connected_clients_pid=Cpid, refs=Refs})when L=< 0 ->
			Conn_pids = lists:delete(Pid_down,Cpid), 
            {noreply, S#state{connected_clients_pid=Conn_pids,refs=gb_sets:delete(Ref,Refs)}}.


start_socket_child(Sup) ->
		supervisor:start_child(Sup, []).

%% Start with 20 listeners so that many multiple connections can
%% be started at once, without serialization. In best circumstances,
%% a process would keep the count active at all times to insure nothing
%% bad happens over time when processes get killed too much.
empty_listeners(Sup,N) ->
		[start_socket_child(Sup) || _ <- lists:seq(1,N)].
