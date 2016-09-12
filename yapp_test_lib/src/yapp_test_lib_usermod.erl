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
		 get_set_auto/1,
		 read_table_all/1,
		 transform_table_check/0
		 ]).

%%% for role stuff
-export([add_role_link/2,
		 add_role/2,
		 add_role_link_list/2,
		 add_link/6,
		 edit_link/7,
		 edit_role/3,
		 get_roles/0,
		 get_roles_id/1,
		 get_roles_filter/1,
		 get_role_links_setup/1,
		 get_role_links/1,
		 get_user_links/1,
		 get_links_for_roles/0,
		 get_links/0,
		 get_links_id/1,
		 get_links_filter/1,
		 find_link_details/1]).
		  
%%% for user stuff		 
-export([get_user_roles/1,
		 add_user/4,
		 add_user_roles/2,
		 get_users/0,
		 verify_user/2,
		 get_users_filter/1,
		 edit_user/5,
		 check_email/3,
		 get_user_id/1,
		 reset_pass/1,
		 lock_account/1,
		 unlock_account/1,
		 get_users_terminal/0,
		 add_user_role_list/2,
		 delete_user_roles/1,
		 check_list_roles/1,
		 check_list_links/1,
		 get_users_for_rules/0
		 ]).

 %%for site stuff
-export([
		add_site/3,
		get_sites/0,
		get_site_name/1,
		get_site_id/1,
		update_site/4,
		get_filter_site/1
		]).
 
 
 
 %%for inst stuff
-export([
		add_inst/3,
		get_inst/0,
		edit_inst/4,
		get_inst_filter/1,
		get_inst_id/1
 
		]).
 
  %%for category stuff
-export([
		add_cat/1 ,
		get_cats/0,
		get_catname/1
		]).
 
 
 

%%type definitions fore the above records
-type usermod_users() :: #usermod_users{}.
-type usermod_roles() :: #usermod_roles{}.
-type usermod_links() :: #usermod_links{}.
-type usermod_users_roles() :: #usermod_users_roles{}.
-type usermod_role_links() :: #usermod_role_links{}.
-type usermod_sites() :: #usermod_sites{}.
-type usermod_inst() :: #usermod_inst{}.
-type usermod_cat() :: #usermod_categories{}.


%%-type auto_inc() :: #auto_inc{}.

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
		mnesia:create_table(usermod_rules_users,
							[{attributes, record_info(fields, usermod_rules_users)},
							 {index, []},
							 {disc_copies, Nodes}, {type, bag}]).
							 
							 
temp_del()->

		mnesia:delete_table(tempmod_rules_temp).
		
transform_table_check()->

mnesia:transform_table(
 tempmod_rules_temp, 
 fun({id,inst_id,template_id,template_ident,rule_fun,rule_options,description,category_rule,rule_status,rule_users}) ->
      {id,site_id,template_id,rule_fun,rule_options,description,category_rule,rule_status=disabled,rule_users=[]}
 end,
 record_info(fields, tempmod_rules_temp)).	
		

