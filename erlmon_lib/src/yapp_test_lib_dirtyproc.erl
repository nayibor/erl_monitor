%%%
%%% @doc yapp_test_lib_dirtyproc module.
%%%<br>this module is responsible for mostly identifying and pulling out rules/users whom have access to rule given an iso message</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(yapp_test_lib_dirtyproc).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").
-include_lib("stdlib/include/qlc.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include_lib("erlmon_lib/include/yapp_test_lib.hrl").



%%this part is for templates
-export([
		 process_message/1	 
		]).



%% @doc for testing and bringing out statistics		
test_message(Message)->
		statistics(wall_clock),
		process_message(Message),
		{_,Timeduration}=statistics(wall_clock),
		io:format(" Time_duration~p~n",[Timeduration/1000]).
		
			
%% @doc this is used for processing messages coming in
%% message processing will either be successful or will generate an error tuple depending on error reason
-spec process_message(map())-> [pos_integer()] | {error,binary()}.
process_message(Message) ->
		 case get_site_message(Message) of
				undefined ->
					{error,<<"Index Not Found">>};
				Site ->
					case validate_site_index(Site)  of
						{ok,Id} ->
							case get_rules_index(Id) of
								{ok,Rules}->
									RuleAns = lists:append(process_rules(Rules,Site,Message)),
									lists:foldl(fun(Item,Acc)->
													case lists:member(Item,Acc) of
														true ->
															Acc;
														false ->
															[Item|Acc]	
													 end
												end,
									 [],RuleAns);
								{error,Reason}->
									Reason
							end;	
						{error,Reason} ->
							{error,Reason}
					end
		 end.
	
	
%% @doc this is supposed to retrieve the site given a iso message
-spec get_site_message(map())->binary() | undefined.
get_site_message(Message)->
		case maps:get(<<"_32">>,Message,<<"fuck">>) of
			<<"fuck">> ->
				undefined;
			 Site ->
				Site
		end. 
		
			
%%% @doc get sites by index 
-spec validate_site_index(Filter::binary()) -> tuple().	
validate_site_index(Filter) ->
			case mnesia:dirty_index_read(usermod_sites,Filter,#usermod_sites.site_short_name) of 
				[#usermod_sites{id=Id}]->
					{ok,Id};
				_->
					{error,<<"No Site">>}
			end.
			
			
%% @doc for getting rules which have a particular index
-spec get_rules_index(pos_integer())-> {ok,[term()]}|{error,binary()}.
get_rules_index(Siteid) ->
			case mnesia:dirty_index_read(tempmod_rules_temp,Siteid,#tempmod_rules_temp.site_id) of 
				[]->
					{error,<<"No Rule">>};
				S-> 
					{ok,S}
			end.


%% @doc for getting the template iden for a specific ident
-spec get_template_ident(pos_integer())->binary().
get_template_ident(Id)->
		    case mnesia:dirty_read(tempmod_temp,Id) of 
				[#tempmod_temp{ident=Ident}] ->
				    Ident;
				_ ->
				   <<>>
		    end.

%% @doc for processing the actual rules .this will process the rules for a site and bring out a list if users
%% whom are eligible to view that rule 
-spec process_rules([tuple()],binary(),binary())->[]|[pos_integer()].
process_rules(Rules,Siteident,Message)->
		lists:filtermap(
				fun(#tempmod_rules_temp{template_id=Tid,rule_options=Rule_opt,rule_status=Rstat,rule_users=Rus})when Rstat =:= <<"enabled">> -> 
					case process_rule_inst(get_template_ident(Tid),Siteident,Rule_opt,Message) of 
						true	->
							{true,Rus};
						false ->
							false
					end;
					(#tempmod_rules_temp{rule_status=Rstat})when Rstat =:= <<"disabled">> -> 
						false
				end,Rules).



%%this is actually used for processing the template
%%user data as well data from the message are extracted and compared 
-spec process_rule_inst(Template_type::binary(),Site_Rule::binary(),Options_creator::[tuple()],Isomessage::binary())->true|false.
process_rule_inst(<<"site_temp">>,Site_rule,_Options_creator,Isomessage)->
		true;
		
%%this is actually used for processing the template
%%user data as well data from the message are extracted and compared 
process_rule_inst(<<"nt">>,Site_rule,_Options_creator,Isomessage)->
		Inst_iso = proplists:get_value(<<"site">>,Isomessage),
		case  Inst_iso =:= Site_rule of 
			true ->
				true;
			false ->
				false
		end;		
					 

%%this is actually used for processing the template
%%user data as well data from the message are extracted and compared 
process_rule_inst(_,_Site_rule,_Options_creator,_Isomessage)->
		false.		
		
