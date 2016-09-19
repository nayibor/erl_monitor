{application, yapp_test_sock,
 [{description,"Transaction Socket Server"},
  {vsn,"0.1.0"},
  {modules,[yapp_test_sock_app,yapp_test_sock_supersup,yapp_test_ppool_serv,yapp_test_sock_sup,yapp_test_sock_serv]},
  {registered, []},
  {mod,{yapp_test_sock_app,[]}},
  {env,[{port, 8005},{name,sock_srv},{limit,50}]},
  {applications,[kernel,stdlib,mnesia]}]}.
