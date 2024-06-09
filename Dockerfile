FROM alpine:latest

# Set work directory
WORKDIR /app

# Install necessary packages
RUN apk --no-cache add curl bash jq

# Copy files
COPY entrypoint.sh ./entrypoint.sh

# Make the script executable
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]