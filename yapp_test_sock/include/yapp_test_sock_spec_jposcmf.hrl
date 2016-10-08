%%%
%%% @doc header file for specifications
%%%this will be used to get information about a specific data element in iso message
%%this format is the format used by jPOS Common Message Format based on iso8583 2003 standard
%%%except network manament messages/acquire reconciliation response messages
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
				2 	->{n,19,vl,2,<<"Pan">>};%%avail
				3 	->{n,6,fx,0,<<"Processing Code">>};%%avail
				4 	->{n,16,fx,0,<<"Amount Transaction">>};%%avail
				5 	->{n,16,fx,0,<<"Amount Settlement">>};%%avail
				6 	->{n,16,fx,0,<<"Amount, cardholder billing">>};%%avail
				7 	->{n,10,fx,0,<<"Transmission date & time MMDDhhmmss">>};%%avail
				8 	->{n,12,fx,0,<<"Amount, Cardholder billing fee">>};%%avail
				9 	->{n,8,fx,0,<<"Conversion rate, Settlement">>};
				10	->{n,8,fx,0,<<"Conversion rate, cardholder billing">>};
				11	->{n,12,fx,0,<<"System Trace Audit Number">>};%%avail
				12	->{n,14,fx,0,<<"Time, Local transaction (CCYYMMDDhhmmss)">>};%%avail
				13	->{n,6,fx,0,<<"Date, Local transaction (CCMMDD)">>};%%avail
				14	->{n,4,fx,0,<<"Date, Expiration YYMM">>};%%avail
				15	->{n,8,fx,0,<<"Settlement Date CCYYMMDD">>};%%avail
				16	->{n,4,fx,0,<<"Conversion Date MMDD">>};
				17	->{n,4,fx,0,<<"Date, Capture MMDD">>};%%avail
				18	->{an,140,vl,2,<<"Message Error Indicator">>};%%avail
				19	->{n,3,fx,0,<<"Country Code">>};
				20	->{n,3,fx,0,<<"Country Code/Pan Extended">>};
				21	->{an,21,fx,0,<<"Transaction life cycle ident data">>};%%avail
				22	->{hex,8,fx,0,<<"Pos Data Code">>};%%avail
				23	->{n,3,fx,0,<<"jCard Sequence Number">>};%%avail				
				24	->{n,3,fx,0,<<"Function Code">>};%%avail
				25	->{n,4,fx,0,<<"Message Reason Code">>};%%avail
				26	->{n,4,fx,0,<<"Card Acceptor Business Code">>};%%avail
				27	->{n,1,fx,0,<<"Approval Code">>};
				28	->{n,6,fx,0,<<"Reconciliation Date YYMMDD">>};
				29	->{n,3,fx,0,<<"Reconciliation Indicator">>};
				30	->{n,32,fx,0,<<"Amount Original">>};%%avail
				31	->{ans,99,vl,2,<<"Acquirer Reference Data">>};
				32	->{n,11,vl,2,<<"Acquirre Identification Code">>};%%avail
				33	->{n,11,vl,2,<<"Forwarding Identification Code">>};%%avail
				34	->{ns,28,vl,2,<<"Pan Extended">>};
				35	->{z,37,vl,2,<<"Track 2 Data">>};%%avail
				36	->{ns,104,vl,2,<<"Track 3 Data">>};
				37	->{an,12,fx,0,<<"Retrieval Reference Number">>};%%avail
				38	->{an,6,fx,0,<<"Approval Code">>};%%avail
				39	->{n,4,fx,0,<<"Response Code">>};%%avail
				40	->{n,3,fx,0,<<"Service Code">>};
				41	->{an,16,fx,0,<<"Terminal Id">>};%%avail
				42	->{an,35,vl,2,<<"Card Acceptor Identication Code">>};%%avail
				43	->{b,9999,vl,2,<<"Name/Location">>};%%avail
				44	->{ans,99,vl,2,<<"Additional Response Data">>};
				45	->{ans,76,vl,2,<<"Track 1 Data">>};%%avail
				46	->{ans,216,vl,2,<<"Amount/Fees">>};%%avail
				47	->{ans,255,vl,3,<<"Additional Data National">>};
				48	->{ans,255,vl,3,<<"Additional Data Private">>};	
				49	->{b,9999,vl,2,<<"Currency Code Transaction">>};%%avail
				50	->{aorn,3,fx,0,<<"Currency Code Reconciliaton">>};
				51	->{aorn,3,fx,0,<<"Currency Code Cardholder Billing">>};
				52	->{hex,8,fx,0,<<"Pin Data">>};%%avail
				53	->{b,48,vl,2,<<"Crypto Info">>};%%avail
				54	->{ans,126,vl,2,<<"aAmount Additional">>};%%avail
				55	->{b,255,vl,2,<<"Currency Code Cardholder Billing">>};
				56	->{n,41,vl,2,<<"Original Data Elements">>};%%avail
				57	->{n,3,fx,0,<<"Authorization Life Cycle Code">>};
				58	->{n,11,vl,2,<<"Authorization Agent Inst Id Code">>};
				59	->{ans,999,vl,2,<<"Transport Code">>};%%avail
				60	->{ans,255,vl,3,<<"Reserved For Nation Use">>};
				61	->{ans,255,vl,3,<<"Reserved For Nation Use">>};
				62	->{ans,255,vl,3,<<"Reserved For Nation Use">>};
				63	->{ans,999,vl,2,<<"Reserved For Nation Use">>};%%avail
				64	->{hex,8,fx,0,<<"Mac Data">>};
				65	->{t,8,fx,0,<<"Reserved for Iso Use">>};
				66	->{ans,204,vl,2,<<"Amount Original Fees">>};	
				67	->{n,2,fx,0,<<"Extended Payment Data">>};				
				68	->{a,9,fx,0,<<"Terminal Batch Number">>};%%avail				
				69	->{n,3,fx,0,<<"Country Code,Settlement Institution">>};				
				70	->{n,3,fx,0,<<"Country Code,Authorizing Agent  Institution">>};				
				71	->{n,8,fx,0,<<"Message Number">>};				
				72	->{b,9999,vl,2,<<"Data Record">>};%%avail				
				73	->{n,6,fx,0,<<"Date Action YYMMDD">>};				
				74	->{n,78,fx,0,<<"Recon Data primary">>};%%avail
				75	->{n,10,fx,0,<<"Credits Reversal Number">>};				
				76	->{n,10,fx,0,<<"Debits Number">>};				
				77	->{n,10,fx,0,<<"Debits Reversal Number">>};				
				78	->{n,10,fx,0,<<"Transfer Number">>};				
				79	->{n,10,fx,0,<<"Transfer Reversal Number">>};				
				80	->{n,10,fx,0,<<"Enquiries Number">>};				
				81	->{n,10,fx,0,<<"Authorizations Number">>};				
				82	->{n,10,fx,0,<<"Enquiries Reversal Number">>};				
				83	->{n,10,fx,0,<<"Payments Number">>};				
				84	->{n,10,fx,0,<<"Payments Reversal Number">>};				
				85	->{n,10,fx,0,<<"Fee Collection Number">>};				
				86	->{n,16,fx,0,<<"Credits Amount">>};				
				87	->{n,16,fx,0,<<"Credits Reversal Amount">>};				
				88	->{n,16,fx,0,<<"Debits Amount">>};				
				89	->{n,16,fx,0,<<"Debits Reversal Amount">>};				
				90	->{n,10,fx,0,<<"Authrization Reversal Number">>};				
				91	->{n,3,fx,0,<<"Country Code.Transaction Destination Institution">>};				
				92	->{n,3,fx,0,<<"Country Code.Transaction Originator Institution">>};				
				93	->{n,11,vl,2,<<"Transaction Destination Institution Id Code">>};				
				94	->{n,11,vl,2,<<"Transaction Originator Institution Id Code">>};				
				95	->{ans,99,vl,2,<<"Transaction Originator Institution Id Code">>};				
				96	->{b,255,vl,2,<<"Key Management Data">>};				
				97	->{n,21,fx,0,<<"Amount Net Reconciliation">>};	%%avail			
				98	->{ans,25,fx,0,<<"Third Party Information">>};				
				99	->{an,11,vl,2,<<"Settlement Instituition Id">>};				
				100	->{n,11,vl,2,<<"Receiving Instituition Id">>};	%%avail			
				101	->{ans,99,vl,2,<<"File Name">>};	%%avail			
				102	->{ans,28,vl,2,<<"Account Number">>};%%avail				
				103	->{ans,28,vl,2,<<"Account Number 2">>};	%%avail			
				104	->{ans,100,vl,2,<<"Transaction Description">>};				
				105	->{n,16,fx,0,<<"Credits ChargeBack Amount">>};				
				106	->{n,16,fx,0,<<"Debits ChargeBack Amount">>};				
				107	->{n,10,fx,0,<<"Credits Chargeback Number">>};				
				108	->{n,10,fx,0,<<"Debits Chargeback Number">>};				
				109	->{ans,84,vl,2,<<"Credits Fee Amount">>};				
				110	->{ans,84,vl,2,<<"Debits Fee Amount">>};				
				111	->{ans,9999,vl,2,<<"Reserved For Iso Use">>};%%avail				
				112	->{ans,9999,vl,2,<<"Reserved For Iso Use">>};%%avail				
				113	->{ans,9999,vl,2,<<"Reserved For Iso Use">>};%%avail				
				114	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				115	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				116	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				117	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				118	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				119	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				120	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				121	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				122	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				123	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				124	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				125	->{ans,255,vl,3,<<"Reserved For Iso Use">>};				
				126	->{ans,255,vl,3,<<"Reserved For Iso Use">>}				
							
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
