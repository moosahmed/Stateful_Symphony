CREATE KEYSPACE IF NOT EXISTS weather_stations WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };

CREATE KEYSPACE IF NOT EXISTS campsites WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 2 };

CREATE TABLE weather_stations.readings (
    station_id varchar,
    measurement_time timestamp,
    lat float,
    lon float,
    temp float,
    PRIMARY KEY (station_id, measurement_time)
) WITH CLUSTERING ORDER BY (measurement_time DESC);

CREATE TABLE campsites.calculations (
  campsite_id int,
  calculation_time timestamp,
  lat float,
  lon float,
  temp float,
  name varchar,
  PRIMARY KEY (campsite_id, calculation_time)
) WITH CLUSTERING ORDER BY (calculation_time DESC);