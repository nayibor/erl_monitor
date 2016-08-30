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
				erlydtl:compile_file(Indir++"/"++File,lists:nth(1,string:tokens(File,".")), [{out_dir,Outdir}])  
				end,Directlist).
	  

%%%sends a response with  a code and a reason for why what happened happend
%%%put here so that all messages sent back to the client can have one format and if possile encoded using one messaging pattern
%%% message pack will be added soon for the encoding :):) . you like that huh 
-spec message_client(pos_integer(),string())-> [tuple()].
message_client(Code,Reason)->
		[{status, Code},
		{html,Reason}
		].

