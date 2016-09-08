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

%%%  usermod_users_links for links for roles .%%type bag
-record(usermod_role_links,{role_id,link_id}). 

%%%  test_new_rec
-record(test_rec,{name,fname,lname}).

%%  auto_inc_table
-record(auto_inc,{name,cvalue}).

%%% record for storing session information
-record(session_data,{id,site_id,inst_id,fname,userdata=[],links_allowed=[]}). 

%%% record for storing the site information
-record(usermod_sites,{id,site_short_name,site_long_name,inst_id}).

%%% record for storing the institution information
-record(usermod_inst,{id,inst_short_name,inst_long_name,inst_ident}).

%%% record for categories
-record(usermod_categories,{id,category}).



%% record definition for templates
-record(tempmod_temp,{id,ident,temp_fun,description,category_temp}).

%% record definition for rules
-record(tempmod_rules,{id,templateid,inst_id,rule_fun,rule_options,description,category_rule}).


%%record definition for template categories
-record(tempmod_temp_cat,{id,description}).


%%record definitions for rule categories
-record(tempmod_rule_cat,{id,description}).



