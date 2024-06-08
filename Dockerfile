# Use the official lightweight Golang image as the builder
FROM golang:alpine AS builder

# Install git to fetch dependencies
RUN apk update && apk add --no-cache git

# Set the working directory inside the container
WORKDIR /go/src/app

# Initialize the Go module
RUN go mod init github.com/yourusername/yourproject

# Copy the source code into the container
COPY . .

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod tidy

# Build the Go application
RUN go build -o app .

# Use a minimal base image to run the built Go application
FROM alpine:latest

# Install certificates and SQLite (if needed for your app)
RUN apk add --no-cache ca-certificates sqlite

# Set the working directory inside the container
WORKDIR /root/

# Copy the binary from the builder stage
COPY --from=builder /go/src/app/app .

# Expose port 8080 to the outside world
EXPOSE 8080

# Command to run the executable
CMD ["./app"]
