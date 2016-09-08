%%% 
%%% @doc function for setting up and processing  transactions.
%%%<br></br>
%%%<br>for setting up templates as well as setting up basic rules system </br>
%%%<br>anonymous functions are used to pack the arguements which are needed to do comparison so that comparison will be faster</br>
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>
%%%
-module(yapp_test_lib_isoproc).
-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").

-include_lib("yapp_test_lib/include/yapp_test_lib.hrl").


-export([setup_template/3,
		 setup_rule/4,
		 process_template/3,
		 process_message/2
		]).



%%this sets up a baseline template  for a system which can be customized depending on the input data being used 
%%this will later be used to generate rules for each individual which will then be passed into  
%%data is saved in database for later use by others
-spec setup_template(Template_ident::binary(),Description::binary(),Category::pos_integer())->Fun_processors::fun((...) -> fun()).
setup_template(Template_ident,_Description,_Category)->
		F=fun(Prop_options_user)->
			fun(Isomessage) ->
				process_template(Template_ident,Prop_options_user,Isomessage)
			end
		end.
		
	
%%for setting up rules based on the template above
%% will get the template from the template table using the templateid
%% will then use this to generate the customized rule based on the template and use this in the rule creation
%% rule  which is a customized tempalate due to user options will then be saved in the db  
-spec setup_rule(Instid::pos_integer(),Templateid::pos_integer(),User_options::[tuple()],Description::binary())-> ok.
setup_rule(Instid,Templateid,User_options,_Description)->
		Template=get_template(Templateid),
		Rule_user = Template(User_options),
		ok.
 

%%this is used for processing the message and getting the final result
%%this step will help in filtering out the users of the template
-spec process_message(fun(),binary())-> true | false . 
process_message(Fun_rule,Message)->
		Fun_rule(Message).

%%this function is used for getting fun representing templates based on the templateid 
%%info is retrieved from db 
-spec get_template(Tempid::pos_integer())->fun() | error.
get_template(Tempid)->
			ok.


-spec process_template(Template_type::binary(),Options_creator::[tuple()],Isomessage::binary())->true|false.
process_template(<<"inst_test">>,Options_creator,Isomessage)->
		Inst = proplists:get_value(name,Options_creator),
		Inst_iso = proplists:get_value(name,Isomessage),
		case  Inst =:= Inst_iso of 
			true ->
				true;
			false ->
				false
		end.
			
		 
		
		
