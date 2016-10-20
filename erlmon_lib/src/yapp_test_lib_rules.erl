
%%% 
%%% @doc function for playing around with the rules
%%%<br></br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_lib_rules).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").

-include_lib("stdlib/include/qlc.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include_lib("erlmon_lib/include/yapp_test_lib.hrl").


%%this part is for templates
-export([get_rules/0,
		 get_rules_filter/1,
		 add_rule/6,
		 edit_rule/7,
		 setup_rule_fun/2,
		 get_template_rule_cat/1,
		 get_rule_cats/0,
		 get_rule_id/1,
		 get_rule_members/1,
		 save_member_rules/2,
		 del_rule/1
		 ]).
		  
		 
%%type definitions fore the above records
-type tempmod_rules_temp() :: #tempmod_rules_temp{}.		 
		 
%% @doc this is for getting rules
%% description of rules  for descripton purposes has been changed to show category of rule in view
-spec get_rules() -> [tempmod_rules_temp()] | [] | term().
get_rules() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S#tempmod_rules_temp{
	            site_id=yapp_test_lib_usermod:get_site_name(Stid),
				template_id=yapp_test_lib_isoproc:get_template_desc(Tmpid),	
				category_rule=get_template_rule_cat(Catid),
				rule_status=format_status(Rlst)
	            } ||
	             S=#tempmod_rules_temp{site_id=Stid,template_id=Tmpid,category_rule=Catid,rule_status=Rlst} <- mnesia:table(tempmod_rules_temp)
	            ]))
	    end,
	    mnesia:activity(transaction, F).

	    
%% @doc this is used for getting a template based on being filtered with an index 
-spec get_rules_filter(binary())-> [tempmod_rules_temp()]	| [] | term().    
get_rules_filter(Filter)->

		F = fun() ->
			qlc:eval(qlc:q(
            [S#tempmod_rules_temp{
            site_id=yapp_test_lib_usermod:get_site_name(Stid),
			template_id=yapp_test_lib_isoproc:get_template_desc(Tmpid),	
			category_rule=get_template_rule_cat(Catid),
			rule_status=format_status(Rlst)
            } ||
             S=#tempmod_rules_temp{description=Desc,site_id=Stid,template_id=Tmpid,category_rule=Catid,rule_status=Rlst} <- mnesia:table(tempmod_rules_temp),
             binary:match(Desc,Filter) =/= nomatch 
            ]))
	    end,
	    mnesia:activity(transaction, F).
	    
		
format_status(enabled)-><<"Enabled">>;
format_status(disabled)-><<"Disabled">>;
format_status(S)->S.



%% @doc get rule by id
-spec get_rule_id(pos_integer()) -> term() | {error,temp_non_exists} .
get_rule_id(Id) ->
			F = fun()->
					mnesia:read(tempmod_rules_temp,Id)
			end,
		    case mnesia:activity(transaction,F) of 
				[S] ->
				    {ok,S};
				_ ->
				   {error,rule_non_exists}
		    end.


%% @doc get rule members
-spec get_rule_members(pos_integer()) -> term() | {error,temp_non_exists} .
get_rule_members(Id) ->
			F = fun()->
					mnesia:read(tempmod_rules_temp,Id)
			end,
		    case mnesia:activity(transaction,F) of 
				[S] ->
				    S#tempmod_rules_temp.rule_users;
				_ ->
				   {error,rule_non_exists}
		    end.


