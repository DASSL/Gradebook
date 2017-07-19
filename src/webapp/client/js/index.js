/*
index.js - Gradebook

Andrew Figueroa, Sean Murthy
Data Science & Systems Lab (DASSL), Western Connecticut State University

Copyright (c) 2017- DASSL. ALL RIGHTS RESERVED.
Licenced to others under CC 4.0 BY-NC-SA
https://creativecommons.org/licenses/by-nc-sa/4.0/

ALL ARTIFACTS PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

This JavaScript file provides the client-side JS code that is used by the index.html
page. The functionality provided includes accessing the REST API provided by the web
server component of the Gradebook webapp, along with providing interactivity for the
index.html webpage. 
*/


$(document).ready(function() {
	//load dropdown boxes
	$('select').material_select();
	
	
	//currently, getConnectionInfo() is being called with every API call, however,
	// this information will at a later point be stored as session login information
	$('#btnLogin').click(function() {
		resetYears();
		var connInfo = getConnectionInfo();
		popYears(connInfo);
	});
	
	$('#yearSelect').change(function() {
		resetSeasons();
		var connInfo = getConnectionInfo();
		var year = $('#yearSelect').val();
		popSeasons(connInfo, year);
	});
	
	$('#seasonSelect').change(function() {
		resetCourses();
		var connInfo = getConnectionInfo();
		var year = $('#yearSelect').val();
		var season = $('#seasonSelect').val();
		popCourses(connInfo, year, season);
	});
	
	$('#courseSelect').change(function() {
		resetSections();
		var connInfo = getConnectionInfo();
		var year = $('#yearSelect').val();
		var season = $('#seasonSelect').val();
		var course = $('#courseSelect').val();
		popSections(connInfo, year, season, course);
	});
	
	$('#sectionSelect').change(function() {
		var connInfo = getConnectionInfo();
		var sectionID = $('#sectionSelect').val();
		popAttendance(connInfo, sectionID);
	});
});

function getConnectionInfo() {
	var host = $('#host').val().trim();
	var port = $('#port').val().trim();
	var db = $('#database').val().trim();
	var uname = $('#user').val().trim();
	var pw =  $('#passwordBox').val().trim();
	var instId = $('#instructorId').val().trim();
	
	if (host === "" || port === "" || db === "" || uname === "" || instId === "" || pw === "")
	{
		alert('One or more fields are empty');
		return null;
	}
	
	pw = JSON.stringify(sjcl.encrypt('dassl2017', pw));
	
	var connInfo = {'host':host, 'port':port, 'database':db, 'user':uname, 'password':pw, 'instructorid':instId};
	return connInfo;
};

function popYears(connInfo) {
	var url = 'year';
	$.ajax(url, {
		dataType: 'json',
		data: connInfo,
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
			alert('Error while retrieving years - ensure connection information is correct');
			console.log(result);
		}
	});
};

function popSeasons(connInfo, year) {
	connInfo.year = year;
	var url = 'season';
	$.ajax(url, {
		dataType: 'json',
		data: connInfo,
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

function popCourses(connInfo, year, seasonorder) {
	connInfo.year = year;
	connInfo.seasonorder = seasonorder;
	var url = 'course';
	$.ajax(url, {
		dataType: 'json',
		data: connInfo,
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

function popSections(connInfo, year, seasonorder, coursenumber) {
	connInfo.year = year;
	connInfo.seasonorder = seasonorder;
	connInfo.coursenumber = coursenumber;
	var url = 'section';
	$.ajax(url, {
		dataType: 'json',
		data: connInfo,
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

function popAttendance(connInfo, sectionid) {
	connInfo.sectionid = sectionid;
	var url = 'attendance';
	$.ajax(url, {
		dataType: 'html',
		data: connInfo,
		success: function(result) {
			var attnTable = result;
			if (attnTable.substring(0, 7) === '<table>') {
				attnTable = '<table class="striped" style="display:block;margin:auto;overflow-x:auto">' + attnTable.substring(7);
			}
			else {
				console.log('WARN: Unable to style attendance table; first 7 chars did not match "<table>"');
			}
			$('#attendanceData').html(attnTable);
		},
		error: function(result) {
			alert('Error while retrieving attendance data');
			resetAttendance();
			console.log(result);
		}
	});
};

function resetYears() {
	var placeholder = '<option value="" disabled="true" selected="true">Choose year</option>';
	$('#yearSelect').html(placeholder); //remove years from dropdown
	$('#yearSelect').prop('disabled', true); //disable dropdown
	$('#yearSelect').material_select(); //reload dropdown
	resetSeasons();
};

function resetSeasons() {
	var placeholder = '<option value="" disabled="true" selected="true">Choose season</option>';
	$('#seasonSelect').html(placeholder); //remove years from dropdown
	$('#seasonSelect').prop('disabled', true); //disable dropdown
	$('#seasonSelect').material_select(); //reload dropdown
	resetCourses();
};

function resetCourses() {
	var placeholder = '<option value="" disabled="true" selected="true">Choose course</option>';
	$('#courseSelect').html(placeholder); //remove years from dropdown
	$('#courseSelect').prop('disabled', true); //disable dropdown
	$('#courseSelect').material_select(); //reload dropdown
	resetSections();
};

function resetSections() {
	var placeholder = '<option value="" disabled="true" selected="true">Choose section</option>';
	$('#sectionSelect').html(placeholder); //remove years from dropdown
	$('#sectionSelect').prop('disabled', true); //disable dropdown
	$('#sectionSelect').material_select(); //reload dropdown
	resetAttendance();
};

function resetAttendance() {
	$('#attendanceData').html('');
}
