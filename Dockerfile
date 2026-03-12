# Build stage
FROM golang:1.26.1 AS builder

# Install Node.js for frontend build
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install dependencies
RUN apt-get update && apt-get install -y git make
RUN npm install -g yarn

WORKDIR /build

# Copy source code
COPY . .

# Build the application
RUN make dist

# Runtime stage
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add ca-certificates tzdata shadow su-exec

# Set the working directory
WORKDIR /listmonk

# Copy the built binary from builder stage
COPY --from=builder /build/listmonk .

# Copy config template
COPY config.toml.sample config.toml

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose the application port
EXPOSE 9000

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

# Define the command to run the application
CMD ["./listmonk"]
