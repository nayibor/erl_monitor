%%%
%%% @doc myapp_dashboard module.
%%%<br>dashboard module </br>
%%%<br>lots of links to other functionality can be found here</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_dashboard_old).
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
		{page,yapp:prepath(Arg)++?AUTH_PAGE};

%%% @doc user is logged but check has to be still done as to whether user has access to page 
out(Arg,ok) ->
		%%io:format("cookie availables.does page exist??~p~n",[yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)]),
		out(Arg,ok,yapp_test_lib_sess:check_perm_page(Arg,?COOKIE_VARIABLE)).


%% @doc logged in users whom dont have access to page are shown the page for restricted users
out(Arg,ok,error) ->
		io:format("user logged in and but does not have permission to acces page"),
		{page,yapp:prepath(Arg)++?PG_401};
	
	
%%% @doc logged in users whom hav access to this page come here
%%%%	 headers,sidebars,footers are setup here.erlydtl can also be setup here 
%%%%  	 also at this page,the url is parsed and user may have to be taken to correct action
%%%%@end
out(Arg,ok,ok) ->
		Uri = yaws_api:request_url(Arg),
		Path = string:tokens(Uri#url.path, "/"), 
		io:format("~nrequest url ~p~n",[Path]),
		outa(Arg,Path).
	
	
%% @doc	this is for the index_dashboard action

outa(Arg,["yapp_test","dashboard","index_dashboard"])->
	Title_Page="Staff",
	Users = yapp_test_lib_usermod:get_users(),
	io:format("Users ~p~n",[Users]),
		
		[
			{ssi, "tab_prebody.inc","%%",[]},
			{ssi, "tab_header.inc","%%",[{"fname","Test_Name"}]},
			{ssi, "tab_home.inc","%%",[]},
			{ehtml,
				{'div',[{'id',"firstLevelContent"}],
					[
						get_sidebar(Arg),
						get_secondLevelContent(Title_Page,gen_content(Users))
					]
				}
			}
		];
	
%% @doc for unknown pages which may be specialized for this layout/controller
%% 		error handler takes cares of this so whats the essence ???		
outa(Arg,_)->
	out(Arg,error).


%% @doc this is for generating the header for the page		
gen_header(InputData)->
		InputData.
		
		
%% @doc this is used for generating the top content of the page before the actual content
gen_content(Users)->
		{'div',[{class,"tableWrapper"}],
			[
			gen_content_upper(),
			gen_content_real(Users)	
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
						lists:map(fun(#usermod_users{id=Id,user_email=Email,fname=Fname,site_id=Site_Id,lname=Lname,lock_status=Lock_stat})-> 
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
		
		
		
		

%% @doc this is used to get the div for the layout and the actual cotent
get_secondLevelContent(Layout_Title,Page_Content)->
       {'div',[{id,"secondLevelContent"}],
			[
				{'div',[{id,"thirdLevelHeader"}],
					{'div',[{class,"breadcrumb hasIcon iconBannersLarge"}],
						{h3,[{class,"noBreadcrumb"}],
							{span,[{class,"label"}],Layout_Title}
						}
					}
				},
				{'div',[{id,"thirdLevelContent"},{style,"min-height: 456px;"}],
					Page_Content
				}
			]
       }.
 

%% @doc used for getting sidebar information
get_sidebar(Arg) -> 
		[{_,Name},{_,Links_Allowd}] = yapp_test_lib_sess:get_user_data(Arg,?COOKIE_VARIABLE),			
		{'div',[{id,"secondLevelNavigation"}],
			{'ul',[{class,"navigation first"}],
				lists:map(fun(S={Cat,Links_List})-> 
					{'li',[{class,"active"}],
						[
							{'a',[{href,"#"}],
								[
									{label,[],Cat},
									{span,[{class,top}]},
									{span,[{class,bottom}]}
								]	
							},
							{'ul',[{class,navigation}],
								lists:map(fun({Controller,Action,Label})->
									{'li',[{class,passive}],
										[
										    {'a',[{href,yapp:prepath(Arg)++Controller++"/"++Action}],Label},
										    {'span',[{class,top}]},
										    {'span',[{class,bottom}]}
										]
									}	
									
								end,Links_List)
							}
						]
					}
				end,Links_Allowd)
			}		
		
		}.

	
%% @doc this is for generating the footer for the page		
gen_footer(InputData)->
		InputData.	