%%% for adding records to autoincrement table
add_auto_table(Tablename) ->
		F= fun()-> mnesia:write(#auto_inc{name=Tablename,cvalue=1}) end ,
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
					[S = #auto_inc{cvalue=Cvalue}]->
						ok=mnesia:activity(transaction,fun()->mnesia:write(S#auto_inc{cvalue=Cvalue+1})end),
						Cvalue
				end
		end,	
		mnesia:activity(transaction,Ofun).
		
		
%%this is used for reading the contents of a random table 
%%table name is supplied as an arguement		
read_table_all(Table_name)->
				F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S <- mnesia:table(Table_name)
	            ]))
	    end,
	    mnesia:activity(transaction, F).
		
		
		
	
%%  reset autoincremet value for table
%%reset_table_auto(TableName)
%%   	ok=mnesia:activity(transaction,fun()->mnesia:write(S#auto_inc{cvalue=Cvalue+1})end),
%% 

%%% @doc add user function which enables you to add users
%%id would have to be created specially in real worl scenario
%%will have to check whether user with email exists first before trying to add
%%validation may have to be carried out to make sure data is safe and of correct size and also required fields are avail
%%basic validation carried out for everything which is done here before anything is inserted
%%validation added to make sure user site already exists
%% @end
-spec add_user(string(),string(),string(),pos_integer())-> {error,term()} | ok | term().
add_user(Email,Fname,Lname,Siteid) ->    
		F = fun() ->	
				case check_email(Email,add_user,0) =:= exists orelse
	                 mnesia:read({usermod_sites, Siteid}) =:= [] of
						true ->
							{error,check_user_site};
						false ->
							Fun_add = fun() ->
									mnesia:write(#usermod_users{user_email=Email,id=get_set_auto(usermod_users),
										   password=gen_pass(),fname=Fname,
										   lname=Lname,site_id=Siteid
										   })
							end,
							mnesia:activity(transaction, Fun_add)
				end
		end,	
		mnesia:activity(transaction,F).

%% @doc this is for reseting the pass of the use  
-spec reset_pass(pos_integer())->{ok,string()} | {error,term()}.
reset_pass(Id) ->
		Fout = fun () -> 
			F = fun()->
					mnesia:read(usermod_users,Id)
			end,
			case mnesia:activity(transaction,F) of
				[S] ->
					Npass = gen_pass(),
					Edit_tran = fun()-> mnesia:write(S#usermod_users{password=Npass}) end,
					ok=mnesia:activity(transaction,Edit_tran),
					{ok,Npass};	
				_ ->
					{error,user_non_exists}
			end
		end,
		mnesia:activity(transaction,Fout).


%% @doc this is for locking the account of the user so the user cant lock in 
-spec lock_account(pos_integer())-> ok | {error,term()} | term().
lock_account(Id) ->
		Fout = fun () -> 
			F = fun()->
					mnesia:read(usermod_users,Id)
			end,
			case mnesia:activity(transaction,F) of
				[S] ->
					Edit_tran = fun()-> mnesia:write(S#usermod_users{lock_status=?LOCKOUT_COUNTER_MAX}) end,
					mnesia:activity(transaction,Edit_tran);
				_ ->
					{error,user_non_exists}
			end
		end,
		mnesia:activity(transaction,Fout).


%% @doc this is for unlocking the account of the user so the user cant lock in 
-spec unlock_account(pos_integer())-> ok | {error,term()} | term().
unlock_account(Id) ->
		Fout = fun () -> 
			F = fun()->
					mnesia:read(usermod_users,Id)
			end,
			case mnesia:activity(transaction,F) of
				[S] ->
					Edit_tran = fun()-> mnesia:write(S#usermod_users{lock_status=0}) end,
					mnesia:activity(transaction,Edit_tran);
				_ ->
					{error,user_non_exists}
			end
		end,
		mnesia:activity(transaction,Fout).


%% @doc  for editing users 
%%  the user is searched for using the id then the rest of the fields which have values are modified
%% since there is no way to manuall update only portions of a record in mnesia 
-spec edit_user(pos_integer(),string(),string(),string(),pos_integer())-> ok |{error,term()} | term(). 
edit_user(Id,Email,Fname,Lname,Siteid)->

		Fout = fun () -> 
			F = fun()->
					mnesia:read(usermod_users,Id)
			end, 
			%%mnesia:activity(transaction,fun()->mnesia:read(usermod_users,5)		
		    case mnesia:activity(transaction,F) of 
				[S] ->
						case check_email(Email,edit_user,Id) of 
							ok ->
								Edit_tran = fun()-> mnesia:write(S#usermod_users{id=Id,user_email=Email,fname=Fname,lname=Lname,site_id=Siteid}) end,
								ok=mnesia:activity(transaction,Edit_tran);
							_ ->
								{error,email_exists_diff_user}
						end;
				_	->
					{error,user_non_exists}
			end	
		end,
		mnesia:activity(transaction,Fout).
		
%%% @doc this is for testing purposes,in the real world an id would have been created in the db without the need for an id 
-spec add_role(binary(),binary()) -> ok | term() .
add_role(Role_short_name,Role_long_name) -> 

		F = fun() ->
				mnesia:write(#usermod_roles{id=get_set_auto(usermod_roles),role_short_name=Role_short_name,
										role_long_name=Role_long_name})
		end,
		mnesia:activity(transaction,F).
		
%%for editing roles/temp				
-spec edit_role(pos_integer(),binary(),binary()) -> ok | term() .
edit_role(Id,Role_short_name,Role_long_name) -> 

		F = fun() ->
				mnesia:write(#usermod_roles{id=Id,role_short_name=Role_short_name,
										role_long_name=Role_long_name})
		end,
		mnesia:activity(transaction,F).	
	
	
	
%%% @doc get roles by id 
-spec get_roles_id(pos_integer()) -> [usermod_roles()] | [] | term().
get_roles_id(Roleid) ->
		F=fun()->
			mnesia:read(usermod_roles,Roleid)
		end,
		case mnesia:activity(transaction,F) of 
			[S] ->
				{ok,S};
			_ ->
				{error,role_non_exists}
		end.	
	
	
	
%%% @doc get sites by id 
-spec get_site_id(pos_integer()) -> [usermod_sites()] | [] | term().
get_site_id(Siteid) ->
		F=fun()->
			mnesia:read(usermod_sites,Siteid)
		end,
		case mnesia:activity(transaction,F) of 
			[S] ->
				{ok,S};
			_ ->
				{error,role_non_exists}
		end.		
	
			

%%% @doc add link
-spec add_link(string(),string(),string(),string(),string(),link_type()) -> ok | term()  .
add_link(Controller,Link_action,Link_allow,Link_category,Link_name,Link_type) ->
		F = fun() ->
				mnesia:write(#usermod_links{id=get_set_auto(usermod_links),link_controller=Controller,link_allow=Link_allow,link_type=Link_type,
										link_action=Link_action,link_category=Link_category,link_name=Link_name})
		end,
		mnesia:activity(transaction,F).
	
	
%%edit_link	 
-spec edit_link(pos_integer(),string(),string(),string(),string(),string(),link_type()) -> ok | term()  .
edit_link(Id,Controller,Link_action,Link_allow,Link_category,Link_name,Link_type) ->
	Fout = fun () -> 
				F = fun()->
						mnesia:read(usermod_links,Id)
				end, 
			    case mnesia:activity(transaction,F) of 
					[S] ->	
						mnesia:write(S#usermod_links{id=Id,link_controller=Controller,link_allow=Link_allow,link_type=Link_type,
											link_action=Link_action,link_category=Link_category,link_name=Link_name});
					_ ->
						{error,link_doesnt_exist}
				end
	end,
	mnesia:activity(transaction,Fout).
	
	
	

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


%% @doc for adding a list of roles for user .
%% deletes old user roles and inserts a new list  .have to find better way of throwing exceptions 
-spec add_user_role_list(pos_integer(),[pos_integer()])-> ok | {error,check_user_role} | term().
add_user_role_list(Userid,RoleListId)->
		
		F = fun() ->
		
				case mnesia:read({usermod_users, Userid}) =:= [] orelse
					 check_list_roles(RoleListId) =:= true of
					true ->
						{error,check_user_role};
					false ->
						ok = delete_user_roles(Userid),
						Res=lists:map(fun(Role)->add_user_roles(Userid,Role)end,RoleListId),
						case lists:member({error,check_user_role},Res) of
							true ->
								exit(error);
							false  -> 
								ok
						end
				end
				
		end ,		
		mnesia:activity(transaction,F).

		
%% @doc for deleting a users role
-spec delete_user_roles(pos_integer()) -> ok | term().		
delete_user_roles(Userid)->	
		F = fun()->
				mnesia:delete({usermod_users_roles,Userid}) end , 
		mnesia:activity(transaction,F).


		
		
		
%%for  setting up the links that a role is allowed access to 	
-spec add_role_link_list(pos_integer(),[pos_integer()])-> ok | {error,check_role_exist} | term().	
add_role_link_list(Roleid,Linklist) ->

		F = fun() ->
		
				case mnesia:read({usermod_roles, Roleid}) =:= [] orelse
					check_list_links(Linklist) =:= true of
					true ->
						{error,check_role_exist};
					false ->
						ok = delete_role_links(Roleid),
						Res=lists:map(fun(Link)->add_role_link(Roleid,Link)end,Linklist),
						case lists:member({error,check_role_link},Res) of
							true ->
								exit(error);
							false  -> 
								ok
						end
				end
				
		end ,		
		mnesia:activity(transaction,F).


%%for deleting role links
-spec delete_role_links(pos_integer()) -> ok | term().		
delete_role_links(Roleid)->	
		F = fun()->
				mnesia:delete({usermod_role_links,Roleid}) end , 
		mnesia:activity(transaction,F).



%%for checking for the existance of roles in a a list of roles

check_list_roles(Roles)->

	lists:member([],mnesia:activity(transaction,fun()->lists:map(fun(Roleid)->mnesia:read({usermod_roles, Roleid})end ,Roles) end)). 

%% for checking for the existance of links in a list of links
check_list_links(Links)->
	lists:member([],mnesia:activity(transaction,fun()->lists:map(fun(Linkid)->mnesia:read({usermod_links, Linkid})end ,Links)end)). 


%% @doc for adding sites
-spec add_site(binary(),binary(),pos_integer())-> ok | {error,inst_none_exist}  |  term() .
add_site(Short_name,Long_name,Instid)->
		F = fun() ->
		
			case mnesia:read({usermod_inst, Instid}) =:= [] of
				true ->
					{error,inst_none_exist};
				false ->		
					mnesia:write(#usermod_sites{id=get_set_auto(usermod_sites),site_short_name=Short_name,
											site_long_name=Long_name,inst_id=Instid})
			end
		end,
		mnesia:activity(transaction,F).


%% @doc for updating  sites--temp measure
-spec update_site(pos_integer(),binary(),binary(),pos_integer())-> ok | {error,inst_none_exist}  |  term() .
update_site(Id,Short_name,Long_name,Instid)->
		F = fun() ->
		
			case mnesia:read({usermod_inst, Instid}) =:= [] of
				true ->
					{error,inst_none_exist};
				false ->		
					mnesia:write(#usermod_sites{id=Id,site_short_name=Short_name,
											site_long_name=Long_name,inst_id=Instid})
			end
		end,
		mnesia:activity(transaction,F).



%% @doc for adding categories
-spec add_cat(binary())-> ok | term() .
add_cat(Category)->
		F = fun() ->
				mnesia:write(#usermod_categories{id=get_set_auto(usermod_categories),category=Category})
		end,
		mnesia:activity(transaction,F). 

%% @doc for adding categories
-spec get_cats()-> [usermod_cat()] | [] | term().
get_cats()->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S <- mnesia:table(usermod_categories)
	            ]))
	    end,
	    mnesia:activity(transaction, F).



