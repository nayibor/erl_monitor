%%%
%%% @doc myapp_inst module.
%%%<br>contains code for working with istitutions</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_inst).

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

%% @doc	this is for the getting institutions
outa(Arg, 'GET', [_, "inst", "get_inst"]) ->
    Title_Page = "Institutions",
    Inst = yapp_test_lib_usermod:get_inst(),
	Inst_sites = myapp_util:convert_data(Inst),
    %%error_logger:info_msg("~ninst list is ~p ",[Inst]),
    {ok, UiData} = yapp_test_inst_list:render([{title,
						Title_Page},
					       {yapp_prepath,
						yapp:prepath(Arg)},
					       {data, Inst_sites}]),
    {html, UiData};
%% @doc this is for getting the sites but using a filter
outa(Arg, 'GET', [_, "inst", "search_inst"]) ->
    %%io:format("query string is ~n~p ",[Search_query]),
    case yaws_api:queryvar(Arg, "filter") of
      {ok, Filter} ->
		  Inst = yapp_test_lib_usermod:get_inst_filter(list_to_binary(Filter)),
		  Inst_list_filtered =  myapp_util:convert_data(Inst),
		  {ok, UiData} =
		      yapp_test_inst_search:render([{yapp_prepath,
						     yapp:prepath(Arg)},
						    {data, Inst_list_filtered}]),
		  {html, UiData};
      undefined ->
		  Inst = yapp_test_lib_usermod:get_inst(),
		  Dict_records = myapp_util:convert_data(Inst),
		  {ok, UiData} =
		      yapp_test_inst_search:render([{yapp_prepath,
						     yapp:prepath(Arg)},
						    {data, Dict_records}]),
		  {html, UiData}
    end;
%% @doc this is used for adding a new insittution
%%		returns an erlydtl html page afer filter and query		
outa(_Arg, 'GET', [_, "inst", "get_add_inst"]) ->
    {ok, UiData} =
	yapp_test_add_inst:render([{type_user_tran,
				    "add_inst"}]),
    {html, UiData};
%% @doc this is used for adding a new insittution
%%		returns an erlydtl html page afer filter and query		
outa(_Arg, 'GET',
     [_, "inst", "get_edit_inst", Instid]) ->
    Stid = list_to_integer(Instid),
    case yapp_test_lib_usermod:get_inst_id(Stid) of
      {error, inst_non_exists} ->
	  yapp_test_lib_util:message_client(500,
					    "Inst Does Not Exist");
      S ->
		[Inst_dict] = myapp_util:convert_data([S]),
		{ok, UiData} =
	      yapp_test_add_inst:render([{type_user_tran,
					  "edit_inst"},
					 {data, Inst_dict}]),
	  {html, UiData}
    end;
%% @doc this is used for adding a new insittution
%%		returns an erlydtl html page afer filter and query		
outa(Arg, 'POST', [_, "inst", "save_add_inst"]) ->
    case yaws_api:postvar(Arg, "id") of
      {ok, Edit_id_val} ->
	  {ok, Sname} = yaws_api:postvar(Arg, "sname"),
	  {ok, Lname} = yaws_api:postvar(Arg, "lname"),
	  {ok, Ident} = yaws_api:postvar(Arg, "ident"),
	  case
	    yapp_test_lib_usermod:edit_inst(list_to_integer(Edit_id_val),
					    list_to_binary(Sname),
					    list_to_binary(Lname),
					    list_to_binary(Ident))
	      of
	    ok ->
		yapp_test_lib_util:message_client(200,
						  "Inst edited successfully");
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  atom_to_list(Reason))
	  end;
      undefined ->
	  {ok, Sname} = yaws_api:postvar(Arg, "sname"),
	  {ok, Lname} = yaws_api:postvar(Arg, "lname"),
	  {ok, Ident} = yaws_api:postvar(Arg, "ident"),
	  case
	    yapp_test_lib_usermod:add_inst(list_to_binary(Sname),
					   list_to_binary(Lname),
					   list_to_binary(Ident))
	      of
	    ok ->
		yapp_test_lib_util:message_client(200,
						  "Inst Added successfully");
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  atom_to_list(Reason))
	  end
    end;
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg, _Method, _) ->
    {page, yapp:prepath(Arg) ++ (?PG_404)}.
