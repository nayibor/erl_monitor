%%%
%%% @doc header file for records/commonly used macros for yapp_test_lib
%%%
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").


%%% usermod_users for user information
-record(usermod_users,{id,user_email,password,fname,lname,site_id,inst_id,lock_status=0}). 

%%% usermod_roles for role information
-record(usermod_roles,{id,role_short_name,role_long_name}).

%%%  usermod_links for link information
-record(usermod_links,{id,link_controller,link_action,link_allow,link_category,link_name,link_type}). 

%%%  usermod_users_roles for roles for users .type bag
-record(usermod_users_roles,{user_id,role_id}).

%%%  usermod_users_links for links for users .%%type bag
-record(usermod_role_links,{role_id,link_id}). 


%%%  test_new_rec
-record(test_rec,{name,fname,lname}).

