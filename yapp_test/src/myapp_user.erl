%%%
%%% @doc file for the use controller.
%%%<br>this is for user functions</br> 
%%%<br>myapp_user  module </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_user).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").


%%functions for processing pages
-export([
		 out/1
		 ]).
		 
		 
-include_lib("yaws/include/yaws_api.hrl").
-include_lib("yapp_test/include/yapp_test.hrl").
-include_lib("yapp_test_lib/include/yapp_test_lib.hrl").


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
		
%% @doc	this is for the index_dashboard action get method
outa(Arg,'GET',["yapp_test","user","get_users"])->
		Title_Page = "Users",
		Users = yapp_test_lib_usermod:get_users(),
		{ok,UiData} = yapp_test_users_list:render([{title,Title_Page},{yapp_prepath,yapp:prepath(Arg)},{data,Users}]),
		{html,UiData};


%% @doc this is used for filtering list . query strings will be used here 
%% 		returns a messagpack object for efficiency purposes
%%		returns an erlydtl html page afer filter and query
outa(Arg,'GET',["yapp_test","user","search_user"])->
		%%io:format("query string is ~n~p ",[Search_query]),
		case  yaws_api:queryvar(Arg,"filter") of
		   {ok,Filter} ->
				Users = yapp_test_lib_usermod:get_users_filter(Filter),
				{ok,UiData} = yapp_test_user_search:render([{yapp_prepath,yapp:prepath(Arg)},{data,Users}]),		
				{ehtml,UiData}; 
			undefined ->
				Users = yapp_test_lib_usermod:get_users(),
				{ok,UiData} = yapp_test_user_search:render([{yapp_prepath,yapp:prepath(Arg)},{data,Users}]),		
				{ehtml,UiData}
		end;
		
			
%% @doc for adding a new user
%% 		retrieving user interface partt
%% 		returns an erlydtl html page
outa(_Arg,'GET',["yapp_test","user","get_add_user"])->
		{ok,UiData} = yapp_test_add_user:render([{type_user_tran,"add_user"}]),
		{html,UiData};


%% @doc this is used for getting for getting user info/perhaps for editing
%%		query string part of url may have to be further parsed
%% 		retrieving user interface part 
outa(_Arg,'GET',["yapp_test","user","get_edit_user",UserId])->
		case yapp_test_lib_usermod:get_user_id(list_to_integer(UserId)) of 
			{Id,Email,Fname,Lname} ->
				{ok,UiData} = yapp_test_add_user:render([{type_user_tran,"edit_user"},{id,Id},{email,Email},{fname,Fname},{lname,Lname}]),
				{html,UiData};
			_ ->
				yapp_test_lib_util:message_client(500,"User Does Not Exist")
		end;


%% @doc for inserting a new user/updating a new user .
%%		insertion part
%% 		returns a messagpack object showing status 
%%  	validation has not been done here but will be done later 
outa(Arg,'POST',["yapp_test","user","save_add_user"])->
		
		%%Userdata = yaws_api:parse_post(Arg),
		%%io:format("post data is ~p ",[Userdata]),
		case  yaws_api:postvar(Arg,"id") of
		   {ok,_Edit_id_val} ->
				{ok,Id} = yaws_api:postvar(Arg, "id"),
				{ok,Email} = yaws_api:postvar(Arg, "email"),
		        {ok,Fname} = yaws_api:postvar(Arg, "fname"),
		        {ok,Lname} = yaws_api:postvar(Arg, "lname"),
		        Siteid = 1,
		        %%Instid = 1 ,
				case yapp_test_lib_usermod:edit_user(list_to_integer(Id),Email,Fname,Lname,Siteid) of
					ok ->
						yapp_test_lib_util:message_client(200,"User edited successfully");
					{error,Reason} ->
						yapp_test_lib_util:message_client(500,atom_to_list(Reason))
				end;
		   undefined ->
		        {ok,Email} = yaws_api:postvar(Arg, "email"),
		        {ok,Fname} = yaws_api:postvar(Arg, "fname"),
		        {ok,Lname} = yaws_api:postvar(Arg, "lname"),
		        Siteid = 1,
		        Instid = 1 ,
		        case yapp_test_lib_usermod:add_user(Email,Fname,Lname,Siteid,Instid) of 
					ok ->
						yapp_test_lib_util:message_client(200,"User added successfully");
					{error,Reason} ->
						yapp_test_lib_util:message_client(500,atom_to_list(Reason))
				end				
		end;
		
	

			
				
%% @doc this is used for getting roles for a particular user
%% 		returns an erlydtl html page 
outa(_Arg,'GET',["yapp_test","user","get_roles_user",UserId])->
		Userrole =  yapp_test_lib_usermod:get_user_roles(list_to_integer(UserId)),
		Roles = yapp_test_lib_usermod:get_roles(),
		io:format("list is ~p",[dict:to_list(Roles)]),
		{ok,UiData} = yapp_test_edit_roles:render([{useroles,Userrole},{roles,Roles}]),
		{html,UiData};
		
	
	
%% @doc this is for updating roles
%%		insertion part
%% 		returns a messagpack object showing status 
outa(_Arg,'POST',["yapp_test","user","save_roles_user"])->
		ok;	
	

%% @doc this is used for resetting the password of the user 
%% 		insertion part
%%		return a messagepack object showing status 
%% 		message pack functionality has to be worked on 
%%		this part also is supposed to return a error status code when the change is not succesful
%%      have to work on that also 
outa(_Arg,'POST',["yapp_test","user","reset_pass_user",UserId])->
		
		Result = yapp_test_lib_usermod:reset_pass(list_to_integer(UserId)),
		case  Result of
		  {ok,NewPass} -> 
		  yapp_test_lib_util:message_client(200,"New Pass is "++NewPass);
		  {error,Reason} -> yapp_test_lib_util:message_client(500,"Error "++atom_to_list(Reason))
		end;


%% @doc this is used for getting for getting user info/perhaps for editing
%%		query string part of url may have to be further parsed
%% 		insertion part
%%		return a messagepack object showing status 
outa(_Arg,'POST',["yapp_test","user","lock_account_user",UserId])->
		
		Result = yapp_test_lib_usermod:lock_account(list_to_integer(UserId)),
		case  Result of
		  ok -> yapp_test_lib_util:message_client(200,"Account Locked");
		  {error,Reason} -> yapp_test_lib_util:message_client(500,"Error "++atom_to_list(Reason))
		end;
	
		
%% @doc this is used for getting for getting user info/perhaps for editing
%%		query string part of url may have to be further parsed
%% 		insertion part
%%		return a messagepack object showing status 
outa(_Arg,'POST',["yapp_test","user","unlock_account_user",UserId])->
		Result = yapp_test_lib_usermod:unlock_account(list_to_integer(UserId)),
		case  Result of
		  ok -> yapp_test_lib_util:message_client(200,"Account Unlocked");
		  {error,Reason} -> yapp_test_lib_util:message_client(500,"Error "++atom_to_list(Reason))
		end;	
		
				

	
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg,_Method,_)->
		{page,yapp:prepath(Arg)++?PG_404}.
		
		
 %% @TODO return error return code when an error occurs
 %% @TODO seperate error checking code from normal code  
