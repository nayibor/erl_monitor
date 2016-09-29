%%%
%%% @doc header file for specifications
%%%this will be used to get information about a specific data element in iso message
%%%
%%% @end
%%% @copyright Nuku Ameyibor <nayibor@startmail.com>

-author("Nuku Ameyibor <nayibor@startmail.com>").
-github("https://bitbucket.com/nameyibor").
-license("Apache License 2.0").


%%
-define(SPEC(DataElem), 
		   case DataElem of
				1	->{hex,8,fx,0,<<"Secondary Bitmap">>};%%hex values have some differences in erlang
				2 	->{n,19,vl,2,<<"Pan">>};
				3 	->{n,6,fx,0,<<"Processing Code">>};
				4 	->{n,12,fx,0,<<"Amount Transaction">>};
				5 	->{n,12,fx,0,<<"Amount Settlement">>};
				6 	->{n,12,fx,0,<<"Amount, cardholder billing">>};
				7 	->{n,10,fx,0,<<"Transmission date & time MMDDhhmmss">>};
				8 	->{n,8,fx,0,<<"Amount, Cardholder billing fee">>};
				9 	->{n,8,fx,0,<<"Conversion rate, Settlement">>};
				10	->{n,8,fx,0,<<"Conversion rate, cardholder billing">>};
				11	->{n,6,fx,0,<<"System Trace Audit Number">>};
				12	->{n,12,fx,0,<<"Time, Local transaction (YYMMDDhhmmss)">>};
				13	->{n,4,fx,0,<<"Date, Local transaction (MMDD)">>};
				14	->{n,4,fx,0,<<"Date, Expiration YYMM">>};
				15	->{n,6,fx,0,<<"Settlement Date YYMMDD">>};
				16	->{n,4,fx,0,<<"Conversion Date MMDD">>};
				17	->{n,4,fx,0,<<"Date, Capture MMDD">>};
				18	->{n,4,fx,0,<<"Merchant Type">>};
				19	->{n,3,fx,0,<<"Country Code">>};
				20	->{n,3,fx,0,<<"Country Code/Pan Extended">>};
				21	->{n,3,fx,0,<<"Country Code/Forwarding Institution">>};
				22	->{an,12,fx,0,<<"Pos Data Code">>};
				23	->{n,3,fx,0,<<"Card Sequence Number">>};				
				24	->{n,3,fx,0,<<"Function Code">>};
				25	->{n,4,fx,0,<<"Message Reason Code">>};
				26	->{n,4,fx,0,<<"Card Acceptor Business Code">>};
				27	->{n,1,fx,0,<<"Approval Code">>};
				28	->{n,6,fx,0,<<"Reconciliation Date YYMMDD">>};
				29	->{n,3,fx,0,<<"Reconciliation Indicator">>};
				30	->{n,24,fx,0,<<"Amount Original">>};
				31	->{ans,99,vl,2,<<"Acquirer Reference Data">>};
				32	->{n,11,vl,2,<<"Acquirre Identification Code">>};
				33	->{n,11,vl,2,<<"Forwarding Identification Code">>};
				34	->{ns,28,vl,2,<<"Pan Extended">>};
				35	->{ns,37,vl,2,<<"Track 2 Data">>};
				36	->{ns,104,vl,2,<<"Track 3 Data">>};
				37	->{anp,12,fx,0,<<"Ritrieval Reference Number">>};
				38	->{anp,6,fx,0,<<"Approval Code">>};
				39	->{n,3,fx,0,<<"Response Code">>};
				40	->{n,3,fx,0,<<"Service Code">>};
				41	->{ans,8,fx,0,<<"Terminal Id">>};
				42	->{ans,15,fx,0,<<"Card Acceptor Identication Code">>};
				43	->{ans,99,vl,2,<<"Name/Location">>};
				44	->{ans,99,vl,2,<<"Additional Response Data">>};
				45	->{ans,76,vl,2,<<"Track 1 Data">>};
				46	->{ans,204,vl,2,<<"Amount/Fees">>};
				47	->{ans,255,vl,3,<<"Additional Data National">>};
				48	->{ans,255,vl,3,<<"Additional Data Private">>};	
				49	->{aorn,3,fx,0,<<"Currency Code Transaction">>};
				50	->{aorn,3,fx,0,<<"Currency Code Reconciliaton">>};
				51	->{aorn,3,fx,0,<<"Currency Code Cardholder Billing">>};
				52	->{hex,8,fx,0,<<"Pin Data">>};
				53	->{b,48,vl,2,<<"Crypto Info">>};
				54	->{ans,120,vl,2,<<"aAmount Additional">>};
				55	->{b,255,vl,2,<<"Currency Code Cardholder Billing">>};
				56	->{n,35,vl,2,<<"Original Data Elements">>};
				57	->{n,3,fx,0,<<"Authorization Life Cycle Code">>};
				58	->{n,11,vl,2,<<"Authorization Agent Inst Id Code">>};
				59	->{ans,255,vl,2,<<"Transport Code">>};
				60	->{ans,255,vl,3,<<"Reserved For Nation Use">>};
				61	->{ans,255,vl,3,<<"Reserved For Nation Use">>};
				62	->{ans,255,vl,3,<<"Reserved For Nation Use">>};
				63	->{ans,255,vl,3,<<"Reserved For Nation Use">>};
				64	->{hex,8,fx,0,<<"Mac Data">>}
			end 
		). 

%%calculate the data elements and their value 
%%will have to actually use a formual to get the values programmatically out of message
%%wont be too difficult but have to be careful about how i create the data elements 

%%to obtain value for particular data element you need(stub of how specification will be implemented )
%%check whether that data element exists
%%if exists get postion to start from 
%%atrributes of that data element to see how you will obtain data for it and calcullate value for next person in sequence 
%%foldr will be used but have to be careful about nature of fold
%%header file will have to be created with definitions for each fld and the attributes of that field value according to  a specification 
%%three main features of a data item are total length,fixed or variable,padding type,data type(numeric,binary,etc..)
%%lists:foldl(fun(X, Sum) -> X + Sum end, 0, [1,2,3,4,5]).

%%fld_010 problematic/differnt from real world --supposed to be Format: N 14 (YYYYMMDDhhmmss)
%%list of all fields and their spec for bp-sim
%%should be able to move various categories
