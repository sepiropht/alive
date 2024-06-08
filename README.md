# Alive

This script monitors the top CPU and memory-consuming processes on the host system and stores the data in an SQLite database. It can be run either directly on the host system or inside a Docker container.

## Run the agent

#### 1. Build the Docker Image

Clone this repo and build the docker image

```bash
$ cd sonde
```

```bash
$ docker build -t top-processes-monitor .
```

#### 2. Run the Docker Container

1. Run the Docker container:

```bash
$ docker run -d --name top-monitor -v ./database:/database -v /proc/proc top-processes-monitor
```

This will start the container in detached mode with the name `top-monitor`.

#### SQLite Database

The SQLite database file (`top_processes.db`) will be stored in the specified directory (`database`) and will contain two tables.

## View data in web

A go app that read the sqlite database app, render a web view to show you the data

1. Build the Docker image:

```bash
# go back to the root

 $ cd ../
```

```bash
$ docker build -t my-go-app .
```

2. Run the go app

```bash
$ docker run -d -p 8080:8080 --name my-go-app-container -v ./database:/database my-go-app
```
