%%%
%%% @doc file for the use controller.
%%%<br>this is for links functions</br>
%%%<br>myapp_user  module </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_links).

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

%% @doc	this is for the index page of the links
outa(Arg, 'GET', [_, "links", "get_links"]) ->
    Title_Page = "Links",
    Links = yapp_test_lib_usermod:get_links(),
	Links_new = myapp_util:convert_data(Links),
    {ok, UiData} = yapp_test_links_list:render([{title,
						 Title_Page},
						{yapp_prepath,
						 yapp:prepath(Arg)},
						{data, Links_new}]),
    {html, UiData};
%% @doc	this is for searching for a link		
outa(Arg, 'GET', [_, "links", "search_links"]) ->
    %%io:format("query string is ~n~p ",[Search_query]),
    %%io:format("get data is ~p,~n",[yaws_api:parse_query(Arg)]),
    case yaws_api:queryvar(Arg, "filter") of
      {ok, Filter} ->
		  Links = yapp_test_lib_usermod:get_links_filter(Filter),
		  New_links = myapp_util:convert_data(Links),
		  {ok, UiData} =
	      yapp_test_link_search:render([{yapp_prepath,yapp:prepath(Arg)},{data, New_links}]),
		  {ehtml, UiData};
      undefined ->
		  Links = yapp_test_lib_usermod:get_links(),
		  New_links = myapp_util:convert_data(Links),
		  {ok, UiData} =
		      yapp_test_link_search:render([{yapp_prepath,
						     yapp:prepath(Arg)},
						    {data, New_links}]),
		  {ehtml, UiData}
    end;
%% @doc for adding a new link
%% 		retrieving user interface partt
%% 		returns an erlydtl html page
outa(_Arg, 'GET', [_, "links", "get_add_link"]) ->
    Categories = yapp_test_lib_usermod:get_cats(),
	Categories_new = myapp_util:convert_data(Categories),
    {ok, UiData} = yapp_test_add_link:render([{cats,Categories_new},{type_user_tran, "add_link"}]),
    {html, UiData};
%% @doc this is used for getting for getting user info/perhaps for editing
%%		query string part of url may have to be further parsed
%% 		retrieving user interface part
outa(_Arg, 'GET',
     [_, "links", "get_edit_link", Linkid]) ->
    case yapp_test_lib_usermod:get_links_id(list_to_integer(Linkid)) of
      {ok, S} ->
		  [Cat_dict] = myapp_util:convert_data([S]),
		  Cats = yapp_test_lib_usermod:get_cats(),
		  Categories_new = myapp_util:convert_data(Cats),
		  {ok, UiData} =
		      yapp_test_add_link:render([{type_user_tran,"edit_link"},{data, Cat_dict}, {cats, Categories_new}]),
		  {html, UiData};
      _ ->
		yapp_test_lib_util:message_client(500,"Link Does Not Exist")
    end;
%% @doc for inserting a new user/updating a new user .
%%		insertion part
%% 		returns a messagpack object showing status
%%  	validation has not been done here but will be done later
outa(Arg, 'POST', [_, "links", "save_link"]) ->
    case yaws_api:postvar(Arg, "id") of
      {ok, Edit_id_val} ->
	  {ok, Link_name} = yaws_api:postvar(Arg, "link_name"),
	  {ok, Controller} = yaws_api:postvar(Arg,
					      "link_controller"),
	  {ok, Link_action} = yaws_api:postvar(Arg,
					       "link_action"),
	  {ok, Link_allow} = yaws_api:postvar(Arg, "link_allow"),
	  {ok, Link_type} = yaws_api:postvar(Arg, "link_type"),
	  {ok, Link_category} = yaws_api:postvar(Arg, "category"),
	  case
	    yapp_test_lib_usermod:edit_link(list_to_integer(Edit_id_val),
					    Controller, Link_action,
					    list_to_atom(Link_allow),
					    list_to_integer(Link_category),
					    Link_name, list_to_atom(Link_type))
	      of
	    ok ->
		yapp_test_lib_util:message_client(200,
						  list_to_binary("Link edited successfully"));
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  atom_to_binary(Reason, utf8))
	  end;
      undefined ->
	  {ok, Link_name} = yaws_api:postvar(Arg, "link_name"),
	  {ok, Controller} = yaws_api:postvar(Arg,
					      "link_controller"),
	  {ok, Link_action} = yaws_api:postvar(Arg,
					       "link_action"),
	  {ok, Link_allow} = yaws_api:postvar(Arg, "link_allow"),
	  {ok, Link_type} = yaws_api:postvar(Arg, "link_type"),
	  {ok, Link_category} = yaws_api:postvar(Arg, "category"),
	  case yapp_test_lib_usermod:add_link(Controller,
					      Link_action,
					      list_to_atom(Link_allow),
					      list_to_integer(Link_category),
					      Link_name,
					      list_to_atom(Link_type))
	      of
	    ok ->
		yapp_test_lib_util:message_client(200,
						  "Link added successfully");
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  atom_to_binary(Reason, utf8))
	  end
    end;
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg, _Method, _) ->
    {page, yapp:prepath(Arg) ++ (?PG_404)}.

 %% @TODO return error return code when an error occurs
 %% @TODO seperate error checking code from normal code  		

