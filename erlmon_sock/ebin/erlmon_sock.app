{application, erlmon_sock,
 [{description,"Transaction Socket Server"},
  {vsn,"0.1.0"},
  {modules,[yapp_test_sock_app,yapp_test_sock_supersup,yapp_test_ppool_serv,yapp_test_sock_sup,yapp_test_sock_serv,yapp_test_sock_test_gen]},
  {registered, [counter]},
  {mod,{yapp_test_sock_app,[]}},
  {env,[{port, 8005},{name,counter},{limit,100}]},
  {applications,[kernel,stdlib,mnesia,erlmon_lib,gproc,msgpack,iso8583_erl]}]}.
