%%% 
%%% @doc function for setting up and processing  transactions.
%%%<br></br>
%%%<br>for setting up templates as well as setting up basic rules system </br>
%%%<br>anonymous functions are used to pack the arguements which are needed to do comparison so that comparison will be faster</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_lib_isoproc).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").

-include_lib("stdlib/include/qlc.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include_lib("erlmon_lib/include/yapp_test_lib.hrl").

%%this part is for templates
-export([get_templates/0,
		 get_template_filter/1,
		 get_template_id/1,
		 get_templates_cats/0,
		 add_template/3,
		 edit_template/4,
		 get_template_desc/1,
		 delete_template/1
		]).


%%type definitions fore the above records
-type tempmod_temp() :: #tempmod_temp{}.



%% @doc this is used for adding a template  
-spec add_template(Template_ident::binary(),Description::binary(),Category::pos_integer())-> ok | {error,binary()}.
add_template(Template_ident,Description,CategoryId)->
	    F = fun()->
				case  check_template(Template_ident,add_temp,0) =:= exists orelse 
					  mnesia:read({tempmod_temp_cat, CategoryId}) =:= [] of
						true ->
							{error,check_template_category};
						false->
								Fun_add = fun() ->  
											mnesia:write(#tempmod_temp{ident=Template_ident,
											id=yapp_test_lib_usermod:get_set_auto(tempmod_temp),
											category_temp=CategoryId,description=Description
												   })
								end,
								mnesia:activity(transaction, Fun_add)
				end
		    end,
		mnesia:activity(transaction,F).



%% @doc this is used for editing a template
-spec edit_template(Id::pos_integer(),Template_ident::binary(),Description::binary(),Category::pos_integer())-> ok | {error,atom()} | {error|term()}.
edit_template(Tempid,Template_ident,Description,CategoryId)->
		
		F = fun()->
				Rcheck = fun()->
					mnesia:read(tempmod_temp,Tempid)
			    end,
				case mnesia:activity(transaction,Rcheck) of
					[S] ->
						case  check_template(Template_ident,edit_temp,Tempid) =:= exists orelse 
							  mnesia:read({tempmod_temp_cat, CategoryId}) =:= [] of
								true ->
									{error,check_template_category};
								false->
										Fun_add = fun() ->  
													mnesia:write(S#tempmod_temp{ident=Template_ident,
													category_temp=CategoryId,description=Description
														   })
										end,
										mnesia:activity(transaction, Fun_add)
						end;
					_ ->
						{error,temp_non_exists}
				end
		end,
		mnesia:activity(transaction,F).
	
	
%% @doc this is for deleting templates along with all rules for that template
%%to be used with utmost care as this removes all rules for a template along with the template from the system 	
-spec delete_template(pos_integer())->ok|term().
delete_template(Tid)->
		F = fun()->
				Rules_Ret =	mnesia:index_read(tempmod_rules_temp,Tid,#tempmod_rules_temp.template_id),
				case Rules_Ret of 
					[]->
						mnesia:delete({tempmod_temp,Tid});
					RuleList-> 
						mnesia:delete({tempmod_temp,Tid}),
						lists:map(fun(#tempmod_rules_temp{id=Id})-> yapp_test_lib_rules:del_rule(Id)  end,RuleList)
				end
		end,
		mnesia:activity(transaction,F).
	
		

%% @doc this is for getting templates
%% description of temp for descripton purposes has been changed to show category of temp in view
-spec get_templates() -> [tempmod_temp()] | [] | term().
get_templates() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S#tempmod_temp{category_temp=get_template_cat(Id_cat)} ||
	             S=#tempmod_temp{category_temp=Id_cat} <- mnesia:table(tempmod_temp)
	            ]))
	    end,
	    mnesia:activity(transaction, F).
	    
	    
%% @doc this is used for getting a template based on being filtered with an index 
-spec get_template_filter(binary())-> [tempmod_temp()]	| [] | term().    
get_template_filter(Filter)->
		F=fun()-> mnesia:index_read(tempmod_temp,Filter,#tempmod_temp.ident)end,
		case mnesia:activity(transaction,F) of 
			[S=#tempmod_temp{category_temp=Id_cat}]->
				[S#tempmod_temp{category_temp=get_template_cat(Id_cat)}];
			_->
				[]
		end.
			
		

%% @doc get template by id
-spec get_template_id(pos_integer()) -> tempmod_temp() | {error,temp_non_exists} .
get_template_id(Id) ->
			F = fun()->
					mnesia:read(tempmod_temp,Id)
			end,
		    case mnesia:activity(transaction,F) of 
				[S] ->
				    {ok,S};
				_ ->
				   {error,temp_non_exists}
		    end.

	
%% @doc get category by id
-spec get_template_cat(pos_integer()) -> binary() .
get_template_cat(Id) ->
			F = fun()->
					mnesia:read(tempmod_temp_cat,Id)
			end,
		    case mnesia:activity(transaction,F) of 
				[#tempmod_temp_cat{description=Desc}] ->
				    Desc;
				_ ->
				   <<>>
		    end.	
	
	
%% @doc get name by id
-spec get_template_desc(pos_integer()) -> binary() .
get_template_desc(Id) ->
			F = fun()->
					mnesia:read(tempmod_temp,Id)
			end,
		    case mnesia:activity(transaction,F) of 
				[#tempmod_temp{description=Desc}] ->
				    Desc;
				_ ->
				   <<>>
		    end.	
	
	
	
%% @doc this is for getting categories
%%
-spec get_templates_cats() -> [term()] | [] | term().
get_templates_cats() ->
		F = fun() ->
				qlc:eval(qlc:q(
	            [S ||
	             S <- mnesia:table(tempmod_temp_cat)
	            ]))
	    end,
	    mnesia:activity(transaction, F).

		
%% @doc this is for checking whether a the ident you are using for a template exists with another template 
-spec check_template(Template_ident::binary(),add_temp|edit_temp,pos_integer())-> ok | exists .
check_template(Template_ident,Type,Id)  ->
			F = fun() ->
				qlc:eval(qlc:q(
	            [{Ident} ||
	             #tempmod_temp{ident=Ident,id=Id_old} <- mnesia:table(tempmod_temp),
	             Template_ident =:= Ident andalso Type =:= add_temp
	             orelse Template_ident =:= Ident andalso Type =:=  edit_temp andalso Id =/= Id_old]))
			end,
	    case mnesia:activity(transaction, F) of
	        [] ->  ok;
	        _  ->  exists
	    end.
	
