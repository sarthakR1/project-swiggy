# Using Node.js 20 Alpine as the base image to clear OS vulnerabilities
FROM node:20-alpine

# Setting up the working directory
WORKDIR /app

# Copying the package.json and package-lock.json files to the working directory
COPY package*.json ./

# Installation of npm dependency
RUN npm install

# Copy the application code
COPY . .

# Buildinf of the React app
RUN npm run build

# Expose port 3000 to access app
EXPOSE 3000

# Start your Node.js server
CMD ["npm", "start"]
