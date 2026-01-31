# Use NGINX Alpine for lightweight static file serving
FROM nginx:alpine

# Add labels for metadata
LABEL maintainer="Adebowale Adeleke"
LABEL description="Multi-environment CI/CD pipeline static site"
LABEL version="1.0.0"

# Copy static HTML file to NGINX default directory
COPY public/index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
