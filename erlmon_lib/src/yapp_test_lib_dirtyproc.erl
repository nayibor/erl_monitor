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
		 process_message/1,
		 get_email_address/1	 
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
			{error,Reason}->
				Reason
		end.

	
%% @doc this is supposed to retrieve the site given a iso message
-spec get_site_message(map())->binary() | undefined.
get_site_message(Message)->
		case maps:get(32,Message,<<"fuck">>) of
			<<"fuck">> ->
				undefined;
			 Site ->
				Site
		end. 
		
		
%% @doc get user email for sending mails 
-spec get_email_address(pos_integer()) -> string()|binary().
get_email_address(Id)->
	case mnesia:dirty_read(usermod_users,Id) of 
			[#usermod_users{user_email=Email}]->
				Email;
			_->
				<<>>
	end.	
		
			
%%% @doc get sites by id 
-spec get_site_ident(Siteid::binary()) -> tuple().	
get_site_ident(Siteid) ->
		case mnesia:dirty_read(usermod_sites,Siteid) of 
			[#usermod_sites{site_short_name=Short_name}]->
				Short_name;
			_->
				<<>>
		end.
		

%% @doc for getting rules which have a particular index
-spec get_rules(pos_integer())-> {ok,[term()]}|{error,binary()}.
get_rules(_Message) ->
			%%find site from here if possible
			%%add generic rules which is used for sending messes to people if site does not have its own rules
			%%this ensures that rules for generic stuff for which emails  have to be sent will be returned even if there are no site rules
						Rules_Site = mnesia:dirty_index_read(tempmod_rules_temp,1,#tempmod_rules_temp.category_rule),	
						Generic_Rules = mnesia:dirty_index_read(tempmod_rules_temp,2,#tempmod_rules_temp.category_rule),
						List_Rules = lists:flatten(Rules_Site,Generic_Rules),
						case erlang:length(List_Rules) of
							Avail when Avail > 0 ->
								{ok,List_Rules};
							_ ->
								{error,<<"No Rule">>}
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
		List_socket_mail= maps:put(socket_list,[],Mail_list),
		lists:foldl(
			fun(#tempmod_rules_temp{template_id=Tid,site_id=Site_id,rule_options=Rule_opt,rule_status=Rstat,rule_users=Rus,category_rule=Ctr},Acc_Map)when Rstat =:= <<"enabled">> andalso (Ctr =:=1  orelse Ctr =:= 2)-> 
				Mail_or_socket = 
					case Ctr of 
					  1 ->socket_list;
					  2 ->mail_list
					end,	
					case process_rule_inst(get_template_ident(Tid),Site_id,Rule_opt,Message) of 
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
			end, List_socket_mail, Rules).


%%this rule is for sending a mesage back to members of a site/group etc..
%%generic rules 
-spec process_rule_inst(Template_type::binary(),Siteid::pos_integer(),Options_creator::[tuple()],Isomessage::binary())->true|false.
process_rule_inst(<<"site_temp">>,Siteid,_Options_creator,Isomessage)->
		case get_site_ident(Siteid)  of
			 <<"gen_site">>->
				true;
			Site_Ident->
				maps:get(32,Isomessage,<<"_fuck_">>) =:= Site_Ident
		end;
		
		
%%this is for generic rules 
%%this rule is for declines
process_rule_inst(<<"decl">>,Siteid,_Options_creator,Isomessage)->
		Decline_code = maps:get(39,Isomessage,<<"_fuck_">>),
		case get_site_ident(Siteid)  of
			<<"gen_site">> ->
				binary:match(Decline_code,<<"9">>)	=/= nomatch;
			Site_Ident ->
				maps:get(32,Isomessage,<<"_fuck_">>) =:= Site_Ident andalso binary:match(Decline_code,<<"9">>)	=/= nomatch 
		end;

%%this is actually used for processing the template
%%user data as well data from the message are extracted and compared 
process_rule_inst(_,_,_,_)->
		false.		
		
		