%% @doc for adding categories
-spec get_catname(pos_integer())-> binary().
get_catname(Id)->
		F = fun()->
					mnesia:read(usermod_categories,Id)
			end,
	    case mnesia:activity(transaction, F) of
			[#usermod_categories{category=Cat}]->Cat;
			 _-> <<>>
		end.



%%% @doc get sites
-spec get_sites() -> [usermod_sites()] | [] | term().
get_sites() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Site_s,Site_l,get_inst_name(Inst)} ||
	             S=#usermod_sites{id=Id,site_long_name=Site_l,site_short_name=Site_s,inst_id=Inst} <- mnesia:table(usermod_sites)
	            ]))
	    end,
	    mnesia:activity(transaction, F).


%% @doc for searching for a site  
-spec get_filter_site(binary())-> [usermod_sites()] | [] | term().
get_filter_site(Filter) ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Site_s,Site_l,get_inst_name(Inst)} ||
	             S=#usermod_sites{id=Id,site_long_name=Site_l,site_short_name=Site_s,inst_id=Inst} <- mnesia:table(usermod_sites),
	             binary:match(Site_l,Filter) =/= nomatch orelse binary:match(Site_s,Filter) =/= nomatch
	            ]))
	    end,
	    mnesia:activity(transaction, F).


%%@doc for getting a site name
-spec get_site_name(pos_integer())->binary(). 
get_site_name(Siteid) ->
		
		F = fun()->
				mnesia:read(usermod_sites,Siteid)
			end,
	    case mnesia:activity(transaction, F) of
			[#usermod_sites{site_long_name=Site_name}]->Site_name;
			 _-> <<>>
		end.
		

%%@doc for getting an institutions name
-spec get_inst_name(pos_integer())->binary(). 
get_inst_name(Std) ->
		
	    F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S=#usermod_inst{id=Instid} <- mnesia:table(usermod_inst),
	             Std =:= Instid
	            ]))         
	    end,
	    case mnesia:activity(transaction, F) of
			[#usermod_inst{inst_long_name=Long_name}]->Long_name;
			 _-> <<>>
		end. 




%% @doc for adding instutions
-spec add_inst(binary(),binary(),binary())-> ok | term() .
add_inst(Short_name,Long_name,Ident)->
		F = fun() ->
				case check_ident(Ident,add_inst,0) of 
					ok ->
						mnesia:write(#usermod_inst{id=get_set_auto(usermod_inst),inst_short_name=Short_name,inst_long_name=Long_name,inst_ident=Ident});
					exists ->
						{error,ident_exists_diff_user}
				end
		end,
		mnesia:activity(transaction,F).

%% @doc for edint instutions
-spec edit_inst(pos_integer(),binary(),binary(),binary())-> ok | term() .
edit_inst(Id,Short_name,Long_name,Ident)->
		
		Fout = fun () -> 
			F = fun()->
					mnesia:read(usermod_inst,Id)
			end, 
			%%mnesia:activity(transaction,fun()->mnesia:read(usermod_users,5)		
		    case mnesia:activity(transaction,F) of 
				[S] ->
						case check_ident(Ident,edit_inst,Id) of 
							ok ->
								Edit_tran = fun()-> mnesia:write(S#usermod_inst{inst_short_name=Short_name,inst_long_name=Long_name,inst_ident=Ident}) end,
								ok=mnesia:activity(transaction,Edit_tran);
							_ ->
								{error,ident_exists_diff_user}
						end;
				_	->
					{error,inst_non_exists}
			end	
		end,
		mnesia:activity(transaction,Fout).


%%% @doc for getting institutions
-spec get_inst() -> [usermod_inst()] | [] | term().
get_inst() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S <- mnesia:table(usermod_inst)
	            ]))
	    end,
	    mnesia:activity(transaction, F).


%%% @doc for getting institutions using a filter 
-spec get_inst_filter(binary()) -> [usermod_inst()] | [] | term().
get_inst_filter(Filter) ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S=#usermod_inst{id=Id,inst_short_name=Short_name,inst_long_name=Long_name,inst_ident=Ident} <- mnesia:table(usermod_inst),
	             binary:match(Short_name,Filter) =/= nomatch orelse binary:match(Long_name,Filter) =/= nomatch 
	             orelse binary:match(Ident,Filter) =/= nomatch
	            ]))
	    end,
	    mnesia:activity(transaction, F).

