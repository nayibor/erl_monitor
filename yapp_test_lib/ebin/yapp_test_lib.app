{application, yapp_test_lib,
 [{description,"Yap Test"},
  {vsn,"0.1.0"},
  {modules,[yapp_test_lib,yapp_test_lib_sup,yapp_test_lib_usermod]},
  {registered, []},
  {applications,[kernel,stdlib,mnesia]}]}.
