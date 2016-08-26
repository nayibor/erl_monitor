%%%
%%% @doc yapp_test_lib_usermod module.
%%%<br>contains basic functions for performing CRUD functionality for users,roles</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(yapp_test_lib_usermod).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").
-include_lib("stdlib/include/qlc.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include_lib("yapp_test_lib/include/yapp_test_lib.hrl").


%%% for installing the basic tables needed for role based functionality/creating temp tables in case neede
-export([install/1,
		 temp_create/1,
		 add_auto_table/1,
		 get_auto_all/0,
		 get_set_auto/1]).

%%% for role stuff
-export([add_role_link/2,
		 add_role/3,
		 add_link/7,
		 get_roles/0,
		 get_role_links/1,
		 get_user_links/1,
		 find_link_details/1]).
		 
%%% for user stuff		 
-export([get_user_roles/1,
		 add_user/7,
		 add_user_roles/2,
		 get_users/0,
		 get_links/0,
		 verify_user/2,
		 get_users_filter/1
		 ]).

 

%%type definitions fore the above records
-type usermod_users() :: #usermod_users{}.
-type usermod_roles() :: #usermod_roles{}.
-type usermod_links() :: #usermod_links{}.
-type usermod_users_roles() :: #usermod_users_roles{}.
-type usermod_role_links() :: #usermod_role_links{}.
-type auto_inc() :: #auto_inc{}.

%%type definition for user category return type
-type single_link_tp() :: {atom(),atom(),atom()} .
-type single_user_cat() :: {atom(),[single_link_tp(), ...]} .
-type user_cat() :: [single_user_cat(),...] | [] .  
-type link_type() :: sidebar | ajax .

%%type definition for link
-type link_det() :: {atom(),atom(),atom()} .


%%max number of lockout_macro
-define(LOCKOUT_COUNTER_MAX,4).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%API%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% @doc this is used to create the basic tables that will be used in setups as well as in tests
-spec install([atom()]|[])-> ok | {badrpc, term()}.
install(Nodes)->
	
		ok = mnesia:create_schema(Nodes),
		rpc:multicall(Nodes, application, start, [mnesia]),
		mnesia:create_table(usermod_users,
							[{attributes, record_info(fields, usermod_users)},
							 {index, [#usermod_users.user_email,#usermod_users.inst_id]},
							 {disc_copies, Nodes}]),
		mnesia:create_table(usermod_roles,
							[{attributes, record_info(fields, usermod_roles)},
							 {index, [#usermod_roles.role_short_name]},
							 {disc_copies, Nodes}]), 
		mnesia:create_table(usermod_links,
							[{attributes, record_info(fields, usermod_links)},
							 {index, [#usermod_links.link_controller,#usermod_links.link_action]},
							 {disc_copies, Nodes}]), 
		mnesia:create_table(usermod_users_roles,
							[{attributes, record_info(fields, usermod_users_roles)},
							 {index, [#usermod_users_roles.role_id]},
							 {disc_copies, Nodes}, {type, bag}]), 
		mnesia:create_table(usermod_role_links,
							[{attributes, record_info(fields, usermod_role_links)},
							 {index, [#usermod_role_links.link_id]},
							 {disc_copies, Nodes}, {type, bag}]),                                           
		rpc:multicall(Nodes, application, stop, [mnesia]).
		
%%% @doc temp table for creating adhoc tables
-spec temp_create([atom()]|[])->ok.
temp_create(Nodes) ->
		mnesia:create_table(auto_inc,
							[{attributes, record_info(fields, auto_inc)},
							 {index, [#auto_inc.cvalue]},
							 {disc_copies, Nodes}]).

%%% for adding records to autoincrement table
add_auto_table(Tablename) ->
		F= fun()-> mnesia:write(#auto_inc{name=Tablename,cvalue=0}) end ,
		mnesia:activity(transaction,F).

%%% @doc get getting records in the autoincrement table 
-spec get_auto_all() -> [{atom(),atom()}] | [].
get_auto_all() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Tablename,Cvalue} ||
	             #auto_inc{name=Tablename,cvalue=Cvalue} <- mnesia:table(auto_inc)
	            ]))
	    end,
	    mnesia:activity(transaction, F).

%%%  @doc gets current autoincrement and gives it to requestor
%%%  resets value to cvalue +1 
get_set_auto(TableName)->
		
		Ofun=fun()->	
				F=fun()-> 
					  mnesia:read({auto_inc,TableName}) 
				end,
				case mnesia:activity(transaction,F) of
					[]->
						exit(error);
					[S = #auto_inc{name=Tablename,cvalue=Cvalue}]->
						ok=mnesia:activity(transaction,fun()->mnesia:write(S#auto_inc{cvalue=Cvalue+1})end),
						Cvalue
				end
		end,	
		mnesia:activity(transaction,Ofun).
		
	
%%  reset autoincremet value for table
%%reset_table_auto(TableName)
%%   	ok=mnesia:activity(transaction,fun()->mnesia:write(S#auto_inc{cvalue=Cvalue+1})end),
%% 

%%% @doc add user function which enables you to add users
%%id would have to be created specially in real worl scenario
%%will have to check whether user with email exists first before trying to add
%%validation may have to be carried out to make sure data is safe and of correct size and also required fields are avail
%%basic validation carried out for everything which is done here before anything is inserted
%% @end
-spec add_user(string(),pos_integer(),string(),string(),string(),pos_integer(),pos_integer())-> {error,user_exists} | ok | term()  .
add_user(Email,Id,Password,Fname,Lname,Siteid,Instid) ->    
		F = fun() ->
				case check_email(Email) of 
					ok ->
						Fun_add = fun() ->
							mnesia:write(#usermod_users{user_email=Email,id=Id,
								   password=Password,fname=Fname,
								   lname=Lname,site_id=Siteid,
								   inst_id=Instid
								   })
						end,
						mnesia:activity(transaction, Fun_add);
					exists ->
						{error,user_exists}
				end
		end,
		mnesia:activity(transaction,F).	


%%% @doc this is for testing purposes,in the real world an id would have been created in the db without the need for an id 
-spec add_role(pos_integer(),string(),string()) -> ok | term() .
add_role(Id,Role_short_name,Role_long_name) -> 
		F = fun() ->
				mnesia:write(#usermod_roles{id=Id,role_short_name=Role_short_name,
										role_long_name=Role_long_name})
		end,
		mnesia:activity(transaction,F).
			

%%% @doc add link
-spec add_link(pos_integer(),string(),string(),string(),string(),string(),link_type()) -> ok | term()  .
add_link(Id,Controller,Link_action,Link_allow,Link_category,Link_name,Link_type) ->
		F = fun() ->
				mnesia:write(#usermod_links{id=Id,link_controller=Controller,link_allow=Link_allow,link_type=Link_type,
										link_action=Link_action,link_category=Link_category,link_name=Link_name})
		end,
		mnesia:activity(transaction,F).
	

%%% @doc add role_link
-spec add_role_link(pos_integer(),pos_integer()) -> ok | {error,check_role_link} | term() .
add_role_link(RoleId,LinkId) ->
	    F = fun() ->
	            case mnesia:read({usermod_links, LinkId}) =:= [] orelse
	                 mnesia:read({usermod_roles, RoleId}) =:= [] of
						true ->
							{error,check_role_link};
						false ->
							mnesia:write(#usermod_role_links{role_id=RoleId,link_id=LinkId})
				end
	    end,
	    mnesia:activity(transaction,F).


%%% @doc add user_roles
-spec add_user_roles(pos_integer(),pos_integer()) -> ok | {error,check_user_role} | term()  .
add_user_roles(UserId,RoleId) ->
	    F = fun() ->
	            case mnesia:read({usermod_users, UserId}) =:= [] orelse
	                 mnesia:read({usermod_roles, RoleId}) =:= [] of
						true ->
							{error,check_user_role};
						false ->
							mnesia:write(#usermod_users_roles{user_id=UserId,role_id=RoleId})
				end
	    end,
	    mnesia:activity(transaction,F).




%%% @doc get_users
-spec get_users() -> [string()] | [] | term().
get_users() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Email,Fname,Site_id,Lname,Lock_stat} ||
	             #usermod_users{id=Id,user_email=Email,fname=Fname,site_id=Site_id,
								  lname=Lname,lock_status=Lock_stat} <- mnesia:table(usermod_users)
	            ]))
		end,
	    mnesia:activity(transaction, F).


%%%	@doc get_users_filter . filtered by fname,email,lname
-spec get_users_filter(string()) -> [string()] | [] | term() .
get_users_filter(UserDet) ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Email,Fname,Site_id,Lname,Lock_stat} ||
	             #usermod_users{id=Id,user_email=Email,fname=Fname,site_id=Site_id,
							    lname=Lname,lock_status=Lock_stat} <- mnesia:table(usermod_users),
				Email =:= UserDet orelse Fname =:= UserDet orelse Lname =:= UserDet				  
	            ]))
		end,
	    mnesia:activity(transaction, F).


%%%	@doc get_users_filter . filtered by fname,email,lname
-spec get_users_filter_old(string()) -> [usermod_users() | [] | term()] .
get_users_filter_old(UserDet)->
		Match = ets:fun2ms(
		fun(S=#usermod_users{user_email=Email,id=Id,fname=Fname,
							   lname=Lname,site_id=Siteid,inst_id=Instid
							   })
			when Email =:= UserDet orelse Fname =:= UserDet orelse Lname =:= UserDet ->
				S
		end
		),
		F=fun() -> mnesia:select(usermod_users, Match) end,
		mnesia:activity(transaction, F).

   

%%% @doc get_roles
-spec get_roles() -> [usermod_roles()] | [] | term().
get_roles() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S <- mnesia:table(usermod_roles)
	            ]))
		end,
	    mnesia:activity(transaction, F).
	
