# Start with a lightweight NGINX image for serving static web content
FROM nginx:alpine

# Set the working directory to avoid potential issues with relative paths
WORKDIR /usr/share/nginx/html

# Copy the HTML file to the default location for NGINX to serve
COPY index.html .

# Expose the default HTTP port (80) for external access
EXPOSE 81

# By default, the NGINX image's entrypoint runs the web server, no need to specify CMD
