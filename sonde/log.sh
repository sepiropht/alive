#!/bin/bash

LOG_DIR="../"
DB_FILE="$LOG_DIR/top_processes.db"
INTERVAL=60  # in seconds

mkdir -p "$LOG_DIR"


# Create SQLite table if it doesn't exist
sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS top_processes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    total_cpu REAL,
    total_mem INTEGER,
    total_swap INTEGER,
    pid INTEGER,
    command TEXT,
    cpu REAL,
    cpu_percent REAL,
    mem REAL,
    mem_percent REAL,
    etime TEXT,
    swap INTEGER,
    swap_percent REAL
);
EOF

while true; do
	    TIMESTAMP=$(date +%s)

	        # Get the top 5 processes by CPU usage
		    CPU_OUTPUT=$(ps -eo pid,comm,%cpu,%mem,etime --sort=-%cpu | head -n 6)
		        
		        # Get the top 5 processes by RAM usage
			    MEM_OUTPUT=$(ps -eo pid,comm,%cpu,%mem,etime --sort=-%mem | head -n 6)
			        
			        # Get the top 5 processes by Swap usage using smem
				    SWAP_OUTPUT=$(smem -c "pid name swap" --no-header | sort -rk3 | head -n 5)

				        # Access host system information from /proc
					    TOTAL_CPU=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
					        TOTAL_MEM=$(grep 'MemTotal' /proc/meminfo | awk '{print $2}')
						    TOTAL_SWAP=$(grep 'SwapTotal' /proc/meminfo | awk '{print $2}')

						        # Insert data into SQLite table
							    sqlite3 "$DB_FILE" <<EOF
    INSERT INTO top_processes (timestamp, total_cpu, total_mem, total_swap, pid, command, cpu, cpu_percent, mem, mem_percent, etime, swap, swap_percent)
    VALUES ($TIMESTAMP, $TOTAL_CPU, $TOTAL_MEM, $TOTAL_SWAP, $CPU_OUTPUT, $MEM_OUTPUT, $SWAP_OUTPUT);
    EOF

    sleep "$INTERVAL"
done
done
done
