%%%
%%% @doc yapp_test_lib_usermod module.
%%%<br>contains utility functions</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-module(yapp_test_lib_util).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").

%%functions for processing pages
-export([
		 compile_temp/0,
		 message_client/2
		 ]).

%%included so that records can be added when compiling templates
-include_lib("yapp_test_lib/include/yapp_test_lib.hrl").

-define(RECORDS_INFO_IN,[{usermod_users, record_info(fields, usermod_users)},
							{usermod_roles, record_info(fields, usermod_roles)},
							{usermod_links, record_info(fields, usermod_links)},
							{usermod_users_roles, record_info(fields, usermod_users_roles)},
							{test_rec, record_info(fields, test_rec)},
							{auto_inc, record_info(fields, auto_inc)}
							{session_data, record_info(fields, session_data)},
							{usermod_sites, record_info(fields, usermod_sites)},
							{usermod_inst, record_info(fields, usermod_inst)}]).


%%shortcut for compiling template for project 
-spec compile_temp() -> term() . 
compile_temp() ->
		compile_templates([
							{"/home/nuku/Documents/PROJECTS/erlang/proj/yaws/test/yapp_test_root/yapp_test/templates","/home/nuku/Documents/PROJECTS/erlang/proj/yaws/test/yapp_test_root/yapp_test/ebin"
							}
						  ]
						 ).
	   
	   
%%%% @doc compiles erdtl templates submite to an output folder
-spec  compile_templates([{Indir::string(),Outdir::string()}])-> term() .   
compile_templates(Listdir) ->
		lists:map(fun({Indir,Outdir})-> compile_temp_dir(Indir,Outdir) end,Listdir).


%%%% @doc compiles the individual files in the template directory	
-spec 	compile_temp_dir([string()],[string()]) -> [ok] | term() . 
compile_temp_dir(Indir,Outdir) ->
		Directlist =string:tokens(os:cmd("ls "++Indir),"\n"),
		%%io:format("items_directory ~p~n",[Indir]),
		lists:map(fun(File)-> 
		%%io:format("~p--~p-~p~n,",[File,lists:nth(1,string:tokens(File,".")),Outdir])
				erlydtl:compile_file(Indir++"/"++File,lists:nth(1,string:tokens(File,".")), 
				[
						{out_dir,Outdir},{record_info,
										[
											{usermod_roles, record_info(fields, usermod_roles)},
										    {usermod_sites, record_info(fields, usermod_sites)},
										    {usermod_links, record_info(fields, usermod_links)},
											{usermod_categories, record_info(fields, usermod_categories)},
											{usermod_inst, record_info(fields, usermod_inst)},
											{tempmod_temp, record_info(fields, tempmod_temp)},
											{tempmod_temp_cat, record_info(fields, tempmod_temp_cat)},
											{tempmod_rules_temp, record_info(fields, tempmod_rules_temp)},
											{tempmod_temp_cat, record_info(fields, tempmod_temp_cat)},
											{tempmod_rule_cat, record_info(fields, tempmod_rule_cat)}
											

										]
									 },{verbose,verbose},{debug_info,debug_info}
				])  
				end,Directlist).
	  
 
%%%sends a response with  a code and a reason for why what happened happend
%%%put here so that all messages sent back to the client can have one format and if possile encoded using one messaging pattern
%%% message pack will be added soon for the encoding :):) . you like that huh :)
-spec message_client(pos_integer(),string())-> [tuple()].
message_client(Code,Reason)->
		[{status, Code},
		{html,Reason}
		].

