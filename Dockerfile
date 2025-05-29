# Use a lightweight base image
FROM debian:bullseye-slim

# Set metadata
LABEL maintainer="you@example.com"

# Simple healthcheck
HEALTHCHECK CMD echo "OK"

# Set working directory
WORKDIR /app

# Create a test file
RUN echo "Hello from test image!" > hello.txt

# Define default command
CMD ["cat", "hello.txt"]
