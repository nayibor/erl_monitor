///file for statistics part

stats = {
	//bert_handler:new BertClass(),
		init:function(){
			// for making request so searches can be made for the 
			$("#search_stats_butt").live('click',function(e) {
				e.preventDefault();
				var link = $("#get_stats").val();
				stats.checkfields(link);
			}); 
			stats.add_binary_transport();
		}, 
			
			//for checking the date fields
		checkfields:function(link){
				_this=this;	
			var counter=0;
			$(".ca").each(function(){
				if(!(document.getElementById($(this).attr("id")).checkValidity())){
					$(this).css("border","solid #F44 2px"); 
					counter++;
				}else
				{
					$(this).css("border","solid grey 1px");       
				}
			}); 
			if(counter==0)
			{
				stats.get_stats(link); 
			}
			else{
				settings.show_message("Please Enter All Fields In Correct Format");
			}
			
		},
		
		//for performing the ajax to get the data about the stats using the date range 
		get_stats:function(link){
			var myChart = echarts.init(document.getElementById('main'));
			var data = "start_date="+$("#start_date").val()+"&end_date="+$("#end_date").val()+"&task_type="+$("#task_type").val();
			$.ajax({
	            url: link,
	            type:"GET",
	            dataType:'binary',
	            data:data,
	            processData: false,
	            beforeSend:function(){
						   myChart.showLoading(); 
			            },
	            success:function(data_resp) {
						var graph_data = [];
						var data = [];
						var uptime_data = [];
						var downtime_data = [];
						var data_task = [] ;
						var categories = [];
						var legend_data=[];
						var categories_data=[];
						var chart_data=[];
						var series_data =[];
						var color_series = [];
						var fileReader = new FileReader();
						fileReader.onloadend = function() {
						var arrayBuffer = this.result;
						var view = new Uint8Array(arrayBuffer);
						var jsdata = Inaka.Jem.decode(arrayBuffer);
						var title= "";
						//console.log("size of data ret is "+jsdata.length);
						//console.log(jsdata[0]);
						
						for (i = 0; i < jsdata.length ; i++)
						{
						//var value_list =jsdata[i][1][0][0]+"/"+jsdata[i][1][0][1]+"/"+jsdata[i][1][0][2];
						var value_list = jsdata[i][1][0][1]+"/"+jsdata[i][1][0][2];
						((categories.filter(function(x){return x==value_list})).length>0)? categories:categories.push(value_list);						
						data = (graph_data[jsdata[i][0]])? graph_data[jsdata[i][0]] : [];
						uptime_data = (data["uptime_data"])? data["uptime_data"]:[];
						downtime_data = (data["downtime_data"])? data["downtime_data"]:[];
						downtime_data.push(jsdata[i][3]);
						uptime_data.push(jsdata[i][4]);
						var data_task = [];
						data_task["uptime_data"] = uptime_data;
						data_task["downtime_data"] = downtime_data;
						graph_data[jsdata[i][0]]=data_task;
						}
						console.log(categories);
						console.log(graph_data); 
					    legend_data = Object.keys(graph_data);
					    var stack_num = 1;
						for (var key in graph_data) {
						  if (graph_data.hasOwnProperty(key)) {	  
							  if($("#up_down").val()=="uptime"){
							  series_data.push({name:key,type:'bar',/*stack:stack_num,**/data:graph_data[key]['uptime_data']});
							  title="Uptime Percentage";
						  }else if($("#up_down").val()=="downtime"){
						    series_data.push({name:key,type:'bar',/*stack:stack_num,**/data:graph_data[key]['downtime_data']});
							  title="Downtime In Seconds";
					  } 
							 (stack_num<3)? stack_num++:stack_num=1;
						  }
						}
						/**
						console.log("finfal data is \n\n\n");
						console.log("\ncategories is ");
						console.log(categories.reverse());
						console.log("\nlegend is ");
						console.log(legend_data);
						console.log("\nseries data is ");
						console.log(series_data);
						**/
						//for color calculation
						//var hStep = Math.round(300 / (legend_data.length - 1));
						//for (var i = 0; i < legend_data.length; i++) {
						//color_series.push(echarts.color.modifyHSL('#5A94DF', hStep * i));    
				//	}
						color_series=
						[ '#000000','#993300','#333300','#003300','#003366','#000080', 	    	  	    
							'#800000','#FF6600','#808000','#008000','#008080','#0000FF', 	    		    
							'#FF0000','#FF9900','#99CC00','#339966','#33CCCC','#3366FF', 	    	 	    
							'#FF00FF','#FFCC00','#FFFF00','#00FF00','#00FFFF','#00CCFF', 	    	    
							'#FF99CC','#FFCC99','#FFFF99','#CCFFCC','#CCFFFF','#99CCFF'
						];
						//console.log(legend_data);
						//console.log(color_series);
						
						chart_data["color"]=color_series;
						chart_data["categories"]=categories.reverse();
						chart_data["legend"]=legend_data;
						chart_data["series_data"]=series_data;
						chart_data["title"]=title;
						stats.create_chart(myChart,chart_data);
					
						};
						fileReader.readAsArrayBuffer(data_resp);						
						
	       
	            },
	            error:function(Data){
	               settings.enable_okbutt_mgdialg();
	               settings.show_message("Error<br>"+"Please Try Again");      
	            }
	        }); 		
		},
		
		
		//this is for creating echarts
		create_chart:function(myChart,chart_data){
		     myChart.hideLoading();
		     
        // specify chart configuration item and data
			 var option = {
				 //color:chart_data["color"],
	            title: {
	                text: chart_data["title"],
	                show:false
	            },
	            animationEasing:"elasticOut",
	           tooltip : {
			        trigger: 'axis',
			        axisPointer : {           
			            type : 'shadow'    
			        }
			    },
			     toolbox:{
					show : true,
					feature :{
					 magicType : {show: true, type: ['line', 'bar']},
					restore : {show: true},
					saveAsImage : {show: true}
				}
			},
			   grid: {
					top:'20%',
			        left: '0%',
			        right: '0%',
			        bottom: '0%',
			        containLabel: true
			    },
	            legend: {
	                data:chart_data["legend"],
	                zlevel:9999,
	                left:"0%"
	            },
	             xAxis : [
			        {
			            type : 'category',
			            data : chart_data["categories"],
			           // name : 'Date',
			            nameLocation : 'middle'
			        }
			    ],
	             yAxis : [
			        {
			            type : 'value',
			            //name : 'Uptime %',
			            nameLocation : 'middle',
			            splitLine:{
						show:false                
            }
			        }
			    ],
	            series: chart_data["series_data"]
	        };
			//final chart
	        myChart.setOption(option);	
			},
		//for adding binary transport so etf formatted erlang data can be sent to the client
		add_binary_transport:function(){
						 /**
			 *
			 * jquery.binarytransport.js
			 *
			 * @description. jQuery ajax transport for making binary data type requests.
			 * @version 1.0 
			 * @author Henry Algus <henryalgus@gmail.com>
			 *
			 */
// use this transport for "binary" data type
			$.ajaxTransport("+binary", function(options, originalOptions, jqXHR){
				    // check for conditions and support for blob / arraybuffer response type
				    if (window.FormData && ((options.dataType && (options.dataType == 'binary')) || (options.data && ((window.ArrayBuffer && options.data instanceof ArrayBuffer) || (window.Blob && options.data instanceof Blob)))))
				    {
				        return {
				            // create new XMLHttpRequest
				        send: function(headers, callback){
						// setup all variables
				        var xhr = new XMLHttpRequest(),
						url = options.url,
						type = options.type,
						async = options.async || true,
						// blob or arraybuffer. Default is blob
						dataType = options.responseType || "blob",
						data = options.data || null,
						username = options.username || null,
						password = options.password || null;
									
				        xhr.addEventListener('load', function(){
						var data = {};
						data[options.dataType] = xhr.response;
							// make callback and send data
						callback(xhr.status, xhr.statusText, data, xhr.getAllResponseHeaders());
				                });				
				        xhr.open(type, url, async, username, password);		
						// setup custom headers
						for (var i in headers ) {
							xhr.setRequestHeader(i, headers[i] );
						}	
				            xhr.responseType = dataType;
				            xhr.send(data);
				            },
				            abort: function(){
				                jqXHR.abort();
				            }
				        };
				    }
				});
				
			}
	}

		$(document).ready(function(){
					    
					    stats.init();  
					
		});


//https://ecomfe.github.io/echarts-examples/public/editor.html?c=bar-stack
//https://ecomfe.github.io/echarts-doc/public/en/tutorial.html#Customerized%20Chart%20Styles
//https://ecomfe.github.io/echarts-doc/public/en/option.html#yAxis
//https://developer.mozilla.org/en-US/docs/Web/JavaScript/Typed_arrays
//http://bert-rpc.org/

