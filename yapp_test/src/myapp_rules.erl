%%%
%%% @doc myapp_rules module.
%%%<br>contains module for working with the rule definitions </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_rules).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").


%%functions for processing pages
-export([
		 out/1
		 ]).
		 
		 
	 
-include_lib("yaws/include/yaws_api.hrl").
-include_lib("yapp_test/include/yapp_test.hrl").


%%% @doc check to see whether use is logged in 
out(Arg) ->
		out(Arg,yapp_test_lib_sess:check_login(Arg,?COOKIE_VARIABLE)).

		
%%% @doc for redirecting users not logged in back to login  page  
out(Arg,error)->
		{page,yapp:prepath(Arg)++?INDEX_PAGE};

%%% @doc user is logged but check has to be still done as to whether user has access to pages
%%  	 all users will have access to landing page as this is waived for all users
%%   @end
out(Arg,ok) ->
		%%io:format("cookie availables.does page exist??~p~n",[yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)]),
		out(Arg,ok,yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)).


%% @doc logged in users whom dont have access to page are shown the page for restricted users (exists/no access)
out(Arg,ok,error) ->
		%%io:format("user logged in and but does not have permission to acces page"),
		{page,yapp:prepath(Arg)++?PG_401};
	
	
%%% @doc logged in users whom hav access to this page come here (exists/access)
out(Arg,ok,ok) ->
		Uri = yaws_api:request_url(Arg),
		Path = string:tokens(Uri#url.path, "/"), 
		Method = (Arg#arg.req)#http_request.method,
		outa(Arg,Method,Path).
		
		
%% @doc	this is for the getting institutions
outa(Arg,'GET',["yapp_test","rules","get_rules"])->
		Title_Page = "Rules",
		Rules = yapp_test_lib_rules:get_rules(),
		{ok,UiData} = yapp_test_rules_list:render([{title,Title_Page},{yapp_prepath,yapp:prepath(Arg)},{data,Rules}]),
		{html,UiData};			
	
		
%% @doc this is for getting the sites but using a filter
outa(Arg,'GET',["yapp_test","rules","search_rules"])->
		
		case  yaws_api:queryvar(Arg,"filter") of
		   {ok,Filter} ->
				Rules = yapp_test_lib_rules:get_rules_filter(list_to_binary(Filter)),
				{ok,UiData} = yapp_test_rules_search:render([{yapp_prepath,yapp:prepath(Arg)},{data,Rules}]),
				{html,UiData}; 
			undefined ->
				Rules = yapp_test_lib_rules:get_rules(),
				{ok,UiData} = yapp_test_rules_search:render([{yapp_prepath,yapp:prepath(Arg)},{data,Rules}]),
				{html,UiData}
		end;		
		

		
%% @doc this is used for adding a new rule
%%		returns an erlydtl html page afer filter and query		
outa(_Arg,'GET',["yapp_test","rules","get_add_rule"])->
		Sites = yapp_test_lib_usermod:get_sites(),
		Temps = yapp_test_lib_isoproc:get_templates(),
		Categories = yapp_test_lib_rules:get_rule_cats(),
		{ok,UiData} = yapp_test_add_rule:render([{sites,Sites},{templates,Temps},{cats,Categories},{type_user_tran,"add_rules"}]),
		{html,UiData};			
		
		
		
	%% @doc this is used for adding a new rule 
outa(_Arg,'GET',["yapp_test","rules","get_edit_rule",RuleId])->

		case yapp_test_lib_rules:get_rule_id(list_to_integer(RuleId)) of 
			{ok,S} -> 
				Sites = yapp_test_lib_usermod:get_sites(),
				Temps = yapp_test_lib_isoproc:get_templates(),
				Categories = yapp_test_lib_rules:get_rule_cats(),
				{ok,UiData} = yapp_test_add_rule:render([{data,S},{sites,Sites},{templates,Temps},{cats,Categories},{type_user_tran,"edit_rules"}]),
				{html,UiData};
			_ ->
				yapp_test_lib_util:message_client(500,"Rule Does Not Exist")
		end;

%% @doc this is used for adding a new template 
%%		returns an erlydtl html page afer filter and query		
outa(Arg,'POST',["yapp_test","rules","save_add_rule"])->
		io:format("~ntesting addition of rule~p",[yaws_api:parse_post(Arg)]),
		case  
		      yaws_api:postvar(Arg,"siteid") =:= undefined orelse
		      yaws_api:postvar(Arg,"templateid") =:= undefined orelse
		      yaws_api:postvar(Arg,"description") =:= undefined orelse
		      yaws_api:postvar(Arg,"siteid") =:= {ok,""} orelse
		      yaws_api:postvar(Arg,"category") =:= {ok,""} orelse
		      yaws_api:postvar(Arg,"templateid") =:= {ok,""} of
				true ->
					yapp_test_lib_util:message_client(500,"Required Field is Empty");
				_ ->
					case  yaws_api:postvar(Arg,"id") of
					   {ok,Edit_id_val} ->
							{ok,Siteid}=yaws_api:postvar(Arg, "siteid"),
							{ok,Templateid}=yaws_api:postvar(Arg, "templateid"),
							{ok,Description}=yaws_api:postvar(Arg, "description"),
							{ok,Cat}=yaws_api:postvar(Arg, "category"),
							{ok,Status}=yaws_api:postvar(Arg, "status"),
							case yapp_test_lib_rules:edit_rule(list_to_integer(Edit_id_val),list_to_integer(Siteid),list_to_integer(Templateid),[],
															 list_to_binary(Description),list_to_integer(Cat),list_to_binary(Status)) of
								ok ->
									yapp_test_lib_util:message_client(200,"Rule Edited Successfully");
								{error,Reason} ->
									yapp_test_lib_util:message_client(500,atom_to_list(Reason))
							end;
						_ ->
							{ok,Siteid}=yaws_api:postvar(Arg, "siteid"),
							{ok,Templateid}=yaws_api:postvar(Arg, "templateid"),
							{ok,Description}=yaws_api:postvar(Arg, "description"),
							{ok,Cat}=yaws_api:postvar(Arg, "category"),
							{ok,Status}=yaws_api:postvar(Arg, "status"),
							case yapp_test_lib_rules:add_rule(list_to_integer(Siteid),list_to_integer(Templateid),[],
															 list_to_binary(Description),list_to_integer(Cat),list_to_binary(Status)) of
								ok ->
									yapp_test_lib_util:message_client(200,"Rule Added Successfully");
								{error,Reason} ->
									yapp_test_lib_util:message_client(500,atom_to_list(Reason))
							end
					end
		end;      
		
%% @doc for getting people whom should have access to a rule  		
outa(_Arg,'GET',["yapp_test","rules","get_rule_members",Ruleid])->
		Ruleint=list_to_integer(Ruleid),
		case yapp_test_lib_rules:get_rule_id(Ruleint) of 
			{ok,_Members} ->
				RuleMembers=yapp_test_lib_rules:get_rule_members(Ruleint),
				Users = yapp_test_lib_usermod:get_users_for_rules(),
				{ok,UiData} = yapp_test_edit_rule_users:render([{ruleid,Ruleint},{members,RuleMembers},{users,Users}]),
				{html,UiData};
			_ ->
				yapp_test_lib_util:message_client(500,"Rule Does Not Exist")
		end;

outa(Arg,'POST',["yapp_test","rules","save_rule_members"])->

		%%io:format("Rules including members/non members are ~n~p",[yaws_api:parse_post(Arg)]),
		Data = lists:map(fun({Postkey,Postval})-> {Postkey,lists:map(fun(Pv)->list_to_integer(Pv)end,string:tokens(Postval,","))}  end ,yaws_api:parse_post(Arg)),
		[Id] = proplists:get_value("id",Data),
		Rules_save = proplists:get_value("rules",Data),
		case yapp_test_lib_rules:save_member_rules(Id,Rules_save) of 
			ok ->
				yapp_test_lib_util:message_client(200,"Members Added Successfully");
			{errror,Reason} ->
				yapp_test_lib_util:message_client(500,atom_to_list(Reason))
		end;


%% @doc this is used for deleting rules 
outa(_Arg,'DELETE',["yapp_test","rules","delete_rule",Ruleid])->

		%%io:format("Rule for deletion is  ~n~p",[list_to_integer(Ruleid)]),
		yapp_test_lib_rules:del_rule(list_to_integer(Ruleid)),
		yapp_test_lib_util:message_client(200,"Rule Deletion Successful");

						
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg,_Method,_)->
		{page,yapp:prepath(Arg)++?PG_404}.		
		
		
				
		
