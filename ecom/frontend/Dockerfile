# Use a base image with a simple web server
FROM nginx:alpine

# Copy the HTML file to the nginx html directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]
