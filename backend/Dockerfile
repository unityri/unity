# Base image - use official Node image instead of Ubuntu
FROM node:16-bullseye AS development

# Install Google Chrome dependencies and Chrome
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libgdk-pixbuf2.0-0 \
    libnspr4 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/src/app

# Copy package files and npm configuration
COPY package*.json .npmrc ./

# Install dependencies with optimized settings
RUN PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install --no-audit --no-fund --prefer-offline || \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install --no-audit --no-fund --legacy-peer-deps

# Copy application code
COPY . .

# Expose application port
EXPOSE 3306

# ✅ Increase Node.js heap memory to 6GB
ENV NODE_OPTIONS="--max-old-space-size=6144"

# Start the app
CMD ["npm", "start"]
