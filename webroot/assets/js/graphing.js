var chart;
var chartData = [];
var chartCursor;



$(document).ready(function() {
	$("#makeGraph").on("click",function(){
		var data = {};
		data.d = {};
		data.d.token = $("#gettoken").val();
		data.d.loglevel = $("#getloglevel").val();
		data.d.interval = $("#getinterval").val();
		data.d.params = {};
		if($("#param1_n").val().length > 0 && $("#param1_v").val().length > 0) {
			data.d.params[$("#param1_n").val()] = $("#param1_v").val()
		}
		if($("#param2_n").val().length > 0 && $("#param2_v").val().length > 0) {
			data.d.params[$("#param2_n").val()] = $("#param2_v").val()
		}
		if($("#param3_n").val().length > 0 && $("#param3_v").val().length > 0) {
			data.d.params[$("#param3_n").val()] = $("#param3_v").val()
		}
// 		console.log(data);
		
		$.ajax({
			type: "POST",
			url: "/api/v1/graph",
			headers:{"Authorization":"Bearer "+headerToken},
			data: JSON.stringify(data),
			contentType: "application/json",
			dataType: "json"
		})
		.done(function(d){
			chartData = [];
			d["d"].map(function(obj){
				chartData.push({
					date: obj.x,
					y: Number(obj.y)
				});
			});
			makeChartNow();
		});
	
		return false;
	});
	$("#saveGraph").on("click",function(){
		return false;
	});
});

// this method is called when chart is first inited as we listen for "dataUpdated" event
function zoomChart() {
	// different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
//	chart.zoomToIndexes(chartData.length - 40, chartData.length - 1);
	chart.zoomToIndexes(0, chartData.length);
}

// changes cursor mode from pan to select
function setPanSelect() {
	if (document.getElementById("rb1").checked) {
		chartCursor.pan = false;
		chartCursor.zoomable = true;
	} else {
		chartCursor.pan = true;
	}
	chart.validateNow();
}
function makeChartNow() {
	// SERIAL CHART
	chart = new AmCharts.AmSerialChart();

	chart.dataProvider = chartData;
	chart.categoryField = "date";
	chart.balloon.bulletSize = 5;

	// listen for "dataUpdated" event (fired when chart is rendered) and call zoomChart method when it happens
	chart.addListener("dataUpdated", zoomChart);

	// AXES
	// category
	var categoryAxis = chart.categoryAxis;
	categoryAxis.parseDates = true; // as our data is date-based, we set parseDates to true
	categoryAxis.minPeriod = "DD"; // our data is daily, so we set minPeriod to DD
	categoryAxis.dashLength = 1;
	categoryAxis.minorGridEnabled = true;
	categoryAxis.twoLineMode = true;
	categoryAxis.dateFormats = [{
								period: 'fff',
								format: 'JJ:NN:SS'
								}, {
								period: 'ss',
								format: 'JJ:NN:SS'
								}, {
								period: 'mm',
								format: 'JJ:NN'
								}, {
								period: 'hh',
								format: 'JJ:NN'
								}, {
								period: 'DD',
								format: 'DD'
								}, {
								period: 'WW',
								format: 'DD'
								}, {
								period: 'MM',
								format: 'MMM'
								}, {
								period: 'YYYY',
								format: 'YYYY'
								}];

	categoryAxis.axisColor = "#DADADA";

	// value
	var valueAxis = new AmCharts.ValueAxis();
	valueAxis.axisAlpha = 0;
	valueAxis.dashLength = 1;
	chart.addValueAxis(valueAxis);

	// GRAPH
	var graph = new AmCharts.AmGraph();
	graph.title = "Perfect Stars";
	graph.valueField = "y";
	graph.bullet = "round";
	graph.bulletBorderColor = "#FFFFFF";
	graph.bulletBorderThickness = 2;
	graph.bulletBorderAlpha = 1;
	graph.lineThickness = 2;
	graph.lineColor = "#FFBB00";
	graph.hideBulletsCount = 50; // this makes the chart to hide bullets when there are more than 50 series in selection
	chart.addGraph(graph);

	// CURSOR
	chartCursor = new AmCharts.ChartCursor();
	chartCursor.cursorPosition = "mouse";
	chartCursor.pan = true; // set it to fals if you want the cursor to work in "select" mode
	chart.addChartCursor(chartCursor);

	// SCROLLBAR
	var chartScrollbar = new AmCharts.ChartScrollbar();
	chart.addChartScrollbar(chartScrollbar);

	chart.creditsPosition = "bottom-right";
	
	// WRITE
	chart.write("chartdiv");
	
}
