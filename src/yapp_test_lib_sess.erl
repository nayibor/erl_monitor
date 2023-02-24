%%%
%%% @doc yapp_test_lib_sess module.
%%%<br>contains basic functions for basic session handling</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(yapp_test_lib_sess).

-author("Nuku Ameyibor <nayibor@startmail.com>").

-github("https://bitbucket.com/nameyibor").

-license("Apache License 2.0").

-include_lib("yaws/include/yaws_api.hrl").

%%%functions for checking user/page permissions
-export([check_login/2, check_perm_page/2,
	 get_user_data/2, get_user_websocket/2, kill_session/2,
	 setup_session/6]).

%%type data for storing sessions
%%% record for storing session information
-record(session_data,
	{id, site_id, inst_id, fname, userdata = [],
	 links_allowed = []}).

%%% @doc for checking whether a user is logged in or not
check_login(Arg, Cookie) ->
    H = Arg#arg.headers,
    case yaws_api:find_cookie_val(Cookie, H#headers.cookie)
	of
      [] -> error;
      Cookie_Unique ->
	  case yaws_api:cookieval_to_opaque(Cookie_Unique) of
	    {ok, _Op} -> ok;
	    {error, no_session} -> error
	  end
    end.

%%% @doc check permission for a page
%%% cookie has already been checked and reset in previous but in case of high usage
%%% still needs to be checked maybe due to scheduling ????
%%% {ok, _OP=#session_data{id=_Id,userdata=_UseData,links_allowed=_Links_Allowd}}
%%%
check_perm_page(Arg, Cookie) ->
    H = Arg#arg.headers,
    Uri = yaws_api:request_url(Arg),
    Path = string:tokens(Uri#url.path, "/"),
    Controller = lists:nth(2, Path),
    Action = lists:nth(3, Path),
    Test = {Controller, Action},
    case yaws_api:find_cookie_val(Cookie, H#headers.cookie)
	of
      [] -> error;
      Cookie_Unique ->
	  %%io:format("cookie unique value is ~n~p~n",[Cookie_Unique]),
	  case yaws_api:cookieval_to_opaque(Cookie_Unique) of
	    {ok,
	     _OP = #session_data{id = _Id, userdata = _UseData,
				 links_allowed = Links_Allowd}} ->
		case lists:member(Test, get_cont_act(Links_Allowd)) of
		  true -> ok;
		  false -> error
		end;
	    {error, no_session} -> error
	  end
    end.

%% @doc for loggin out a user
%% user session data is deleted
%%% @end
kill_session(Arg, Cookie) ->
    H = Arg#arg.headers,
    case yaws_api:find_cookie_val(Cookie, H#headers.cookie)
	of
      [] -> error;
      Cookie_Unique ->
	  yaws_api:delete_cookie_session(Cookie_Unique), ok
    end.

%% @doc get user data from session
%% links of type ajax arent show on the sidebar although they are still checked to see whether user has access b4
%% user is allowd to view them
get_user_data(Arg, Cookie) ->
    H = Arg#arg.headers,
    case yaws_api:find_cookie_val(Cookie, H#headers.cookie)
	of
      [] -> error;
      Cookie_Unique ->
	  case yaws_api:cookieval_to_opaque(Cookie_Unique) of
	    {ok,
	     _OP = #session_data{id = _Id, fname = Name,
				 userdata = _UseData,
				 links_allowed = Links_Allowd}} ->
		[{user_name, Name},
		 {user_data, get_sidebar_links(Links_Allowd)}];
	    {error, no_session} -> error
	  end
    end.

%% @doc this is used for getting information which will be passed to the websocket session
get_user_websocket(Arg, Cookie) ->
    H = Arg#arg.headers,
    case yaws_api:find_cookie_val(Cookie, H#headers.cookie)
	of
      [] -> error;
      Cookie_Unique ->
	  case yaws_api:cookieval_to_opaque(Cookie_Unique) of
	    {ok, _OP = #session_data{id = Id, fname = Name}} ->
		[{user_name, Name}, {id, Id}];
	    {error, no_session} -> error
	  end
    end.

%%% @doc for obtaining permissible links for a user from mnesia/external data store
%%% putting that data in the yaws session variable
%%% also for getting  other user specific setup data and putting it in mnesia
%%% @end
setup_session(Userid, Fname, Site_id, Inst_id,
	      _Cookie_MaxTime, UserData) ->
    S = #session_data{id = Userid, fname = Fname,
		      site_id = Site_id, inst_id = Inst_id,
		      links_allowed = UserData},
    yaws_api:new_cookie_session(S).

%%%% used to check whether a link exists for user and exists if link found in user link list					
%%check_link(Key,List)->check_link(Key,List,false).
%%check_link(_Key,_List,true)->ok;
%%check_link(_Key,[],_) ->error;
%%check_link(Key,[H|T],false)->check_link(Key,T,lists:member(Key,H)).

%%	@doc for filtering to show only sidebar links at the side of the page
%%	ajax link types can also be checked although they dont appear in the sidebar 			
%%	@end	
get_sidebar_links(List_cat) ->
    lists:foldl(fun ({C, ListEl}, Acc) ->
			[{C, [V1 || V1 <- ListEl, get_sidebar_links_1(V1)]}
			 | Acc]
		end,
		[], List_cat).

get_sidebar_links_1({_Fi, _Si, _Ti, Fti}) ->
    Fti =:= sidebar.

%%% @doc for getting a list of only controller/actions from the categorized list
%%% have to see if there isnt a better way of doing this ????????? . feels like its iniefficient but have to benchmark to find out
%%% may have to resort to using the above one but will have to check and see .very interesting stuff
%%%	@end
get_cont_act(List_cat) ->
    lists:append(lists:foldl(fun ({_C, ListEl}, Acc) ->
				     [[get_cont_act_1(V1) || V1 <- ListEl]
				      | Acc]
			     end,
			     [], List_cat)).

get_cont_act_1({Fi, Si, _Ti, _Fti}) -> {Fi, Si}.
