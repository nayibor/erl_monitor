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
		 get_secondLevelContent/2
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
					}
					
				]
			}
		].
%%name="setting_dialog-message" id="setting_dialog-message" title="Message">

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
