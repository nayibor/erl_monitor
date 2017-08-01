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
			var data = "start_date="+$("#start_date").val()+"&end_date="+$("#end_date").val();
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
						var fileReader = new FileReader();
						fileReader.onloadend = function() {
						var arrayBuffer = this.result;
						var view = new Uint8Array(arrayBuffer);
						var jsdata = Inaka.Jem.decode(arrayBuffer);
						console.log("size of data ret is "+jsdata.length);
						console.log(jsdata[0]); 
						//setTimeout(function() {                   
						stats.create_chart(myChart);
						//}, 2000);
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
		create_chart:function(myChart){
		 myChart.hideLoading();
		 /**
		 var option = {
			backgroundColor: '#2c343c',
			textStyle: {color: 'rgba(255, 255, 255, 0.3)'},
			visualMap: {
			    // hide visualMap component; use lightness mapping only
			    show: false,
			    // mapping with min value at 80
			    min: 80,
			    // mapping with max value at 600
			    max: 600,
			    inRange: {
			        // mapping lightness from 0 to 1
			        colorLightness: [0, 1]
			    }
			    },
		    series : [
		        {
		            name: 'Reference Page',
		            type: 'pie',
		            roseType: 'angle',
		            itemStyle: {
					  normal:{
						color: '#c23531',
						shadowBlur: 200,
						shadowColor: 'rgba(0, 0, 0, 0.5)'
						},
					labelLine: {
						normal: {
				        lineStyle: {
				            color: 'rgba(255, 255, 255, 0.3)'
							}
						}
					},
				   //
				   *  normal: {
				        // shadow size
				        shadowBlur: 200,
				        // horizontal offset of shadow
				        shadowOffsetX: 0,
				        // vertical offset of shadow
				        shadowOffsetY: 0,
				        // shadow color
				        shadowColor: 'rgba(0, 0, 0, 0.5)'
						}
					**
			
					},
		            radius: '55%',
		            data:[
		                {value:400, name:'Searching Engine'},
		                {value:335, name:'Direct'},
		                {value:310, name:'Email'},
		                {value:274, name:'Alliance Advertisement'},
		                {value:235, name:'Video Advertisement'}
					]
		        }
		    ]
		}
		*/
        // specify chart configuration item and data
		  var option = {
            title: {
                text: 'ECharts entry example'
            },
            tooltip: {},
            legend: {
                data:['Sales']
            },
            xAxis: {
                data: ["shirt","cardign","chiffon shirt","pants","heels","socks"]
            },
            yAxis: {},
            series: [{
                name: 'Sales',
                type: 'bar',
                data: [5, 20, 36, 10, 10, 20]
            }]
        };
		//this shows animation
        // use configuration item and data specified to show chart
        myChart.setOption(option);	
        myChart.on('click', function (params) {
		console.log(params);
		window.open('https://www.baidu.com/s?wd=' + encodeURIComponent(params.name));
		});
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