%% @doc get inst by id
-spec get_inst_id(pos_integer()) -> usermod_inst() | {error,site_non_exists} .
get_inst_id(Id) ->
			F = fun()->
					mnesia:read(usermod_inst,Id)
			end,
		    case mnesia:activity(transaction,F) of 
				[S] ->
				    S;
				_ ->
				   {error,inst_non_exists}
		    end.





%%% @doc get_users for terminal
-spec get_users_terminal() -> [string()] | [] | term().
get_users_terminal() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Email,Fname,Lname,Site_id,format_lock_counter(Lock_stat),Lock_stat,Pwd} ||
	             #usermod_users{id=Id,user_email=Email,fname=Fname,site_id=Site_id,password=Pwd,
								  lname=Lname,lock_status=Lock_stat} <- mnesia:table(usermod_users)
	            ]))
		end,
	    mnesia:activity(transaction, F).


%%% @doc get_users
-spec get_users() -> [tuple()] | [] | term().
get_users() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Email,Fname,Lname,Site_id,format_lock_counter(Lock_stat),status_url_form(Lock_stat),lock_class_form(Lock_stat),lock_label_form(Lock_stat),get_site_name(Site_id)} ||
	             #usermod_users{id=Id,user_email=Email,fname=Fname,site_id=Site_id,
								  lname=Lname,lock_status=Lock_stat} <- mnesia:table(usermod_users)
	            ]))
		end,
	    mnesia:activity(transaction, F).
	    
	
