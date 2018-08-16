var express = require('express');
var router = express.Router();
require('dotenv').config();
var moment = require('moment');
var request = require('request');
const h1 = process.env.CASSANDRA_HOST1;
const h2 = process.env.CASSANDRA_HOST2;
const cassandra = require('cassandra-driver');
const campsitesClient = new cassandra.Client({ contactPoints: [h1, h2], keyspace: 'campsites' });
const stationsClient = new cassandra.Client({ contactPoints: [h1, h2], keyspace: 'weather_stations' });
const GOOGLE_MAPS_API_KEY = process.env.GOOGLE_MAPS_API_KEY;

function getDataFromRow(row, offsetFromUTC) {
  /**
   * Returns an object with temperature, and time with offset subtracted
   *
   * @param {Object} row - A row from the Cassandra response
   * @param {int} offsetFromUTC - The offset, in seconds, from UTC for the timezone
   * @returns {Object} - An object with temperature and time with offset subtracted
   */
  let time = moment.utc(row.calculation_time);
  let temp = degCtoDegF(row.temp);
  time.add(offsetFromUTC, "seconds");
  return {time: time.format("YYYY-MM-DD HH:mm"), temp: temp}
}

function degCtoDegF(degC) {
  return degC * 1.8 + 32;
}

router.post('/get_hist_campsite_weather', function(req, res, next) {
  // Returns the weather for a campsite at a given date/time
  var facilityId = parseInt(req.body.facilityId);
  
  var month = req.body.month;
  var day = req.body.day;
  var year = req.body.year;
  
  // Zero-padding for month and day
  if (month.length === 1) {
    month = "0" + month;
  }
  if (day.length === 1) {
    day = "0" + day;
  }

  var date = moment.utc(year + "-" + month + "-" + day);

  // Constructing query string for Google Maps API
  // Determines timezone offset from UTC, given a location and date
  // Date is needed to account for DST
  var baseURL = "https://maps.googleapis.com/maps/api/timezone/json?";
  var location = "location=" + req.body.lat + "," + req.body.lng;
  var key = "key=" + GOOGLE_MAPS_API_KEY;
  var timestamp = "timestamp=" + date.unix().toString();
  var url = baseURL + location + "&" + key + "&" + timestamp;

  request.get(url, (error, response, body) => {
    if (error) {
      next(error);
    }
    var timezoneResponse = JSON.parse(body);
    var offsetFromUTC = parseInt(timezoneResponse.dstOffset) + parseInt(timezoneResponse.rawOffset);

    // Data in database is stored in UTC. Data that should be displayed on
    // frontend is from midnight to midnight for the selected date, for the
    // appropriate timezone for the selected campsite, based on time of year
    // and location. Need to subtract out offset from UTC for database query
    date.subtract(offsetFromUTC, 'seconds');
    var milliseconds_start_date = date.unix() * 1000;
  
    // Getting the time, in milliseconds, that is 24 hours later
    var milliseconds_end_date = milliseconds_start_date + (24 * 60 * 60 * 1000);
    
    const query = "SELECT * FROM campsites.calculations WHERE campsite_id = ? "
      + "AND calculation_time >= ? "
      + "AND calculation_time < ?";
    
    campsitesClient.execute(query, [facilityId,
      milliseconds_start_date,
      milliseconds_end_date], {prepare: true})
    .then(result => {
      // Create an array of times and temperatures to send to the frontend,
      // for the given campsite
      var arrayLength = result.rows.length;
      var times = [];
      var temps = [];
      for (var i = 0; i < arrayLength; i++) {
        var dataFromRow = getDataFromRow(result.rows[i], offsetFromUTC);
        times.push(dataFromRow.time);
        temps.push(dataFromRow.temp);
      }
      var resultData = {times: times, temps: temps};
      res.json(resultData);
    })
    .catch(error => {
      next(error);
    });
  });
});

module.exports = router;
