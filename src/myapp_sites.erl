%%%
%%% @doc myapp_inst module.
%%%<br>contains module for working with sites/banks</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_sites).

-author("Nuku Ameyibor <nayibor@startmail.com>").

-github("https://bitbucket.com/nameyibor").

-license("Apache License 2.0").

%%functions for processing pages
-export([out/1]).

-include_lib("yaws/include/yaws_api.hrl").
-include_lib("erl_mon/include/yapp_test.hrl").


%%% @doc check to see whether use is logged in
out(Arg) ->
    out(Arg,
	yapp_test_lib_sess:check_login(Arg, ?COOKIE_VARIABLE)).

%%% @doc for redirecting users not logged in back to login  page
out(Arg, error) ->
    {page, yapp:prepath(Arg) ++ (?INDEX_PAGE)};
%%% @doc user is logged but check has to be still done as to whether user has access to pages
%%  	 all users will have access to landing page as this is waived for all users
%%   @end
out(Arg, ok) ->
    %%io:format("cookie availables.does page exist??~p~n",[yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)]),
    out(Arg, ok,
	yapp_test_lib_sess:check_perm_page(Arg,
					   ?COOKIE_VARIABLE)).

%% @doc logged in users whom dont have access to page are shown the page for restricted users (exists/no access)
out(Arg, ok, error) ->
    %%io:format("user logged in and but does not have permission to acces page"),
    {page, yapp:prepath(Arg) ++ (?PG_401)};
%%% @doc logged in users whom hav access to this page come here (exists/access)
out(Arg, ok, ok) ->
    Uri = yaws_api:request_url(Arg),
    Path = string:tokens(Uri#url.path, "/"),
    Method = (Arg#arg.req)#http_request.method,
    outa(Arg, Method, Path).

%% @doc	this is for the getting sites
outa(Arg, 'GET', [_, "sites", "get_sites"]) ->
    Title_Page = "Sites",
    Sites = yapp_test_lib_usermod:get_sites(),
    {ok, UiData} = yapp_test_sites_list:render([{title,
						 Title_Page},
						{yapp_prepath,
						 yapp:prepath(Arg)},
						{data, Sites}]),
    {html, UiData};
%% @doc this is for getting the sites but using a filter
outa(Arg, 'GET', [_, "sites", "search_sites"]) ->
    %%io:format("query string is ~n~p ",[Search_query]),
    case yaws_api:queryvar(Arg, "filter") of
      {ok, Filter} ->
	  Sites =
	      yapp_test_lib_usermod:get_filter_site(list_to_binary(Filter)),
	  {ok, UiData} =
	      yapp_test_sites_search:render([{yapp_prepath,
					      yapp:prepath(Arg)},
					     {data, Sites}]),
	  {html, UiData};
      undefined ->
	  Sites = yapp_test_lib_usermod:get_sites(),
	  {ok, UiData} =
	      yapp_test_sites_search:render([{yapp_prepath,
					      yapp:prepath(Arg)},
					     {data, Sites}]),
	  {html, UiData}
    end;
%% @doc this is used for adding a new site
%% 		should returns a messagpack object for efficiency purposes
%%		returns an erlydtl html page afer filter and query		
outa(_Arg, 'GET', [_, "sites", "get_add_site"]) ->
    Inst = yapp_test_lib_usermod:get_inst(),
	Inst_sites = Inst_sites = myapp_util:convert_data(Inst),
	 {ok, UiData} = yapp_test_add_site:render([{inst, Inst_sites},
			      {type_user_tran, "add_site"}]),
    {html, UiData};
%%% @doc this is for getting a site so it can be edited		
outa(_Arg, 'GET',
     [_, "sites", "get_edit_site", Siteid]) ->
    Inst = yapp_test_lib_usermod:get_inst(),
	Inst_sites = Inst_sites = myapp_util:convert_data(Inst),
	%%io:format("~nsites are ~p",[Inst_sites]),
    case yapp_test_lib_usermod:get_site_id(list_to_integer(Siteid)) of
		{ok, S} ->		
		[Site_dict] = myapp_util:convert_data([S]), 				
		{ok, UiData} = yapp_test_add_site:render([{inst,Inst_sites},
						    {data, Site_dict},
						    {type_user_tran,
						     "edit_site"}]),
		{html, UiData};
      _ ->
		yapp_test_lib_util:message_client(500,"Site does Not exist")
    end;
%%% @doc this is for saving a site
outa(Arg, 'POST', [_, "sites", "save_add_site"]) ->
    case yaws_api:postvar(Arg, "id") of
      {ok, Edit_id_val} ->
	  {ok, Sname} = yaws_api:postvar(Arg, "sname"),
	  {ok, Lname} = yaws_api:postvar(Arg, "lname"),
	  {ok, Inst} = yaws_api:postvar(Arg, "inst"),
	  case
	    yapp_test_lib_usermod:update_site(list_to_integer(Edit_id_val),
					      list_to_binary(Sname),
					      list_to_binary(Lname),
					      list_to_integer(Inst))
	      of
	    ok ->
		yapp_test_lib_util:message_client(200,
						  "Site edited successfully");
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  atom_to_list(Reason))
	  end;
      undefined ->
	  {ok, Sname} = yaws_api:postvar(Arg, "sname"),
	  {ok, Lname} = yaws_api:postvar(Arg, "lname"),
	  {ok, Inst} = yaws_api:postvar(Arg, "inst"),
	  case
	    yapp_test_lib_usermod:add_site(list_to_binary(Sname),
					   list_to_binary(Lname),
					   list_to_integer(Inst))
	      of
	    ok ->
		yapp_test_lib_util:message_client(200,
						  "Site added successfully");
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  atom_to_list(Reason))
	  end
    end;
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg, _Method, _) ->
    {page, yapp:prepath(Arg) ++ (?PG_404)}.
