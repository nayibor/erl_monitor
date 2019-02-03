%%%
%%% @doc myapp_inst module.
%%%<br>utility module for data type conversion so it works with erlydtl templates</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_util).
-export([convert_data/1]).

-include_lib("erlmon_lib/include/yapp_test_lib.hrl").

convert_data(Record_terms)->
	lists:foldl(
		fun(X,Accum)->
		 Dict_record =  process_record(X),
		 [Dict_record|Accum]
		end,[],Record_terms).
	

process_record(X) when is_record(X,usermod_inst)=:=true ->
	List_inst = [{id,X#usermod_inst.id},{inst_short_name,X#usermod_inst.inst_short_name},{inst_long_name,X#usermod_inst.inst_long_name},{inst_ident,X#usermod_inst.inst_ident}],
	lists:foldl(
	fun({Key,Value},Acc)->
		 dict:store(Key,Value,Acc)
	end,dict:new(),List_inst);


process_record(X) when is_record(X,usermod_sites)=:=true ->
	List_site = [{id,X#usermod_sites.id},{site_short_name,X#usermod_sites.site_short_name},
				 {site_long_name,X#usermod_sites.site_long_name},{inst_id,X#usermod_sites.inst_id}],
	lists:foldl(
	fun({Key,Value},Acc)->
		 dict:store(Key,Value,Acc)
	end,dict:new(),List_site);


process_record(X) when is_record(X,usermod_roles)=:=true ->
	List_roles = [{id,X#usermod_roles.id},{role_short_name,X#usermod_roles.role_short_name},{role_long_name,X#usermod_roles.role_long_name}],
	lists:foldl(
	fun({Key,Value},Acc)->
		dict:store(Key,Value,Acc)
	end,dict:new(),List_roles);


process_record(X) when is_record(X,usermod_links)=:=true ->
	List_links = [{id,X#usermod_links.id},{link_controller,X#usermod_links.link_controller},
				    {link_action,X#usermod_links.link_action},{link_allow,X#usermod_links.link_allow},
				    {link_category,X#usermod_links.link_category},{link_name,X#usermod_links.link_name},{link_type,X#usermod_links.link_type}
				    ],
	lists:foldl(
	fun({Key,Value},Acc)->
		dict:store(Key,Value,Acc)
	end,dict:new(),List_links);


process_record(X) when is_record(X,usermod_categories)=:=true ->
	List_cat = [{id,X#usermod_categories.id},{category,X#usermod_categories.category}],
	lists:foldl(
	fun({Key,Value},Acc)->
		dict:store(Key,Value,Acc)
	end,dict:new(),List_cat);


process_record(X) when is_record(X,tempmod_rules_temp)=:=true ->
	List_rules = [{id,X#tempmod_rules_temp.id},{site_id,X#tempmod_rules_temp.site_id},{template_id,X#tempmod_rules_temp.template_id},{rule_fun,X#tempmod_rules_temp.rule_fun},
				  {rule_options,X#tempmod_rules_temp.rule_options},{description,X#tempmod_rules_temp.description},{category_rule,X#tempmod_rules_temp.category_rule},
				  {rule_status,X#tempmod_rules_temp.rule_status},{rule_users,X#tempmod_rules_temp.rule_users}
				 ],
	lists:foldl(
	fun({Key,Value},Acc)->
		dict:store(Key,Value,Acc)
	end,dict:new(),List_rules);


process_record(X) when is_record(X,tempmod_temp)=:=true ->
	List_temp = [{id,X#tempmod_temp.id},{ident,X#tempmod_temp.ident},{temp_fun,X#tempmod_temp.temp_fun},{description,X#tempmod_temp.description},
				  {category_temp,X#tempmod_temp.category_temp}],
	lists:foldl(
	fun({Key,Value},Acc)->
		dict:store(Key,Value,Acc)
	end,dict:new(),List_temp);


process_record(X) when is_record(X,tempmod_rule_cat)=:=true ->
	List_rule_cat = [{id,X#tempmod_rule_cat.id},{description,X#tempmod_rule_cat.description}],
	lists:foldl(
	fun({Key,Value},Acc)->
		dict:store(Key,Value,Acc)
	end,dict:new(),List_rule_cat);


process_record(X) when is_record(X,tempmod_temp_cat)=:=true ->
	List_temp_cat = [{id,X#tempmod_temp_cat.id},{description,X#tempmod_temp_cat.description}],
	lists:foldl(
	fun({Key,Value},Acc)->
		dict:store(Key,Value,Acc)
	end,dict:new(),List_temp_cat).
