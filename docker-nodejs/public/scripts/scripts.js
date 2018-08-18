function queryWeatherAtMarker(marker, map, month, day, year) {
  let facilityId = marker.facilityId;
  let data = {facilityId: facilityId,
    lat: marker.getPosition().lat(),
    lng: marker.getPosition().lng(),
    month: month,
    day: day,
    year: year};

  $.ajax({
    type: "POST",
    url: "/api/get_hist_campsite_weather",
    data: data,
    success: function(resp) {
      let contentString = marker.contentString;

      // Add date to info window
      contentString += '<br /><h3 style="text-align:center">' + year.toString();
      contentString += '-' + month.toString() + '-' + day.toString() + '</h3>';
      contentString += '<br /><div id="chart-' + facilityId.toString() + '"></div>';

      // Get times and temperatures from backend response
      var times = resp.times;
      times.unshift('Time');
      var temps = resp.temps;
      temps.unshift('Temperature (F)');

      var infowindow = new google.maps.InfoWindow({
        content: contentString
      });

      // Generate time-series plot and bind to DOM when infoWindow opens
      google.maps.event.addListener(infowindow, 'domready', function() {
        var chart = c3.generate({
          bindto: '#chart-' + facilityId.toString(),
          size: {
            height: 240,
            width: 480
          },
          data: {
            x: 'Time',
            xFormat: '%Y-%m-%d %H:%M',
            columns: [times, temps]
          },
          axis: {
            x: {
                type: 'timeseries',
                tick: {format: '%H:%M'},
                label: {
                  text: 'Time',
                  position: 'outer-center'
                }
            },
            y: {
              label: {
                text: 'Temperature (F)',
                position: 'outer-middle'
              }
            }
          },
          legend: {
            hide: true
          },
          tooltip: {
            format: {
              value: function (value, ratio, id, index) {
                return value.toPrecision(3);
              }
            }
          }
        });
      });
      infowindow.open(map, marker);
    },
    error: function(resp) {
      let contentString = marker.contentString;
      var infowindow = new google.maps.InfoWindow({
        content: contentString
      });
      infowindow.open(map, marker);
    },
    dataType: "json"
  });
}

function initMap() {
  // Initialize the date picker
  $('#datetimepicker13').datetimepicker({
      defaultDate: "2016-01-24T19:00:00Z",
      inline: true,
      sideBySide: true,
      keepInvalid: false,
      format: "MM/dd/YYYY"
  });

  // Initialize map of campgrounds
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 3,
    center: {lat: 37.425713, lng: -122.1704554}
  });
  var campgrounds =  {};

  // Obtain campground locations
  function loadJSON(callback) {
    var xobj = new XMLHttpRequest();
    xobj.overrideMimeType("application/json");
    xobj.open('GET', '/campgrounds_info.json', true);
    xobj.onreadystatechange = function () {
          if (xobj.readyState == 4 && xobj.status == "200") {
            callback(xobj.responseText);
          }
    };
    xobj.send(null);
  }

  // Place map pins for each campground
  loadJSON(function(response) {
    // Parse JSON string into object
    campgrounds = JSON.parse(response);
    campgrounds = campgrounds.campgrounds;
    var markers = campgrounds.map(function(campground, i) {
      var contentString = "<h1>" + campground.name + "</h1><br />";
      contentString += "ID: " + campground.facilityId.toString() + "<br />";
      contentString += "Position: " + campground.position.lat.toPrecision(5) + ", ";
      contentString += campground.position.lng.toPrecision(5);

      // Create pin and store campground attributes within Marker object
      var marker = new google.maps.Marker({
        position: campground.position,
        map: map,
        name: campground.name,
        facilityId: campground.facilityId,
        contentString: contentString,
      });

      // Add event listener to open up info window and query backend for
      // weather data on click
      marker.addListener('click', function() {
        let date = $('#datetimepicker13').datetimepicker('date');

        // JS Date objects have months indexed from 0 (0 to 11)
        let month = date.month() + 1;
        let day = date.date();
        let year = date.year();
        queryWeatherAtMarker(marker, map, month, day, year);
      });

      return marker;
    });
    // Add a marker clusterer to manage the markers.
    var markerCluster = new MarkerClusterer(map, markers,
      {imagePath: '/markerclusterer/images/m'});
  });
}