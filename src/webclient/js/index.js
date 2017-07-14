/*
attendance.js - DASSL Gradebook

Andrew Figueroa, Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University

Copyright (c) 2017- DASSL. ALL RIGHTS RESERVED.
Licenced to others under CC 4.0 BY-NC-SA
https://creativecommons.org/licenses/by-nc-sa/4.0/

ALL ARTIFACTS PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
*/


$(document).ready(function() {
	//load downdown boxes
	$('select').material_select();
	
	
	//currently, getConnectionInfo() is being called with every API call, however,
	// this information will at a later point be stored as session login information
	$('#btnLogin').click(function() {
		var connInfo = getConnectionInfo();
		popYears(connInfo);
	});
	
	$('#yearSelect').change(function() {
		var connInfo = getConnectionInfo();
		var year = $('#yearSelect').val();
		popSeasons(connInfo, year);
	});
	
	$('#seasonSelect').change(function() {
		var connInfo = getConnectionInfo();
		var year = $('#yearSelect').val();
		var season = $('#seasonSelect').val();
		popCourses(connInfo, year, season);
	});
	
	$('#courseSelect').change(function() {
		var connInfo = getConnectionInfo();
		var year = $('#yearSelect').val();
		var season = $('#seasonSelect').val();
		var course = $('#courseSelect').val();
		popSections(connInfo, year, season, course);
	});
	
	$('#sectionSelect').change(function() {
		//fill attendance table
		alert('Attendance data is not ready');
	});
});

function getConnectionInfo(){
	var host = $('#host').val();
	var port = $('#port').val();
	var db = $('#database').val();
	var uname = $('#user').val();
	var pw =  $('#passwordBox').val();
	var instId = $('#instructorId').val();
	
	if (host === "" || port === "" || db === "" || uname === "" || instId === "" || pw === "")
	{
		alert('One or more fields are empty');
		return null;
	}
	
	pw = JSON.stringify(sjcl.encrypt('dassl2017', pw));
	
	var connInfo = {"host":host, "port":port, "db":db, "uname":uname, "pw":pw, "instId":instId};

	return connInfo;
};

function popYears(connInfo){
	var url = 'gradebook/year';
	$.ajax(url, {
		type: "GET",
		async: true,
		dataType: "json",
		data: {
			user: connInfo.uname,
			database: connInfo.db,
			password: connInfo.pw,
			host: connInfo.host,
			port: connInfo.port,
			instructorid: connInfo.instId
		},
		success: function(result) {
			var years = '<option value="" disabled="true" selected="true">Choose year</option>';
			for(var i = 0; i < result.years.length; i++) {
				years += '<option value="' + result.years[i] + '">' + result.years[i] + '</option>';
			}
			$('#yearSelect').html(years); //add years to dropdown
			$('#yearSelect').prop('disabled', false); //enable dropdown
			$('#yearSelect').material_select(); //reload dropdown
		},
		error: function(result) {
			alert('Error while retrieving years');
			console.log(result);
		}
	});
};

function popSeasons(connInfo, year){
	var url = 'gradebook/season';
	$.ajax(url, {
		type: "GET",
		async: true,
		dataType: "json",
		data: {
			user: connInfo.uname,
			database: connInfo.db,
			password: connInfo.pw,
			host: connInfo.host,
			port: connInfo.port,
			instructorid: connInfo.instId,
			year: year
		},
		success: function(result) {
			var seasons = '<option value="" disabled="true" selected="true">Choose season</option>';
			for(var i = 0; i < result.seasons.length; i++) {
				seasons += '<option value="' + result.seasons[i].seasonorder + '">' + result.seasons[i].seasonname + '</option>';
			}
			$('#seasonSelect').html(seasons); //add seasons to dropdown
			$('#seasonSelect').prop('disabled', false); //enable dropdown
			$('#seasonSelect').material_select(); //reload dropdown
		},
		error: function(result) {
			alert('Error while retrieving seasons');
			console.log(result);
		}
	});
};

function popCourses(connInfo, year, seasonorder){
	var url = 'gradebook/course'
	$.ajax(url, {
		type: "GET",
		async: true,
		dataType: "json",
		data: {
			user: connInfo.uname,
			database: connInfo.db,
			password: connInfo.pw,
			host: connInfo.host,
			port: connInfo.port,
			instructorid: connInfo.instId,
			year: year,
			seasonorder: seasonorder
		},
		success: function(result) {
			var courses = '<option value="" disabled="true" selected="true">Choose course</option>';
			for(var i = 0; i < result.courses.length; i++) {
				courses += '<option value="' + result.courses[i] + '">' + result.courses[i] + '</option>';
			}
			$('#courseSelect').html(courses); //add courses to dropdown
			$('#courseSelect').prop('disabled', false); //enable dropdown
			$('#courseSelect').material_select(); //reload dropdown
		},
		error: function(result) {
			alert('Error while retrieving courses');
			console.log(result);
		}
	});
};

function popSections(connInfo, year, seasonorder, coursenumber){
	var url = 'gradebook/section'
	$.ajax(url, {
		type: "GET",
		async: true,
		dataType: "json",
		data: {
			user: connInfo.uname,
			database: connInfo.db,
			password: connInfo.pw,
			host: connInfo.host,
			port: connInfo.port,
			instructorid: connInfo.instId,
			year: year,
			seasonorder: seasonorder,
			coursenumber: coursenumber
		},
		success: function(result) {
			var sections = '<option value="" disabled="true" selected="true">Choose section</option>';
			for (var i = 0; i < result.sections.length; i++) {
				sections += '<option value="' + result.sections[i].sectionid + '">' + result.sections[i].sectionnumber + '</option>';
			}
			$('#sectionSelect').html(sections); //add sections to dropdown
			$('#sectionSelect').prop('disabled', false); //enable dropdown
			$('#sectionSelect').material_select(); //reload dropdown
		},
		error: function(result) {
			alert('Error while retrieving sections');
			console.log(result);
		}
	});
};
