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
		io:format("user logged in and but does not have permission to acces page"),
		{page,yapp:prepath(Arg)++?PG_401};
	
	
%%% @doc logged in users whom hav access to this page come here (exists/access)
out(Arg,ok,ok) ->
		Uri = yaws_api:request_url(Arg),
		Path = string:tokens(Uri#url.path, "/"), 
		Method = (Arg#arg.req)#http_request.method,
		io:format("~nrequest url ~p~n",[Path]),
		outa(Arg,Method,Path).
		
%% @doc	this is for the index_dashboard action get method
outa(Arg,'GET',["yapp_test","user","get_users"])->
		Title_Page = "Users",
		Data = get_users(Arg),
		Response = myapp_dash_layout:get_secondLevelContent(Title_Page,Data),
		{ehtml,Response};


%% @doc this is used for filtering list . query strings will be used here 
%% 		returns a messagpack object for efficiency purposes
%%		returns an erlydtl html page afer filter and query
outa(Arg,'GET',["yapp_test","user","search_user"])->
		Search_query = yaws_api:parse_query(Arg),
		%%io:format("query string is ~n~p ",[Search_query]),
		case  yaws_api:queryvar(Arg,"filter") of
		   undefined ->
				io:format("no filter");
		   Filter ->
				io:format("filter is  ~n~p",[Filter])
		   
		end,
		ok;	
			
			
%% @doc this is used for getting roles for a particular user
%% 		returns an erlydtl html page 
outa(Arg,'GET',["yapp_test","user","get_roles_user",UserId])->
		ok;
	
	
%% @doc this is for updating roles
%%		insertion part
%% 		returns a messagpack object showing status 
outa(Arg,'POST',["yapp_test","user","save_roles_user",UserId])->
		ok;	
	

%% @doc for adding a new user
%% 		retrieving user interface part
%% 		returns an erlydtl html page
outa(Arg,'GET',["yapp_test","user","get_add_user"])->
		ok;

	
%% @doc for inserting a new user .
%%		insertion part
%% 		returns a messagpack object showing status 
outa(Arg,'POST',["yapp_test","user","save_add_user"])->
		ok;	
	
	
%% @doc this is used for getting for getting user info/perhaps for editing
%%		query string part of url may have to be further parsed
%% 		retrieving user interface part 
outa(Arg,'GET',["yapp_test","user","get_edit_user",UserId])->
		ok;
	
	
%% @doc this is used for getting for getting user info/perhaps for editing
%%		query string part of url may have to be further parsed
%% 		insertion part
%%		return a messagepack object showing status 
outa(Arg,'POST',["yapp_test","user","save_edit_user",UserId])->
		ok;	
	
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg,_Method,_)->
		{page,yapp:prepath(Arg)++?PG_404}.


%% @doc this is a wrapper function so all you need to show data is the actual content and not any other data

get_out_content(Data) ->
		{'div',[{class,"tableWrapper"}],
			Data
		}.	

%% @doc this is used for getting the users
%%% depending on whether a filter is used or not 
get_users(Arg)->
		Users = yapp_test_lib_usermod:get_users(),
		Data = [gen_content_upper(),gen_content_real(Users)],	 
		get_out_content(Data).


%% @doc this is used for generating the top content of the inner page b4 the actual contnt 
gen_content_upper()->
		{'div',[{class,"tableHeader"}],
					[
						{'ul',[{class,"tableActions"}],
							[
								{'li',[],
									{'a',[{name,"add_user"},{id,"add_user"},{title,"add_user"},{href,"#"},{class,"inlineIcon iconAdvertiserAdd"}],
										"Add New User"
									}
								},
								{'li',[],
									{'input',[{type,"text"},{name,"search_user"},{id,"search_user"},{placeholder,"Search By Name or Email"}]}	
								},
								{'li',[],
									{'input',[{type,"button"},{id,"search_butt"},{name,"search_butt"},{value,"Search"}]}
								
								}
							]
						},
						{'div',[{class,"clear"}]},
						{'div',[{class,"corner left"}]},
						{'div',[{class,"corner right"}]}
					]		
		}.


%% @doc this is used for generating the actual content of the page 
gen_content_real(Users)->
		{'div',[{id,"table_info"},{name,"table_info"}],
			{'table',[{cellspacing,"0"}],
				[
					{'thead',[],
						{'tr',[],
							[
								{'th',[{class,"sortup"}],"Name"},{'th',[{class,"sortup"}],"Email"},{'th',[],"Site"},{'th',[]},
								{'th',[],"Status"},{'th',[]},{'th',[]},{'th',[]},{'th',[{class,"last alignRight"}]},
								{'th',[]},{'th',[]},{'th',[]},{'th',[]}
							]
						}
					
					},
					{'tbody',[],
						lists:map(fun(#usermod_users{id=Id,user_email=Email,fname=Fname,site_id=Site_Id,lname=Lname,lock_status=_Lock_stat})-> 
						          {'tr',[{id,Id}],
									[
										{'td',[{class,"name_info"}],lists:concat([Fname," ",Lname])},
										{'td',[],Email},
										{'td',[],Site_Id},
										{'td',[]},
										{'td',[],"lock_stat"},
										{'td'},{td},{td},
										{'td',[],
											{'ul',[{class,"rowActions"}],
												[
													{'li',[],
														{'a',[{href,"#"},{class,"inlineIcon preferences edit_user"}],"Edit"}
													},
													{'li',[],
														{'a',[{href,"#"},{class,"inlineIcon preferences iconAdvertiser"}],"Roles"}
													},
													{'li',[],
														{'a',[{href,"#"},{class,"inlineIcon preferences iconActivate reset_pass"}],"Reset Pass"}
													},
													{'li',[],
														{'a',[{href,"#"},{class,"inlineIcon preferences iconlock lock"}],"Lock"}
													}
												]
											}
										
										},
										{'td'},{'td'},{'td'},{'td'}
									]
						          }
						
								  end,
						Users)
					
					}
				]
			}
		
		}.

		