%%% @doc get_users
-spec get_users_for_rules() -> [tuple()] | [] | term().
get_users_for_rules() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Fname,Lname} ||
	             #usermod_users{id=Id,fname=Fname,lname=Lname} <- mnesia:table(usermod_users)
	            ]))
		end,
	    mnesia:activity(transaction, F).	
	    
	    

%% @doc get users by id
-spec get_user_id(pos_integer()) -> tuple().
get_user_id(Id) ->
			F = fun()->
					mnesia:read(usermod_users,Id)
			end,
		    case mnesia:activity(transaction,F) of 
				[#usermod_users{id=Id,user_email=Email,fname=Fname,lname=Lname,site_id=Siteid}] ->
				    {Id,Email,Fname,Lname,Siteid};
				_ ->
				   {error,user_non_exists}
		    end.


%%%	@doc get_users_filter . filtered by fname,email,lname
-spec get_users_filter(string()) -> [string()] | [] | term() .
get_users_filter(UserDet) ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Email,Fname,Lname,Site_id,format_lock_counter(Lock_stat),status_url_form(Lock_stat),lock_class_form(Lock_stat),lock_label_form(Lock_stat),get_site_name(Site_id)}||
	             #usermod_users{id=Id,user_email=Email,fname=Fname,site_id=Site_id,
							    lname=Lname,lock_status=Lock_stat} <- mnesia:table(usermod_users),
				Email =:= UserDet orelse Fname =:= UserDet orelse Lname =:= UserDet				  
	            ]))
		end,
	    mnesia:activity(transaction, F).



	
	
