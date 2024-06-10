FROM node:alpine

# Create and change to app dir
WORKDIR /usr/src/app

# Copy package & -lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the source, files copied are only those in public repo by github action
COPY . .

# Expose the port
EXPOSE 8080

# Command to run the application
CMD ["node", "entrypoint.js"]