%%% @doc get links
-spec get_links() -> [usermod_links()] | [] | term().
get_links() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S <- mnesia:table(usermod_links)
	            ]))
	    end,
	    mnesia:activity(transaction, F).

%%% @doc verify_user
%%hash will have to be done of password before password is put into system
%%user is locked out after password is tried for  a predefined number of times
%% @end
-spec verify_user(string(),string())-> {error,check_username_password} | {error,check_username_password_lock} | {ok,pos_integer(),string()} | term() .
verify_user(Email,Password)->
	
		F_out=fun()->
				F = fun() ->
					qlc:eval(qlc:q(
					[S ||
					S = #usermod_users{user_email=Rc_email} <- mnesia:table(usermod_users),
					Rc_email =:= Email ]))
				end,
				case mnesia:activity(transaction,F) of 
						[] -> 
							{error,check_username_password}; 
						[S=#usermod_users{password=Rc_pass,lock_status=Lock_status}] when Rc_pass =/= Password andalso Lock_status < ?LOCKOUT_COUNTER_MAX  -> 
							ok=mnesia:activity(transaction,fun()->mnesia:write(S#usermod_users{lock_status=Lock_status+1})end),
							{error,check_username_password}; 
						[#usermod_users{password=Rc_pass,lock_status=Lock_status}] when Password =/= Rc_pass  andalso Lock_status >= ?LOCKOUT_COUNTER_MAX  -> 
							{error,check_username_password_lock}; 
						[S=#usermod_users{password=Rc_pass,id=Id,fname=Fname}] when Rc_pass =:= Password  ->	
							ok=mnesia:activity(transaction,fun()->mnesia:write(S#usermod_users{lock_status=0})end),
							{ok,Id,Fname}
				end
		end,
		mnesia:activity(transaction,F_out).
		

%%% @doc get_role_links 
-spec get_role_links(pos_integer()) -> [usermod_role_links()] | [] | term() .
get_role_links(RoleId) ->
		F=fun()->
			mnesia:read(usermod_role_links,RoleId)
		end,
		mnesia:activity(transaction,F).
	    
%%get_user_roles 
-spec get_user_roles(pos_integer()) -> [usermod_users_roles()] | [] | term() .
get_user_roles(UserId) ->
		F = fun()->
				mnesia:read(usermod_users_roles,UserId)
		end,
	    mnesia:activity(transaction,F).



%%% @doc this gets all the links for a particular user 
%%%data is put into a category format after this 
%%% @end 
-spec get_user_links(pos_integer()) -> user_cat() .
get_user_links(UserId)->
		F = fun() ->
				QH=qlc:q(
						[find_link_details(Rc_rl_lid) ||
						#usermod_users_roles{user_id=Rc_ur_uid,role_id=Rc_ur_rid} <- mnesia:table(usermod_users_roles),
						#usermod_role_links{role_id=Rc_rl_rid,link_id=Rc_rl_lid} <- mnesia:table(usermod_role_links),
						Rc_ur_rid =:=Rc_rl_rid andalso UserId =:= Rc_ur_uid]),
				qlc:fold(fun({Controller,Action,Category,Label,Link_Type}, Dict) ->
						dict:update(Category,fun(X) -> [{Controller,Action,Label,Link_Type}|X] end,[{Controller,Action,Label,Link_Type}|[]], Dict)
						end,
						dict:new(),
						QH)         
	    end, 
	    dict:to_list(mnesia:activity(transaction,F)).



%%%%%%%%%%%%%%%%%%%%%%%%%
%%%PRIVATE FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%
%% @private for checking whether an email exists or not 
-spec check_email(atom()) -> ok | exists . 
check_email(Email)->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{User_Em} ||
	             #usermod_users{user_email=User_Em} <- mnesia:table(usermod_users),
	             User_Em =:= Email]))
			end,
	    case mnesia:activity(transaction, F) of
	        [] ->  ok;
	        _  ->  exists
	    end.
    
%% @private returns link details of a particular linkk
-spec find_link_details(pos_integer()) -> link_det() | undefined . 
find_link_details(Linkid)->
		F = fun() ->
				qlc:eval(qlc:q( 
							  [{Link_controller,Link_action,Link_category,Link_name,Link_type} ||
							  #usermod_links{id=RcLinkid,link_allow=Link_allow,
							  link_controller=Link_controller,link_action=Link_action,
							  link_category=Link_category,link_name=Link_name,link_type=Link_type
							  } <- mnesia:table(usermod_links),
				Linkid =:=RcLinkid andalso Link_allow =:= true]))
		end,
	    case mnesia:activity(transaction, F) of
	        [] ->undefined;
	        [S] -> S
	    end.
 
 %% @TODO Finish checking for the correct return type for mnesia:activity/2 to aid in dialyzer analysis
 %% @TODO seperate error checking code from normal code    
