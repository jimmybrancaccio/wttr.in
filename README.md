*wttr.in — the right way to ~check~ `curl` the weather!*

## Important Notes

This is a fork of [wttr.in](https://github.com/chubin/wttr.in). You can find usage instructions in that repository.

---

wttr.in is a console-oriented weather forecast service that supports various information
representation methods like terminal-oriented ANSI-sequences for console HTTP clients
(curl, httpie, or wget), HTML for web browsers, or PNG for graphical viewers.

Originally started as a small project, a wrapper for [wego](https://github.com/schachmat/wego),
intended to demonstrate the power of the console-oriented services,
*wttr.in* became a popular weather reporting service, handling tens of millions[¹](#wttrin-usage-stats) of queries daily.

You can see it running here: [wttr.in](https://wttr.in).

[Documentation](https://wttr.in/:help) | [Usage](https://github.com/chubin/wttr.in#usage) | [One-line output](https://github.com/chubin/wttr.in#one-line-output) | [Data-rich output format](https://github.com/chubin/wttr.in#data-rich-output-format-v2) | [Map view](https://github.com/chubin/wttr.in#map-view-v3) | [Output formats](https://github.com/chubin/wttr.in#different-output-formats) | [Moon phases](https://github.com/chubin/wttr.in#moon-phases) | [Internationalization](https://github.com/chubin/wttr.in#internationalization-and-localization) | [Installation](https://github.com/chubin/wttr.in#installation)



## Self-Hosted Installation

### Installation via Docker

**This is working as of 2026-03-05.**

1. Install Docker on the system which you intend to host your wttr instance on.
2. Set up your file and directory struture. The following is how I've set up things myself, you do not need to do the same, but make sure you set the environment variables accordingly.
    ```
    Docker Compose Directory: /home/username/.docker/compose
    Data Directory: /home/username/.docker/data/wttr
    Logs Directory: /home/username/.docker/logs/wttr
    ```
3. If you would like IP2Location which is optional, go to the [IP2Location website](https://www.ip2location.io) and sign up for an account. They have a free plan which includes 50,000 API calls per month. Once signed up, grab your API key and save it into a new file at `/home/username/.docker/data/wttr/.ip2location.key`.
4. Grab a copy of `airports.dat` [from here](https://github.com/jpatokal/openflights/blob/master/data/airports.dat). I am not 100% if this is the correct file or data but was one of my search results when looking up the term, "airports.dat" and it looked right to me 🤷🏼‍♂️. Place the file at `/home/username/.docker/data/wttr/airports.dat`.
5. Sign up for a [MaxMind account](https://www.maxmind.com/en/create-account). You will need this to obtain the GeoLite2 database.
    * Once signed up, and logged in, you should be on your Account Summary page. You should see a sidebar on the left side of the page which a bunch of links. Atop the sidebar you should see Account (ID: xxxxxxx), where xxxxxxx is your account ID. Take note of that as we'll need it in a moment.
    * On the list of link in sidebar on the left, click on Manage License Keys. Create a new license key, I called mine wttr, but name it whatever you see fit. Copy the key and save it somewhere safe for the time being.
    * Navigate into the `/home/username/.docker/data/wttr` directory and run the following command. Make sure to set the user and password value correctly. The password value will be your license key.
        ```console
        wget -S --user=xxxxxxx --password=your-max-mind-license-key -O geolite2.tar.gz 'https://download.maxmind.com/geoip/databases/GeoLite2-City/download?suffix=tar.gz'
        ```
    * Uncompress the file using `tar zxvf geolite2.tar.gz`. I believe this will create a new directory with the `GeoLite2-City.mmdb` file in it. Just move the file up one directory into the `data` directory like such - `cp -va GeoLite2-City_20260303/GeoLite2-City.mmdb .` Please note the name of the directory that is created after uncompressing the `geolite2.tar.gz` file will likely not be named `GeoLite2-City_20260303` but will be very similar. It looks like MaxMind just appends the date of download to the end of the directory name. In my case, I downloaded the GeoLite2 database on February 3, 2026, hence the compressed filename being appended with `20260303`. At this point you should have `/home/username/.docker/data/wttr/GeoLite2-City.mmdb`.
6. Now you'll need to [sign up for a WorldWeatherOnline](https://www.worldweatheronline.com/weather-api/signup.aspx) account and get an API key from them.
    * Once you've signed up and logged in, go to to the [My Account page](https://www.worldweatheronline.com/weather-api/my/). You should see a section on that page to create a Premium API key, so go ahead and do so. Take note of it and save it somewhere safe.  
    * Create a new file at `/home/username/.docker/data/wttr/.wwo.key` and put your key into that file.  
    * Next create a `.wegorc` file. I've stored this in my `/home/username/.docker/data/wttr` directory (full path `/home/username/.docker/data/wttr/.wegorc`). The `City` parameter in the `.wegorc` file is ignored. The other parameters aside from `APIKey` may be ignored as well, I haven't tested them. Put your World Weather Online API key into the `APIKey` value field, replacing `00XXXXXXXXXXXXXXXXXXXXXXXXXXX`.
        ```json
        {
            "APIKey": "00XXXXXXXXXXXXXXXXXXXXXXXXXXX",
            "City": "London",
            "Numdays": 3,
            "Imperial": false,
            "Lang": "en"
        }
        ```
7. At this point your files and directories should look something like this:
    ```console
    jimmy@myserver:~/.docker/data/wttr$ ls -la

    total 62732
    drwxrwxr-x 2 jimmy jimmy     4096 Mar  4 19:17 .
    drwxr-xr-x 8 jimmy jimmy     4096 Mar  3 19:58 ..
    -rw-r--r-- 1 jimmy jimmy  1127225 Mar  3 18:00 airports.dat
    -rw-r--r-- 1 jimmy jimmy 63085331 Mar  3 02:38 GeoLite2-City.mmdb
    -rw-r--r-- 1 jimmy jimmy       33 Mar  3 17:57 .ip2location.key
    -rw-r--r-- 1 jimmy jimmy      133 Mar  4 19:17 .wegorc
    -rw-r--r-- 1 jimmy jimmy       31 Mar  3 18:06 .wwo.key
    ```
8. Now it's time to build your Docker container. First `git clone` this repository wherever you keep your Git repositories. For me that's in `/home/username/Developer/github.com/git-repo-author-name/` or in this case `/home/user/Developer/github.com/jimmybrancaccio/`.
    * Once the repository has been cloned, run the command: `docker build wttr:latest .`. 
9. After the image has been build you can use Docker Compose or `docker run` to start up the container. I use Docker Compose myself, but you should be able to easily convert the following into a `docker run` command if you wish. I also have an external Docker network named `production` I created prior to this so you may need to adjust accordingly.
    ```yaml
    services:
    app:
        image: wttr:latest
        container_name: wttr
        hostname: wttr
        environment:
        - WTTR_MYDIR=${WTTR_MYDIR}
        - WTTR_GEOLITE=${WTTR_GEOLITE}
        - WTTR_WEGO=${WTTR_WEGO}
        - WTTR_LISTEN_HOST=${WTTR_LISTEN_HOST}
        - WTTR_LISTEN_PORT=${WTTR_LISTEN_PORT}
        - DEFAULT_LOCATION=${DEFAULT_LOCATION}
        - MY_EXTERNAL_IP=${MY_EXTERNAL_IP}
        - USE_IMPERIAL=${USE_IMPERIAL}
        volumes:
        - ${DOCKER_DATA_DIR}/wttr/.wegorc:/root/.wegorc
        - ${DOCKER_DATA_DIR}/wttr/.ip2location.key:/root/.ip2location.key
        - ${DOCKER_DATA_DIR}/wttr/airports.dat:/app/airports.dat
        - ${DOCKER_DATA_DIR}/wttr/GeoLite2-City.mmdb:/app/GeoLite2-City.mmdb
        - ${DOCKER_DATA_DIR}/wttr/.wwo.key:/root/.wwo.key
        - ${DOCKER_LOGS_DIR}/wttr:/app/logs
        ports:
        - 8002:8002
        networks:
        - production
        restart: unless-stopped
    
    networks:
        production:
            external: true
    ```
    You can use either an `.env` file with the environment values or put them right into your Docker Compose file. In the example above, I have an `.env` file where I put my environment variables.  
    * I have set `DOCKER_DATA_DIR` to `/home/username/.docker/data`.
    * I have set `DOCKER_LOGS_DIR` to `/home/username/docker/logs`.
    * I have set `WTTR_MYDIR` to `/app`.
    * I have set `WTTR_GEOLITE` to `/app/GeoLite2-City.mmdb`.
    * I have set `WTTR_WEGO` to `/app/go/bin/wego`.
    * I have set `WTTR_LISTEN_HOST` to `0.0.0.0`.
    * I have set `WTTR_LISTEN_PORT` to `8002`.
    * I have set `DEFAULT_LOCATION` to `Houston`.
    * I have set `MY_EXTERNAL_IP` to my external IP address as shown at [IPChicken](https://ipchicken.com).
    * I have set `USE_IMPERIAL` to `true` since I am in the USA. It's likely you'll want to set it to `false` if you're not in the USA.
10. Once you've configured your Docker Compose you can start it up with `docker compose up -d`.

### Configure the HTTP-frontend service

It's recommended that you also configure the web server that will be used to access the service. The following is an example using Nginx, though I use Traefik myself.

```nginx
server {
	listen [::]:80;
	server_name  wttr.in *.wttr.in;
	access_log  /var/log/nginx/wttr.in-access.log  main;
	error_log  /var/log/nginx/wttr.in-error.log;

	location / {
	    proxy_pass         http://127.0.0.1:8002;

	    proxy_set_header   Host             $host;
	    proxy_set_header   X-Real-IP        $remote_addr;
	    proxy_set_header   X-Forwarded-For  $remote_addr;

	    client_max_body_size       10m;
	    client_body_buffer_size    128k;

	    proxy_connect_timeout      90;
	    proxy_send_timeout         90;
	    proxy_read_timeout         90;

	    proxy_buffer_size          4k;
	    proxy_buffers              4 32k;
	    proxy_busy_buffers_size    64k;
	    proxy_temp_file_write_size 64k;

	    expires                    off;
	}
}
```
