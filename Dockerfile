# Use an official Node.js runtime as a parent image
FROM node:24

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install app dependencies, including Material-UI 5
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .
ENV NODE_OPTIONS=--openssl-legacy-provider

# Set the environment variable for the Rapid API key using build-time argument
ARG REACT_APP_RAPID_API_KEY
ENV REACT_APP_RAPID_API_KEY=$REACT_APP_RAPID_API_KEY

# Build the React app
RUN npm run build

# Expose the port that the app will run on (adjust if needed)
EXPOSE 3000

# Define the command to start the app
CMD ["npm", "start"]

