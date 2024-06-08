# Use alpine as the base image
FROM alpine:latest

# Install necessary packages
RUN apk update && \
    apk add --no-cache procps sqlite

# Copy the script into the container
COPY log_top_processes_with_swap.sh /usr/src/app/log_top_processes_with_swap.sh

# Set the working directory
WORKDIR /usr/src/app

# Make the script executable
RUN chmod +x log_top_processes_with_swap.sh

# Run the script
CMD ["sh","log_top_processes_with_swap.sh"]
