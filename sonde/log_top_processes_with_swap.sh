#!/bin/bash

LOG_DIR="/database"
DB_FILE="$LOG_DIR/top_processes.db"
INTERVAL=20  # in seconds

mkdir -p "$LOG_DIR"

# Create SQLite tables if they don't exist
sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS top_processes_cpu (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    pid INTEGER,
    command TEXT,
    cpu REAL,
    mem REAL
);

CREATE TABLE IF NOT EXISTS top_processes_mem (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    pid INTEGER,
    command TEXT,
    cpu REAL,
    mem REAL
);

CREATE TABLE IF NOT EXISTS total_consumption (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    cpu_total REAL,
    mem_total REAL,
    swap_total REAL
);
EOF

while true; do
    TIMESTAMP=$(date +%s)
    
    # Get the top 20 processes by CPU usage
    CPU_OUTPUT=$(ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10 | tail -n +9)

    for row in "$CPU_OUTPUT"; do
        pid=$(echo $row | awk '{print $1}')
        command=$(echo $row | awk '{print $2}')
        cpu=$(echo $row | awk '{print $3}')
        mem=$(echo $row | awk '{print $4}')

        sqlite3 "$DB_FILE" <<EOF
INSERT INTO top_processes_cpu (timestamp, pid, command, cpu, mem)
VALUES ($TIMESTAMP, $pid, '$command', $cpu, $mem);
EOF
    done

    # Get the top 20 processes by memory usage
    MEM_OUTPUT=$(ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 10 | tail -n +9)

    for row in "$MEM_OUTPUT"; do
        pid=$(echo $row | awk '{print $1}')
        command=$(echo $row | awk '{print $2}')
        cpu=$(echo $row | awk '{print $3}')
        mem=$(echo $row | awk '{print $4}')

        sqlite3 "$DB_FILE" <<EOF
INSERT INTO top_processes_mem (timestamp, pid, command, cpu, mem)
VALUES ($TIMESTAMP, $pid, '$command', $cpu, $mem);
EOF
    done

    # Get the total CPU, memory, and swap consumption
    TOTAL_CPU=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
    TOTAL_MEM=$(free | awk '/Mem/{print $3}')
    TOTAL_SWAP=$(free | awk '/Swap/{print $3}')

    # Insert data into the total_consumption table
    sqlite3 "$DB_FILE" <<EOF
INSERT INTO total_consumption (timestamp, cpu_total, mem_total, swap_total)
VALUES ($TIMESTAMP, $TOTAL_CPU, $TOTAL_MEM, $TOTAL_SWAP);
EOF

    sleep "$INTERVAL"
done
