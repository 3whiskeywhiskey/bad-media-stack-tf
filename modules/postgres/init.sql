CREATE ROLE radarr WITH LOGIN PASSWORD 'radarr';
CREATE DATABASE "radarr-main";
CREATE DATABASE "radarr-log";
GRANT ALL PRIVILEGES ON DATABASE "radarr-main" TO radarr;
GRANT ALL PRIVILEGES ON DATABASE "radarr-log" TO radarr;

CREATE ROLE sonarr WITH LOGIN PASSWORD 'sonarr';
CREATE DATABASE "sonarr-main";
CREATE DATABASE "sonarr-log";
GRANT ALL PRIVILEGES ON DATABASE "sonarr-main" TO sonarr;
GRANT ALL PRIVILEGES ON DATABASE "sonarr-log" TO sonarr;

CREATE ROLE lidarr WITH LOGIN PASSWORD 'lidarr';
CREATE DATABASE "lidarr-main";
CREATE DATABASE "lidarr-log";
GRANT ALL PRIVILEGES ON DATABASE "lidarr-main" TO lidarr;
GRANT ALL PRIVILEGES ON DATABASE "lidarr-log" TO lidarr;

CREATE ROLE readarr WITH LOGIN PASSWORD 'readarr';
CREATE DATABASE "readarr-main";
CREATE DATABASE "readarr-log";
GRANT ALL PRIVILEGES ON DATABASE "readarr-main" TO readarr;
GRANT ALL PRIVILEGES ON DATABASE "readarr-log" TO readarr;

CREATE ROLE prowlarr WITH LOGIN PASSWORD 'prowlarr';
CREATE DATABASE "prowlarr-main";
CREATE DATABASE "prowlarr-log";
GRANT ALL PRIVILEGES ON DATABASE "prowlarr-main" TO prowlarr;
GRANT ALL PRIVILEGES ON DATABASE "prowlarr-log" TO prowlarr;
