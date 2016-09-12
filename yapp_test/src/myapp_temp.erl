%%%
%%% @doc myapp_temp module.
%%%<br>contains code for working with system templates</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_temp).
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
outa(Arg,'GET',["yapp_test","temp","get_temp"])->
		Title_Page = "Templates",
		Temps = yapp_test_lib_isoproc:get_templates(),
		{ok,UiData} = yapp_test_temp_list:render([{title,Title_Page},{yapp_prepath,yapp:prepath(Arg)},{data,Temps}]),
		{html,UiData};	

%% @doc this is for getting the sites but using a filter
outa(Arg,'GET',["yapp_test","temp","search_temp"])->
		
		case  yaws_api:queryvar(Arg,"filter") of
		   {ok,Filter} ->
				Temp = yapp_test_lib_isoproc:get_template_filter(list_to_binary(Filter)),
			    {ok,UiData} = yapp_test_temp_search:render([{yapp_prepath,yapp:prepath(Arg)},{data,Temp}]),
				{html,UiData}; 
			undefined ->
				Temps = yapp_test_lib_isoproc:get_templates(),
				{ok,UiData} = yapp_test_temp_search:render([{yapp_prepath,yapp:prepath(Arg)},{data,Temps}]),
				{html,UiData}
		end;
		
		
%% @doc this is used for adding a new template 
%%		returns an erlydtl html page afer filter and query		
outa(_Arg,'GET',["yapp_test","temp","get_add_temp"])->

		Cats = yapp_test_lib_isoproc:get_templates_cats(),
		{ok,UiData} = yapp_test_add_temp:render([{cats,Cats},{type_user_tran,"add_temp"}]),
		{html,UiData};			
		
	
%% @doc this is used for adding a new template 
%%		returns an erlydtl html page afer filter and query		
outa(Arg,'POST',["yapp_test","temp","save_add_temp"])->

		case  
		      yaws_api:postvar(Arg,"ident") =:= undefined orelse
		      yaws_api:postvar(Arg,"description") =:= undefined orelse
		      yaws_api:postvar(Arg,"category") =:= undefined orelse
		      yaws_api:postvar(Arg,"ident") =:= {ok,""} orelse
		      yaws_api:postvar(Arg,"category") =:= {ok,""} of
				true ->
					yapp_test_lib_util:message_client(500,"Required Field is Empty");
				_  ->	
					case  yaws_api:postvar(Arg,"id") of
					   {ok,Edit_id_val} ->
							yapp_test_lib_util:message_client(500,"Not yet implemented.Stub");
					   _ ->
							{ok,Ident}=yaws_api:postvar(Arg, "ident"),
							{ok,Description}=yaws_api:postvar(Arg, "description"),
							{ok,Cat}=yaws_api:postvar(Arg, "category"),
							case yapp_test_lib_isoproc:add_template(list_to_binary(Ident),list_to_binary(Description),list_to_integer(Cat)) of
								ok ->
									yapp_test_lib_util:message_client(200,"Template Added Successfully");
								{error,Reason} ->
									yapp_test_lib_util:message_client(500,atom_to_list(Reason))
							end
					end
		end;
				
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg,_Method,_)->
		{page,yapp:prepath(Arg)++?PG_404}.		
		
		
		
		
		
		

		
