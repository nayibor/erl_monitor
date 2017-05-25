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
		case get_rules(Message) of
			{ok,Rules}->
				process_rules(Rules,Message);
				%%RuleAns = lists:append(process_rules(Rules,Message));
				%%RuleAnsPlusAdmin = lists:append(RuleAns,get_admin_vew());
				%%lists:foldl(fun(Item,Acc)->
				%%				case lists:member(Item,Acc) of
				%%					true ->
				%%						Acc;
				%%					false ->
				%%						[Item|Acc]
				%%				 end
				%%			end,
				 %%[],RuleAnsPlusAdmin);
			{error,Reason}->
				Reason
		end.

	
%% @doc for getting the admins/superadmins in system
%%		these group of guys in system get to see all transaction rolling through system
%%      doesnt matter which site they belong to .they see everything in system
-spec get_admin_vew()->[pos_integer()].
get_admin_vew()->
		View_trans_all_users = mnesia:dirty_index_read(usermod_users_roles,7,#usermod_users_roles.role_id) ,
		lists:foldl(fun(#usermod_users_roles{user_id=UserId},Acc)->[UserId|Acc]  end ,[],View_trans_all_users).	
	
	
%% @doc this is supposed to retrieve the site given a iso message
-spec get_site_message(map())->binary() | undefined.
get_site_message(Message)->
		case maps:get(32,Message,<<"fuck">>) of
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
-spec get_rules(pos_integer())-> {ok,[term()]}|{error,binary()}.
get_rules(Message) ->
			%%find site from here if possible
			%%add generic rules which is used for sending messes to people if site does not have its own rules
			%%this ensures that rules for generic stuff for which emails  have to be sent will be returned even if there are no site rules
		case get_site_message(Message) of 
			undefined->
				get_generic_rules();
			Siteid ->
				case validate_site_index(Siteid) of 
					{ok,Id}->
						Rules_Site = mnesia:dirty_index_read(tempmod_rules_temp,Id,#tempmod_rules_temp.site_id),	
						Generic_Rules = mnesia:dirty_index_read(tempmod_rules_temp,2,#tempmod_rules_temp.category_rule),
						List_Rules = lists:flatten(Rules_Site,Generic_Rules),
						case erlang:length(List_Rules) of
							Avail when Avail > 0 ->
								{ok,List_Rules};
							_ ->
								{error,<<"No Rule">>}
						end;
					 _ ->
						get_generic_rules()
				end
			end.


%%this is for returning generic rule list
-spec get_generic_rules()->{ok,list()}|{error,binary()}.
get_generic_rules() ->
		List_Rules = mnesia:dirty_index_read(tempmod_rules_temp,2,#tempmod_rules_temp.category_rule),
						case erlang:length(List_Rules) of
							Avail when Avail > 0 ->
								{ok,List_Rules};
							_ ->
								{error,<<"No Site">>}
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
-spec process_rules([tuple()],binary())->[]|[pos_integer()].
process_rules(Rules,Message)->
		Map_users = maps:new(),
		Mail_list = maps:put(mail_list,[],Map_users),
		List_socket_Mail= maps:put(socket_list,[],Mail_list),
		lists:foldl(
			fun(#tempmod_rules_temp{template_id=Tid,rule_options=Rule_opt,rule_status=Rstat,rule_users=Rus,category_rule=Ctr},Acc_Map)when Rstat =:= <<"enabled">> andalso (Ctr =:=1  orelse Ctr =:= 2)-> 
				Mail_or_socket = 
					case Ctr of 
					  1 ->socket_list;
					  2 ->mail_list
					end,	
					case process_rule_inst(get_template_ident(Tid),Rule_opt,Message) of 
							true ->
								Socket_New_list = lists:foldl(fun(SinU,Acc_Map_ls)->
																case lists:member(SinU,Acc_Map) of 
																  true -> 
																	Acc_Map;
																  false ->
																	[SinU|Acc_Map_ls]
																end
															  end,Rus,maps:get(Mail_or_socket,Acc_Map)),
								maps:update(Mail_or_socket,Socket_New_list,Acc_Map);
							false ->
								Acc_Map
					end;
			(#tempmod_rules_temp{rule_status=Rstat},Acc_Map)when Rstat =:= <<"disabled">> -> 
					Acc_Map
			end, List_socket_Mail, Rules).                          


%%this rule is for sending a mesage back to members of a site/group etc..
-spec process_rule_inst(Template_type::binary(),Options_creator::[tuple()],Isomessage::binary())->true|false.
process_rule_inst(<<"site_temp">>,_Options_creator,_Isomessage)->
		true;
		
		
%%this is for generic rules 
%%rules for which  mails will be sent 
%%this rule will be applied for everybody regardless of site 
%%can be used for rules which have to be sent regardless of site 
process_rule_inst(<<"genx">>,_Options_creator,_Isomessage)->
		true;			 

%%this is actually used for processing the template
%%user data as well data from the message are extracted and compared 
process_rule_inst(_,_Options_creator,_Isomessage)->
		false.		
		
