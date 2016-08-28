%%%
%%% @doc layout file for use by other modules.
%%%<br>myapp_dash_layout  module </br>
%%%<br>layout file</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(myapp_dash_layout).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").


%%functions for processing pages
-export([
		 out/3,
		 show_dashboard/1,
		 get_secondLevelContent/2,
		 gen_content_upper/0,
		 gen_content_real/2,
		 get_out_content/1
		 ]).

-include_lib("yaws/include/yaws_api.hrl").
-include_lib("yapp_test/include/yapp_test.hrl").


%% @doc this is for showing only the dashboard page 
%%      all pages have access to this page/layout
show_dashboard(Arg) ->
		out(Arg,"Dashboard",{'div',[],"Welcome To Dashboard"}).
		
		
out(Arg,Title_Page,Content_layout) ->
		[{_,Name},{_,Links_Allowd}] = yapp_test_lib_sess:get_user_data(Arg,?COOKIE_VARIABLE),
		[
			{ssi, "tab_prebody.inc","%%",[]},
			{ssi, "tab_header.inc","%%",[{"fname",Name}]},
			{ssi, "tab_home.inc","%%",[]},
			{ehtml,
				[
					{'div',[{id,"firstLevelContent"}],
						[
							get_sidebar(Arg,Links_Allowd),
							get_secondLevelContent(Title_Page,Content_layout)
						]
					},
					{'div',[{name,"setting_dialog-confirm"},{id,"setting_dialog-confirm"},{title,"Message"}],
						{'p',[{class,"message"}]}
					},
					{'div',[{name,"setting_dialog-message"},{id,"setting_dialog-message"},{title,"Message"}],
						{'p',[{class,"message"}]}
					},
					{'div',[{name,"add_edit_user"},{id,"add_edit_user"},{title,"Message"}]}
					
				]
			}
		].
%%name="setting_dialog-message" id="setting_dialog-message" title="Message">

%% @doc this is a wrapper function so all you need to show data is the actual content and not any other data
get_out_content(Data) ->
		{'div',[{class,"tableWrapper"}],
			Data
		}.	


%% @doc this is used to get the div for the layout and the actual content
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
get_sidebar(Arg,Links_Allowd) -> 
		%%[{_,Name},{_,Links_Allowd}] = yapp_test_lib_sess:get_user_data(Arg,?COOKIE_VARIABLE),			
		{'div',[{id,"secondLevelNavigation"}],
			{'ul',[{class,"navigation first"}],
				lists:map(fun({Cat,Links_List})-> 
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
								lists:map(fun({Controller,Action,Label,_Link_Type})->
									{'li',[{class,passive}],
										[
										    {'a',[{class,"load_content"},{href,yapp:prepath(Arg)++Controller++"/"++Action}],Label},
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
gen_content_real(Arg,Users)->
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
						lists:map(fun({Id,Email,Fname,Lname,Site_id,Lock_stat,_} )-> 
						          {'tr',[{id,Id}],
									[
										{'td',[{class,"name_info"}],lists:concat([Fname," ",Lname])},
										{'td',[],Email},
										{'td',[],Site_id},
										{'td',[]},
										{'td',[],Lock_stat },
										{'td'},{td},{td},
										{'td',[],
											{'ul',[{class,"rowActions"}],
												[
													{'li',[],%%yapp:prepath(Arg)++"get_edit_user"++"/"++Id
														{'a',[{href,yapp:prepath(Arg)++"user/get_edit_user"++"/"++integer_to_list(Id)},{class,"inlineIcon preferences edit_user"}],"Edit"}
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

		
			
