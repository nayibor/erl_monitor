-module(yapp_test_usermod_SUITE).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").
-export([init_per_suite/1,end_per_suite/1,init_per_testcase/2,end_per_testcase/2,all/0]).
-export([add_user/1,add_role/1,add_link/1,add_role_link/1,verify_user/1,add_user_role/1,lock_account/1]).

%%common test definitions for the usermod functions
%%testing whether istill dey happen

all() -> [add_user,add_role,add_link,add_role_link,verify_user,add_user_role,lock_account].

init_per_suite(Config) ->


    Priv = ?config(priv_dir, Config),
    application:set_env(mnesia, dir, Priv),
    yapp_test_lib_usermod:install([node()]),
    application:start(mnesia),
    application:start(yapp_test_lib),
    Config.

end_per_suite(_Config) ->
    application:stop(mnesia),
    ok.

init_per_testcase(_, Config) ->
	io:format("starting usermod tests"),
    Config.

	
end_per_testcase(_, _Config) ->
    ok.


add_user(_Config) ->
	ok = yapp_test_lib_usermod:add_user("nayiborbc@gmail.com",1,123,"Nuku","Ameyibor",1,1).
	%%ok = yapp_test_lib_usermod:add_user("nayiborbc@gmail.com",1,123,"Nuku","Ameyibor",1,1).

add_role(_Config) ->
	ok = yapp_test_lib_usermod:add_role(1,"TRA","Staff").
	
add_link(_Config) ->
	ok = yapp_test_lib_usermod:add_link(33,"Customer","get_sales_info_list",true,"Print","Print Stuff").
	
add_role_link(_Config) ->
	ok = yapp_test_lib_usermod:add_role(2,"ADM","Administrator"),
	ok = yapp_test_lib_usermod:add_link(33,"Customer","get_sales_info_list",true,"Print","Print Stuff"),
	ok = yapp_test_lib_usermod:add_role_link(2,33).
	
add_user_role(_Config) ->
	ok = yapp_test_lib_usermod:add_user("test@gmail.com",1,123,"Nuku","Ameyibor",1,1),
	ok = yapp_test_lib_usermod:add_role(100,"TRA","Staff"),
	ok   = yapp_test_lib_usermod:add_user_roles(1,100),
	{error,check_user_role} = yapp_test_lib_usermod:add_user_roles(121,201).
	
	
verify_user(_Config) -> 
  	ok = yapp_test_lib_usermod:add_user("nayiborcheck@gmail.com",1,123,"Nuku","Ameyibor",1,1),
  	%%ok = yapp_test_lib_usermod:verify_user("nayiborcheck@gmail.com",123),
  	?assertEqual(ok,yapp_test_lib_usermod:verify_user("nayiborcheck@gmail.com",123)).
  	
lock_account(_Config) ->
	
  	ok = yapp_test_lib_usermod:add_user("nayiborlock@gmail.com",1,123,"Nuku","Ameyibor",1,1),
  	{error,check_username_password}=yapp_test_lib_usermod:verify_user("nayiborlock@gmail.com",2),
  	{error,check_username_password}=yapp_test_lib_usermod:verify_user("nayiborlock@gmail.com",3),
  	{error,check_username_password}=yapp_test_lib_usermod:verify_user("nayiborlock@gmail.com",4),
  	{error,check_username_password}=yapp_test_lib_usermod:verify_user("nayiborlock@gmail.com",5),  	
  	{error,check_username_password_lock}=yapp_test_lib_usermod:verify_user("nayiborlock@gmail.com",5).
  	
  	
	
