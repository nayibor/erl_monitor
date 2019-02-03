

-module(util).

%%functions for processing pages
-export([change_node_name/5,install/1]).

%%% usermod_users for user information
-record(usermod_users,{id::pos_integer(),user_email::string(),password::string(),fname::string(),lname::string(),site_id::pos_integer(),inst_id::pos_integer(),lock_status=0::0|1|2|3|4,reset_time_max,reset_status=false::true|false}). 

%%% usermod_roles for role information
%%% usermod_roles for role information
-record(usermod_roles,{id::pos_integer(),role_short_name,role_long_name}).

%%%  usermod_links for link information
-record(usermod_links,{id,link_controller,link_action,link_allow,link_category,link_name,link_type}). 

%%%  usermod_users_roles for roles for users .type bag
-record(usermod_users_roles,{user_id,role_id}).

%%%  usermod_users_links for links for roles .%%type bag
-record(usermod_role_links,{role_id,link_id}). 

%%%  test_new_rec
-record(test_rec,{name,fname,lname}).

%%  auto_inc_table
-record(auto_inc,{name,cvalue}).


%%% record for storing the site information
%%	for the mean time the short name will be used for the identtt.should be unique 
%%  the whole table will be transformed later 
-record(usermod_sites,{id,site_short_name,site_long_name,inst_id}).


%%%record for storing the institution information
-record(usermod_inst,{id,inst_short_name,inst_long_name,inst_ident}).

%%%record for categories
-record(usermod_categories,{id,category}).


%%record definition for templates
-record(tempmod_temp,{id,ident,temp_fun,description,category_temp}).


%%record definition for rules
-record(tempmod_rules_temp,{id,site_id,template_id,rule_fun,rule_options,description,category_rule,rule_status=disabled,rule_users=[]}).


%%record definition for template categories
-record(tempmod_temp_cat,{id,description}).


%%record definitions for rule categories
-record(tempmod_rule_cat,{id,description}).


%%%usermod_rules_users for rules for users .type bag
-record(usermod_rules_users,{ruleid,userid}).


-record(test_transform,{id,name}).
-record(test_transform_new,{id,lname,name,extra}).




change_node_name(Mod, From, To, Source, Target) ->
    Switch =
        fun(Node) when Node == From -> To;
           (Node) when Node == To -> throw({error, already_exists});
           (Node) -> Node
        end,
    Convert =
        fun({schema, db_nodes, Nodes}, Acc) ->
                {[{schema, db_nodes, lists:map(Switch,Nodes)}], Acc};
           ({schema, version, Version}, Acc) ->
                {[{schema, version, Version}], Acc};
           ({schema, cookie, Cookie}, Acc) ->
                {[{schema, cookie, Cookie}], Acc};
           ({schema, Tab, CreateList}, Acc) ->
                Keys = [ram_copies, disc_copies, disc_only_copies],
                OptSwitch =
                    fun({Key, Val}) ->
                            case lists:member(Key, Keys) of
                                true -> {Key, lists:map(Switch, Val)};
                                false-> {Key, Val}
                            end
                    end,
                {[{schema, Tab, lists:map(OptSwitch, CreateList)}], Acc};
           (Other, Acc) ->
                {[Other], Acc}
        end,
    mnesia:traverse_backup(Source, Mod, Target, Mod, Convert, switched).



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
		mnesia:create_table(auto_inc,
							[{attributes, record_info(fields, auto_inc)},
							 {index, [#auto_inc.cvalue]},
							 {disc_copies, Nodes}]),
		mnesia:create_table(usermod_sites,
							[{attributes, record_info(fields, usermod_sites)},
							 {index, [#usermod_sites.site_short_name]},
							 {disc_copies, Nodes}]),
		mnesia:create_table(usermod_inst,
							[{attributes, record_info(fields, usermod_inst)},
							 {index, [#usermod_inst.inst_short_name]},
							 {disc_copies, Nodes}]),	
		mnesia:create_table(usermod_categories,
							[{attributes, record_info(fields, usermod_categories)},
							 {index, [#usermod_categories.category]},
							 {disc_copies, Nodes}]),
		mnesia:create_table(tempmod_temp,
							[{attributes, record_info(fields, tempmod_temp)},
							 {disc_copies, Nodes}]),
		mnesia:create_table(tempmod_rules_temp,
							[{attributes, record_info(fields, tempmod_rules_temp)},
							 {disc_copies, Nodes}]),
		mnesia:create_table(tempmod_temp_cat,
							[{attributes, record_info(fields, tempmod_temp_cat)},
							 {disc_copies, Nodes}]),
	mnesia:create_table(tempmod_rule_cat,
							[{attributes, record_info(fields, tempmod_rule_cat)},
							 {disc_copies, Nodes}]),
		mnesia:create_table(usermod_rules_users,
						[{attributes, record_info(fields, usermod_rules_users)},
							 {index, [#usermod_rules_users.userid]},
							 {disc_copies, Nodes}, {type, bag}]).