%% @doc for adding users to a rule 
-spec save_member_rules(pos_integer(),[pos_integer()])->ok|{error,term()}.
save_member_rules(Ruleid,Members)->
			F = fun()->
					mnesia:read(tempmod_rules_temp,Ruleid)
			end,
		    case mnesia:activity(transaction,F) of 
				[S] ->
				    Fun_add = fun()->
						mnesia:write(S#tempmod_rules_temp{rule_users=Members})
						end,
					mnesia:activity(transaction,Fun_add);	
				_ ->
				   {error,rule_non_exists}
		    end.



		
%% @doc get category desc for rule
-spec get_template_rule_cat(pos_integer()) -> binary() .
get_template_rule_cat(Id) ->
			F = fun()->
					mnesia:read(tempmod_rule_cat,Id)
			end,
		    case mnesia:activity(transaction,F) of 
				[#tempmod_rule_cat{description=Desc}] ->
				    Desc;
				_ ->
				   <<>>
		    end.		
		    
		    
%% @doc get category desc for rule
-spec get_rule_cats() -> [term()]| [] .
get_rule_cats() ->
			F = fun() ->
					qlc:eval(qlc:q(
		            [S ||
					S<- mnesia:table(tempmod_rule_cat)
		             ]))
			end,
	    mnesia:activity(transaction, F).		
		    		    
		    

%%% @doc for deleting rules 
-spec del_rule(pos_integer())->ok|term().
del_rule(Ruleid)->
		F = fun()->
				mnesia:delete({tempmod_rules_temp,Ruleid}) 
		end , 
		mnesia:activity(transaction,F).




		
%% @doc this is used for temp adding rules
-spec add_rule(Site::pos_integer(),Template::pos_integer(),Rule_options::[tuple()],Description::binary(),Category::pos_integer(),Status::binary())-> ok|{error,atom()}.
add_rule(Siteid,Template,Rule_options,Description,Category,Status)->
		
		F = fun()->
				case  mnesia:read({usermod_sites, Siteid}) =:= []  orelse 
					  mnesia:read({tempmod_temp, Template}) =:= [] orelse
					  mnesia:read({tempmod_rule_cat, Category}) =:= [] orelse 
					  check_rule_exists(Siteid,Template,add,0) =:= exists of
					  true ->
						{error,rule_already_exists_or_data_wrong};
					  false ->
						Fun_add = fun()->
						mnesia:write(#tempmod_rules_temp{site_id=Siteid,template_id=Template,rule_status=Status,
						rule_options=Rule_options,description=Description,category_rule=Category,
						id=yapp_test_lib_usermod:get_set_auto(tempmod_rules_temp)})
						end,
						mnesia:activity(transaction,Fun_add)
				end
		end,		
		mnesia:activity(transaction,F).
		
		
		
%% @doc this is used for editing rules
-spec edit_rule(Ruleid::pos_integer(),Site::pos_integer(),Template::pos_integer(),Rule_options::[tuple()],Description::binary(),Category::pos_integer(),Status::binary())-> ok|{error,atom()}.
edit_rule(Ruleid,Siteid,Template,Rule_options,Description,Category,Status)->
			
		F = fun()->
				Rcheck = fun()->
					mnesia:read(tempmod_rules_temp,Ruleid)
			    end,
				case mnesia:activity(transaction,Rcheck) of
					[S] ->
						case  mnesia:read({usermod_sites, Siteid}) =:= []  orelse 
							  mnesia:read({tempmod_temp, Template}) =:= [] orelse
							  mnesia:read({tempmod_rule_cat, Category}) =:= [] orelse
							  check_rule_exists(Siteid,Template,edit,Ruleid) =:= exists of
								true ->
									{error,rule_already_exists_or_data_wrong};
								false ->
									Fun_add = fun()->
									mnesia:write(S#tempmod_rules_temp{rule_status=Status,
									site_id=Siteid,template_id=Template,
									rule_options=Rule_options,
									description=Description,category_rule=Category})
									end,
									mnesia:activity(transaction,Fun_add)
						end;
					_ ->
						{error,rule_non_exists}
				end
						
		end,		
		mnesia:activity(transaction,F).
		
		
				
%% @doc this is used for setting up the rules for the template							
-spec setup_rule_fun(pos_integer(),[tuple()]|[])->Fun_processors::fun((...) -> fun())| term().						
setup_rule_fun(Temp_id,Rule_options)->
		F = fun()->
				mnesia:read(tempmod_temp,Temp_id)
			end,
			case mnesia:activity(transaction,F) of 
			[S = #tempmod_temp{temp_fun=Tfun}] ->
			  Tfun;
			     %%Tfun(Rule_options);
			_ ->
			   throw(error)
			end.
 
 
 
%% @doc check if template already exists .
%% this will prevent you from creating rules for ones already done for a site
-spec check_rule_exists(Site::pos_integer(),Tempid::pos_integer(),Type::add|edit,Id::pos_integer())->ok|exists.
check_rule_exists(Site,Tempid,Type,Cid) ->	
			F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S=#tempmod_rules_temp{site_id=Site_old,template_id=Temp_old,id=Oid} <- mnesia:table(tempmod_rules_temp),
	             Temp_old =:= Tempid andalso Site_old =:= Site andalso  Type =:= add
	             orelse Temp_old =:= Tempid andalso Site_old =:= Site andalso  Type =:= edit andalso Cid =/= Oid  
	             ]))
			end,
	    case mnesia:activity(transaction, F) of
	       [] ->  ok;
	        _  ->  exists
	    end.							
	
			
