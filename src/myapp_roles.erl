%%%
%%% @doc myapp_roles module.
%%%<br>contains module for working with roles in the system</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_roles).

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

%% @doc	this is for the getting roles
outa(Arg, 'GET', [_, "roles", "get_roles"]) ->
    Title_Page = "Roles",
    Roles = yapp_test_lib_usermod:get_roles(),
    {ok, UiData} = yapp_test_roles_list:render([{title,
						 Title_Page},
						{yapp_prepath,
						 yapp:prepath(Arg)},
						{data, Roles}]),
    {html, UiData};
%% @doc this is used for filtering list . query strings will be used here
%% 		returns a messagpack object for efficiency purposes
%%		returns an erlydtl html page afer filter and query
outa(Arg, 'GET', [_, "roles", "search_roles"]) ->
    %%io:format("query string is ~n~p ",[Search_query]),
    case yaws_api:queryvar(Arg, "filter") of
      {ok, Filter} ->
	  Roles =
	      yapp_test_lib_usermod:get_roles_filter(list_to_binary(Filter)),
	  {ok, UiData} =
	      yapp_test_roles_search:render([{yapp_prepath,
					      yapp:prepath(Arg)},
					     {data, Roles}]),
	  {html, UiData};
      undefined ->
	  Roles = yapp_test_lib_usermod:get_roles(),
	  {ok, UiData} =
	      yapp_test_roles_search:render([{yapp_prepath,
					      yapp:prepath(Arg)},
					     {data, Roles}]),
	  {html, UiData}
    end;
%% @doc this is used for adding a new role
%% 		should returns a messagpack object for efficiency purposes
%%		returns an erlydtl html page afer filter and query		
outa(_Arg, 'GET', [_, "roles", "get_add_role"]) ->
    {ok, UiData} =
	yapp_test_add_role:render([{type_user_tran,
				    "add_role"}]),
    {html, UiData};
%% @doc for editing roles
%% 		
outa(_Arg, 'GET',
     [_, "roles", "get_edit_roles", Roleid]) ->
    case
      yapp_test_lib_usermod:get_roles_id(list_to_integer(Roleid))
	of
      {ok, S} ->
	  {ok, UiData} = yapp_test_add_role:render([{data, S},
						    {type_user_tran,
						     "edit_role"}]),
	  {html, UiData};
      _ ->
	  yapp_test_lib_util:message_client(500,
					    "Role Does Not Exist")
    end;
%% @doc this is used for adding a new role
%% 		should returns a messagpack object for efficiency purposes
%%		returns an erlydtl html page afer filter and query		
outa(Arg, 'POST', [_, "roles", "save_add_role"]) ->
    case yaws_api:postvar(Arg, "id") of
      {ok, Edit_id_val} ->
	  {ok, Sname} = yaws_api:postvar(Arg, "sname"),
	  {ok, Lname} = yaws_api:postvar(Arg, "lname"),
	  case
	    yapp_test_lib_usermod:edit_role(list_to_integer(Edit_id_val),
					    list_to_binary(Sname),
					    list_to_binary(Lname))
	      of
	    ok ->
		yapp_test_lib_util:message_client(200,
						  "Role edited successfully");
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  atom_to_list(Reason))
	  end;
      undefined ->
	  {ok, Sname} = yaws_api:postvar(Arg, "sname"),
	  {ok, Lname} = yaws_api:postvar(Arg, "lname"),
	  case
	    yapp_test_lib_usermod:add_role(list_to_binary(Sname),
					   list_to_binary(Lname))
	      of
	    ok ->
		yapp_test_lib_util:message_client(200,
						  "Role added successfully");
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  atom_to_list(Reason))
	  end
    end;
outa(_Arg, 'GET',
     [_, "roles", "get_role_links", Roleid]) ->
    Links = yapp_test_lib_usermod:get_links_for_roles(),
    Rlinks =
	yapp_test_lib_usermod:get_role_links_setup(list_to_integer(Roleid)),
    {ok, UiData} =
	yapp_test_edit_roles_links:render([{links, Links},
					   {rolelinks, Rlinks}]),
    {html, UiData};
%%	@doc for saving roles for a user
outa(Arg, 'POST', [_, "roles", "save_role_links"]) ->
    case yaws_api:postvar(Arg, "roleid") =:= {ok, []} orelse
	   yaws_api:postvar(Arg, "roleid") =:= undefined orelse
	     yaws_api:postvar(Arg, "new_links") =:= undefined
	of
      true ->
	  yapp_test_lib_util:message_client(500,
					    "Required Field is Empty");
      false ->
	  Data = [outa_2(V2) || V2 <- yaws_api:parse_post(Arg)],
	  [Id] = proplists:get_value("roleid", Data),
	  Links_save = proplists:get_value("new_links", Data),
	  case yapp_test_lib_usermod:add_role_link_list(Id,
							Links_save)
	      of
	    {error, Reason} ->
		yapp_test_lib_util:message_client(500,
						  "Error " ++
						    atom_to_list(Reason));
	    ok ->
		yapp_test_lib_util:message_client(200,
						  "Save Successful")
	  end
    end;
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg, _Method, _) ->
    {page, yapp:prepath(Arg) ++ (?PG_404)}.

outa_1(Pv) -> list_to_integer(Pv).

outa_2({Postkey, Postval}) ->
    {Postkey,
     [outa_1(V1) || V1 <- string:tokens(Postval, ",")]}.

 %% @TODO return error return code when an error occurs
 %% @TODO seperate error checking code from normal code  		

