{application, erlmon_lib,
 [{description,"Library File for Erl Monitor Web Application/Transaction Server"},
  {vsn,"0.1.0"},
  {modules,[yapp_test_lib,yapp_test_lib_dirtyproc,yapp_test_lib_util,yapp_test_lib_sup,yapp_test_lib_usermod,yapp_test_lib_isoproc,yapp_test_lib_rules,yapp_test_lib_temp,yapp_test_lib_smtpclient]},
  {registered, []},
  {env,[
			{
				mail_settings,
					[
						{host,"smtp.gmail.com"},
						{username,"erltest010101@gmail.com"},
						{password,"2,Pb<5RUwc72/[q|J)f!X"},
						{from_email_address,"erltest010101.com"}
					]
			}
		]
   },
  {applications,[kernel,stdlib,mnesia,erlpass,gen_smtp]}]}.