%%% @doc get roles
-spec get_roles() -> [usermod_roles()] | [] | term().
get_roles() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	           S<- mnesia:table(usermod_roles)
	            ]))
	    end,
	    mnesia:activity(transaction, F).
	
%%@doc for getting roles with the added twist of a filter
-spec get_roles_filter(binary()) -> [usermod_roles()] | [] | term().
get_roles_filter(Filter) ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	            S=#usermod_roles{role_short_name=Rsn,role_long_name=Rln} <- mnesia:table(usermod_roles),
	           binary:match(Rsn,Filter) =/= nomatch orelse binary:match(Rln,Filter) =/= nomatch
	            ]))
	    end,
	    mnesia:activity(transaction, F).	
	
	
	
%%% @doc get links
-spec get_links() -> [usermod_links()] | [] | term().
get_links() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S#usermod_links{link_category=get_catname(Link_category)} ||
	             S=#usermod_links{link_category=Link_category} <- mnesia:table(usermod_links)
	            ]))
	    end,
	    mnesia:activity(transaction, F).
	    
%%% @doc get links for using to create rolelinks
-spec get_links_for_roles() -> [usermod_links()] | [] | term().
get_links_for_roles() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Id,Lname,atom_to_binary(Ltype,utf8)} ||
	             #usermod_links{link_category=Link_category,id=Id,link_name=Lname,link_type=Ltype} <- mnesia:table(usermod_links)
	            ]))
	    end,
	    mnesia:activity(transaction, F).	    
	    

%%% @doc get links
-spec get_links_id(pos_integer()) -> [usermod_links()] | [] | term().
get_links_id(LinkId) ->
		F=fun()->
			mnesia:read(usermod_links,LinkId)
		end,
		case mnesia:activity(transaction,F) of 
			[S] ->
				{ok,S};
			_ ->
				{error,link_non_exists}
		end.




