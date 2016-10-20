%%% 
%%% @doc function for working with temp,rules,rule categories,temp categories tables.
%%%<br></br>
%%%<br>for setting up templates as well as setting up basic rules system </br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_lib_temp).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").
-include_lib("stdlib/include/qlc.hrl").
-include_lib("stdlib/include/ms_transform.hrl").
-include_lib("erlmon_lib/include/yapp_test_lib.hrl").

%%for dealing with categories
-export([add_category_rules/1,
		 add_category_temp/1
		]).






%% @doc this is for adding a categorization for templates to the system for using for the templates to 
		%categorize them 
-spec add_category_temp(Description_Category::binary())->ok | term().
add_category_temp(Description)->

		F = fun() ->
					mnesia:write(#tempmod_temp_cat{id=yapp_test_lib_usermod:get_set_auto(tempmod_temp_cat),description=Description})
		end,
		mnesia:activity(transaction,F).


%% @doc this is for adding a category for the rules  system for using for the templates to 
		%categorize them 
add_category_rules(Description)->
		F = fun() ->
					mnesia:write(#tempmod_rule_cat{id=yapp_test_lib_usermod:get_set_auto(tempmod_rule_cat),description=Description})
		end,
		mnesia:activity(transaction,F).
		
		
		
		

		    	    
