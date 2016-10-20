{application, erlmon_lib,
 [{description,"Library File for Erl Monitor Web Application/Transaction Server"},
  {vsn,"0.1.0"},
  {modules,[yapp_test_lib,yapp_test_lib_sup,yapp_test_lib_usermod,yapp_test_lib_isoproc,yapp_test_lib_rules,yapp_test_lib_sess,yapp_test_lib_temp]},
  {registered, []},
  {applications,[kernel,stdlib,mnesia]}]}.