%%%% @doc get link but now a filter is involved 
-spec get_links_filter(string()) -> [usermod_links()] | [] | term().
get_links_filter(Filter) ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [
					S#usermod_links{link_category=get_catname(Link_category)}||
					S=#usermod_links{link_allow=Link_allow,
							  link_controller=Link_controller,link_action=Link_action,
							  link_category=Link_category,link_name=Link_name,link_type=Link_type}
							  <-  mnesia:table(usermod_links),
								Filter =:= Link_allow orelse Filter =:= Link_controller orelse Filter =:= Link_action 
								orelse Filter =:= Link_category orelse Filter =:= Link_name orelse Filter =:= Link_type  
								orelse list_to_atom(Filter) =:= Link_type orelse list_to_atom(Filter) =:= Link_allow
	            ]))
	    end,
	    mnesia:activity(transaction, F).		






%%% @doc verify_user
%%hash will have to be done of password before password is put into system
%%user is locked out after password is tried for  a predefined number of times
%% @end
-spec verify_user(string(),string())-> {error,check_username_password} | {error,check_username_password_lock} | {ok,pos_integer(),string(),pos_integer(),pos_integer()} | term() .
verify_user(Email,Password)->
	
		F_out=fun()->
				F = fun() ->
					qlc:eval(qlc:q(
					[S ||
					S = #usermod_users{user_email=Rc_email} <- mnesia:table(usermod_users),
					Rc_email =:= Email ]))
				end,
				%%useranme and password is wrong and lock is less th
				case mnesia:activity(transaction,F) of  
						[] -> 
							{error,check_username_password}; 
						[S=#usermod_users{password=Rc_pass,lock_status=Lock_status}] when Password =/=Rc_pass andalso Lock_status < ?LOCKOUT_COUNTER_MAX  -> 
							ok=mnesia:activity(transaction,fun()->mnesia:write(S#usermod_users{lock_status=Lock_status+1})end),
							{error,check_username_password}; 
						[#usermod_users{password=Rc_pass,lock_status=Lock_status}] when Password =/= Rc_pass  andalso Lock_status >= ?LOCKOUT_COUNTER_MAX  -> 
							{error,check_username_password_lock}; 
						[#usermod_users{password=Rc_pass,lock_status=Lock_status}] when Password =:=Rc_pass andalso Lock_status >= ?LOCKOUT_COUNTER_MAX ->	
							{error,check_username_password_lock}; 
						[S=#usermod_users{site_id=Site_id,inst_id=Inst_id,password=Rc_pass,id=Id,fname=Fname,lock_status=Lock_status}] when Password =:=Rc_pass andalso Lock_status < ?LOCKOUT_COUNTER_MAX ->	
							ok=mnesia:activity(transaction,fun()->mnesia:write(S#usermod_users{lock_status=0})end),
							{ok,Id,Fname,Site_id,Inst_id}
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
	    
	    
%%% @doc get_role_links for link setup
-spec get_role_links_setup(pos_integer()) -> [integer()] |[] .
get_role_links_setup(RoleId) ->
		F=fun()->
			mnesia:read(usermod_role_links,RoleId)
		end,
		case mnesia:activity(transaction,F) of
			[] ->
				[];
			S ->
				lists:map(fun(#usermod_role_links{role_id=Role_id,link_id=Link_id})->Link_id end,S)
		end.
	
	    
%%get_user_roles 
-spec get_user_roles(pos_integer()) -> [usermod_users_roles()] | [] | term() .
get_user_roles(Userid_search) ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [Roleid ||
	             #usermod_users_roles{user_id=Userid,role_id=Roleid} <- mnesia:table(usermod_users_roles),
	             Userid_search =:= Userid
	            ]))
	    end,
	    mnesia:activity(transaction, F).


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
				qlc:fold(fun({Controller,Action,Category,Label,Link_Type,Link_allow}, Dict) when Link_allow =:= true ->
								dict:update(Category,fun(X) -> [{Controller,Action,Label,Link_Type}|X] end,[{Controller,Action,Label,Link_Type}|[]], Dict);
							(_,Dict) ->
								Dict
						end,
						dict:new(),
						QH)         
	    end, 
	    dict:to_list(mnesia:activity(transaction,F)).



%%%%%%%%%%%%%%%%%%%%%%%%%
%%%PRIVATE FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%

status_url_form(Lock_stat) when Lock_stat >= ?LOCKOUT_COUNTER_MAX -> "user/unlock_account_user"++"/" ;
status_url_form(Lock_stat) when Lock_stat < ?LOCKOUT_COUNTER_MAX -> "user/lock_account_user"++"/" .


lock_class_form(Lock_stat) when Lock_stat >= ?LOCKOUT_COUNTER_MAX -> "inlineIcon preferences "++"iconopen unlock" ;
lock_class_form(Lock_stat) when Lock_stat < ?LOCKOUT_COUNTER_MAX -> "inlineIcon preferences "++"iconlock lock" .

lock_label_form(Lock_stat) when Lock_stat >= ?LOCKOUT_COUNTER_MAX -> "Unlock" ;
lock_label_form(Lock_stat) when Lock_stat < ?LOCKOUT_COUNTER_MAX -> "Lock" .

 
%% @private formats lock counter for external viewing
format_lock_counter(Lock_counter) when Lock_counter >= ?LOCKOUT_COUNTER_MAX-> "Locked";
format_lock_counter(Lock_counter) when Lock_counter < ?LOCKOUT_COUNTER_MAX -> "Active".

		
%% @private for checking whether an email exists or not 
%% first condition is for checking whether email exists for a new user 
%% second condition is for making sure a seperate user does not have email address when trying to edit
-spec check_email(string(),atom(),pos_integer()) -> ok | exists . 
check_email(Email,Type,Id)->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{User_Em} ||
	             #usermod_users{user_email=User_Em,id=Id_old} <- mnesia:table(usermod_users),
	             User_Em =:= Email andalso Type =:= add_user 
	             orelse User_Em =:= Email andalso Type =:=  edit_user andalso Id =/= Id_old]))
			end,
	    case mnesia:activity(transaction, F) of
	        [] ->  ok;
	        _  ->  exists
	    end.
	    
	    
%% @private for checking whether an ident  exists for a seperate institution  
%% first condition is for checking whether ident exists when creating a new ident 
%% second condition is for making sure a seperate inst does not exist for seperate user when trying to edit
-spec check_ident(binary(),atom(),pos_integer()) -> ok | exists . 
check_ident(Ident,Type,Id)->
		F = fun() ->
				qlc:eval(qlc:q(
	            [{Ident_rc} ||
	            #usermod_inst{id=Id_old,inst_ident=Ident_rc} <- mnesia:table(usermod_inst),
	             Ident =:= Ident_rc andalso Type =:= add_inst 
	             orelse Ident =:= Ident_rc andalso Type =:=  edit_inst andalso Id =/= Id_old]))
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
							  [{Link_controller,Link_action,get_catname(Link_category),Link_name,Link_type,Link_allow} ||
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
 
 
 		
%%%%@doc very very weak internal way for generating passwords
%%%%%	 dont use even if your life is being threatened :):).no seriously!!!
gen_pass() ->
		Base = "-_=+abcdefghijklmnopqrstuvwxyz!@#$%^&ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
		<<A:32, B:32, C:32>> = crypto:rand_bytes(12),
		random:seed(A,B,C),
		lists:append([gen_weak_char(Base)||_<-lists:seq(1,10)]).


gen_weak_char(Base) ->
		Select_dig = random:uniform(string:len(Base)),
		string:sub_string(Base,Select_dig,Select_dig).
 
 %% @TODO Finish checking for the correct return type for mnesia:activity/2 to aid in dialyzer analysis
 %% @TODO change the hash type
 %% @TODO optimize how the link categories are retrieved 
 %% @TODO encrypt user passwords with bcrypt when creating ,editing,verifying user passwords
