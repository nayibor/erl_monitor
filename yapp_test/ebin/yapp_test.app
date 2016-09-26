{application, yapp_test,
 [{description,"Yap Test"},
  {vsn,"0.1.0"},
  {modules,[myapp_auth,myapp_dash_layout,myapp_dashboard,myapp_dashboard_old,myapp_user,myapp_auth,myapp_links,myapp_roles]},
  {env, [
         {yapp_appmods,
			[
				{"auth",myapp_auth},{"dashboard",myapp_dashboard},{"user",myapp_user},{"links",myapp_links},
				{"roles",myapp_roles},{"sites",myapp_sites},{"inst",myapp_inst},{"temp",myapp_temp},{"rules",myapp_rules},
				{"websock",myapp_websocket}
			]
		 }
        ]
  },
  {registered, []},
  {applications,[kernel, stdlib, yaws, yapp,yapp_test_lib,yapp_test_sock,msgpack,gproc]}]}.
