package main

import (
    "database/sql"
    "html/template"
    "log"
    "net/http"

    _ "github.com/mattn/go-sqlite3"
)

var tmpl = template.Must(template.New("index").Parse(`
<!DOCTYPE html>
<html>
<head>
    <title>Top Processes</title>
</head>
<body>
    <h1>Top Processes</h1>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Timestamp</th>
            <th>CPU</th>
            <th>Memory</th>
            <th>Swap</th>
        </tr>
        {{range .}}
        <tr>
            <td>{{.ID}}</td>
            <td>{{.Timestamp}}</td>
            <td>{{.CPU}}</td>
            <td>{{.Memory}}</td>
            <td>{{.Swap}}</td>
        </tr>
        {{end}}
    </table>
</body>
</html>
`))

type Process struct {
    ID        int
    Timestamp int64
    CPU       float64
    Memory    float64
    Swap      int
}

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        db, err := sql.Open("sqlite3", "/database/top_processes.db")
        if err != nil {
            http.Error(w, "Error opening database", http.StatusInternalServerError)
            return
        }
        defer db.Close()

        rows, err := db.Query("SELECT * FROM top_processes ORDER BY mem DESC LIMIT 1 OFFSET 9")
        if err != nil {
            http.Error(w, "Error querying database", http.StatusInternalServerError)
            return
        }
        defer rows.Close()

        var processes []Process
        for rows.Next() {
            var p Process
            if err := rows.Scan(&p.ID, &p.Timestamp, &p.CPU, &p.Memory, &p.Swap); err != nil {
                http.Error(w, "Error scanning row", http.StatusInternalServerError)
                return
            }
            processes = append(processes, p)
        }
        if err := rows.Err(); err != nil {
            http.Error(w, "Error iterating over rows", http.StatusInternalServerError)
            return
        }

        if err := tmpl.Execute(w, processes); err != nil {
            http.Error(w, "Error executing template", http.StatusInternalServerError)
            return
        }
    })

    log.Fatal(http.ListenAndServe(":8080", nil))
}
