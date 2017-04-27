var chart;
var chartData = [];
var chartCursor;
var graphOptions = {};

$(document).ready(function() {
	$("#makeGraph").on("click", function() {
		assembleData(function() {
			getData()
		});
		return false;
	});
	$("#saveGraph").on("click", function() {
		assembleData(function() {
			saveData()
		});
		return false;
	});
	$("#getgrapgconfig").on("change", function() {
		var graphID = Number($("#getgrapgconfig").val());
		if (graphID == 0) {
			return;
		}
	
		$.ajax({
			type: "GET",
			url: "/api/v1/graph/load/" + graphID,
			headers: {
				"Authorization": "Bearer " + headerToken
			},
			contentType: "application/json",
			dataType: "json"
			})
		.done(function(d) {
			//console.log(d)
			
			// set opts
			$("#gettoken").val(d["config"]["token"]);
			$("#getinterval").val(d["config"]["interval"]);
			var counter = 0;
			Object.keys(d["config"]["params"]).forEach(key => {
				counter += 1;
				$("#param"+counter+"_n").val(key);
				$("#param"+counter+"_v").val(d["config"]["params"][key]);
			});
			
			chartData = [];
			d[d["config"]["ref"]].map(function(obj) {
				chartData.push({
					date: obj.x,
					y: Number(obj.y)
				});
			});
		makeChartNow();
		});
	});
});
function getData() {
	$.ajax({
		type: "POST",
		url: "/api/v1/graph",
		headers: {
			"Authorization": "Bearer " + headerToken
		},
		data: JSON.stringify(graphOptions),
		contentType: "application/json",
		dataType: "json"
	})
	.done(function(d) {
		chartData = [];
		d["d"].map(function(obj) {
			chartData.push({
				date: obj.x,
				y: Number(obj.y)
			});
		});
		makeChartNow();
	});
}

function saveData() {
	var name = prompt("Please enter a name for this Graph Configuration", "");
	if (name != null) {
		graphOptions.d.ref = name;
		$.ajax({
			type: "POST",
			url: "/api/v1/graph/save",
			headers: {
				"Authorization": "Bearer " + headerToken
			},
			data: JSON.stringify(graphOptions),
			contentType: "application/json",
			dataType: "json"
		})
		.done(function(d) {
			alert("Graph configuration saved.");
		});
	}
}

function assembleData(func) {
	graphOptions = {};
	
	graphOptions.d = {};
	
	graphOptions.d.token = $("#gettoken").val();
	graphOptions.d.loglevel = $("#getloglevel").val();
	graphOptions.d.interval = $("#getinterval").val();
	graphOptions.d.params = {};
	
	if ($("#param1_n").val().length > 0 && $("#param1_v").val().length > 0) {
		graphOptions.d.params[$("#param1_n").val()] = $("#param1_v").val()
	}
	
	if ($("#param2_n").val().length > 0 && $("#param2_v").val().length > 0) {
		graphOptions.d.params[$("#param2_n").val()] = $("#param2_v").val()
	}
	
	if ($("#param3_n").val().length > 0 && $("#param3_v").val().length > 0) {
		graphOptions.d.params[$("#param3_n").val()] = $("#param3_v").val()
	}
	
	console.log("done1")
	console.log(graphOptions);
	console.log("done2");
	func();
}


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
		},
		{
			period: 'ss',
			format: 'JJ:NN:SS'
		},
		{
			period: 'mm',
			format: 'JJ:NN'
		},
		{
			period: 'hh',
			format: 'JJ:NN'
		},
		{
			period: 'DD',
			format: 'DD'
		},
		{
			period: 'WW',
			format: 'DD'
		},
		{
			period: 'MM',
			format: 'MMM'
		},
		{
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
	$(".chartops").show();
}
