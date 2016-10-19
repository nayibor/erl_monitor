%%%
%%% @doc myapp_auth module.
%%%<br>contains module for doing authentication,crashes,and other library stuff</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_auth).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").

%%functions for processing pages
-export([
		 out/1,
		 out/2,
		 out/3,
		 out404/3,
		 out401/3,
		 crashmsg/3
		 ]).

-include_lib("yaws/include/yaws_api.hrl").
-include_lib("yapp_test/include/yapp_test.hrl").
 



%%% @doc validation still has to be done on username and password apart from empty check validation
%%% if yes user is taken to dashboard page/if no details are checked then they are logged in 
%%% check whether fields are empty
%%% validate them 
%%% pass them to routine for checking credentials
%%% @end

out(Arg) ->
		Uri = yaws_api:request_url(Arg),
		Path = string:tokens(Uri#url.path, "/"), 
		Method = (Arg#arg.req)#http_request.method,
		%%io:format("~nmethod is ~p~nrequest url ~p~n",[Method,Path]),
		out(Arg,Method,Path).
		
		
%% @doc this is for users whom are trying to login
out(Arg,'POST',[_,"auth","login"]) ->
		out(Arg,yapp_test_lib_sess:check_login(Arg,?COOKIE_VARIABLE));

%% @doc this is for loggin out users
out(Arg,'GET',[_,"auth","logout"]) ->
		yapp_test_lib_sess:kill_session(Arg,?COOKIE_VARIABLE),
		{redirect_local, yapp:prepath(Arg)++?INDEX_PAGE};
		
%%	@doc everything else is redirected to login page
out(Arg,_Method,_Path) ->		
		{redirect_local, yapp:prepath(Arg)++?INDEX_PAGE}.		

%%% @doc for checking to see whether uses arent  logged in before they are taken to the dashboard page
%%% users whom have to reset their pass(new users,users whose pass have been reset) are redirected to a reset pass to reset pass
%%% @end
out(Arg,error) ->
		%%io:format("post stuff is ~p\n",[yaws_api:parse_post(Arg)]),
		Post_data = yaws_api:parse_post(Arg),
		Username = proplists:get_value("username",Post_data),
		Password = proplists:get_value("password",Post_data),
		case Username=:=undefined  orelse Password=:=undefined orelse Username=:="" orelse Password=:=""  of
	        true ->
					{page,yapp:prepath(Arg)++?INDEX_PAGE};	
			_ ->
					case yapp_test_lib_usermod:verify_user(Username,Password) of
						{ok,Id,Fname,Site_id,Inst_id,false} ->
							User_Links = yapp_test_lib_usermod:get_user_links(Id),						
							Cookie = yapp_test_lib_sess:setup_session(Id,Fname,Site_id,Inst_id,?SESSION_MAX_TIME,User_Links),
							Data = {redirect_local, yapp:prepath(Arg)++?PG_DASHBOARD},
							CO = yaws_api:set_cookie(?COOKIE_VARIABLE,Cookie,[{path,yapp:prepath(Arg)}]),
							[Data, CO]; 	
						{ok,Id,Fname,Site_id,Inst_id,true} ->
							Cookie = yapp_test_lib_sess:setup_session(Id,Fname,Site_id,Inst_id,?SESSION_MAX_TIME,[]),
							Data = {redirect_local, yapp:prepath(Arg)++?PG_RESET_PASS},
							CO = yaws_api:set_cookie(?COOKIE_VARIABLE,Cookie,[{path,yapp:prepath(Arg)}]),
							[Data, CO];
						_  ->
							{page,yapp:prepath(Arg)++?INDEX_PAGE}
					end		
			
		
		end;


%%% @doc users whom are logged in are taken to the dashboard page
out(Arg,ok) ->
		{redirect_local, yapp:prepath(Arg)++?PG_DASHBOARD}.
		%%{page,yapp:prepath(Arg)++?PG_DASHBOARD}.
					
		
%%for error 404 messages page not found errors
out404(Arg,_GC,_SC) ->
		%%io:format("outpage path is  ~p",[yapp:prepath(Arg)++?PG_404]), 
		%%io:format("actuals path is  ~p",["/yapp_test/"++?PG_404]),
		{page,yapp:prepath(Arg)++?PG_404}.

%% @doc for unauthorized pages messages
out401(Arg,_Auth, _Realm) ->

	 %% {html,"<h1>pg unauth</h1>"}.
	    {page,yapp:prepath(Arg)++?PG_401}.
	   
%%% @doc for crashes which occur	   
crashmsg(Arg,_Auth, _Realm) ->

	%%  {html,"<h1>pg unauth</h1>"}.
	    {page,yapp:prepath(Arg)++?PG_CRASH}.	  

