#!/bin/bash
# Use this for your user data (script from top to bottom)
# Install httpd (Linux 2 version)
#yum update -y
#yum install -y httpd
#systemctl start httpd
#systemctl enable httpd

# Create the local index.html file
sudo cat << 'EOF' > index.gen.html
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <title>LOGNAME's site - CURR_DATE</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      text-align: center;
      margin: 0;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 100vh;
      transition: background-color 0.5s, color 0.5s;
    }

    h1 {
      margin-top: 20px;
      font-size: 36px;
    }

    .image-container {
      width: 80%;
      heigth: 80%
      display: flex;
      justify-content: center;
      align-items: center;
      margin-top: 20px;
    }

    .image-container img {
      max-width: 100%;
      max-height: 80vh;
    }

    .joke-container {
      margin-top: 20px;
      display: flex;
      flex-direction: column;
      align-items: center;
      width: 100%;
    }

    .joke-text {
      font-size: 18px;
      margin-bottom: 10px;
      position: relative;
      display: inline-block;
      text-align: center;
    }

    .joke-text:hover::before {
      content: attr(title);
      position: absolute;
      background-color: rgba(0, 0, 0, 0.7);
      color: white;
      padding: 4px 8px;
      border-radius: 4px;
      white-space: nowrap;
      z-index: 1;
      bottom: 90%;
      left: 50%;
      transform: translateX(-50%);
    }

    .copy-button,
    .refresh-button {
      background-color: transparent;
      border: 1px solid currentColor;
      border-radius: 4px;
      padding: 8px;
      cursor: pointer;
      transition: background-color 0.3s, transform 0.1s;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-top: 10px;
      margin-right: 10px;
      /* Space between buttons */
      position: relative;
      font-size: 14px;
    }

    .copy-button:hover,
    .refresh-button:hover {
      background-color: rgba(255, 255, 255, 0.1);
    }

    .copy-button:active,
    .refresh-button:active {
      transform: scale(0.95);
    }

    .copy-button.copied {
      background-color: #4CAF50;
      color: white;
    }

    .copy-icon,
    .refresh-icon {
      display: block;
      width: 16px;
      height: 16px;
      margin-left: 8px;
      margin-right: 8px;
    }

    .button-container {
      display: flex;
      gap: 10px;
      /* Space between buttons */
      margin-top: 10px;
    }
  </style>
</head>

<body>
  <h1>Hello World, this is LOGNAME from HOSTNAME</h1>
  <h2>since CURR_DATE</h2>
  <div class="image-container">
    <img id="randomImage" src="" alt="">
  </div>
  <div id="jokeContainer" class="joke-container">
    <p id="joke"></p>
  </div>
  <script>
    const darkColors = ['#1a1a1a', '#2e2e2e', '#3c3c3c', '#484848', '#505050', '#5c5c5c', '#1a1a66', '#2e2e99', '#3c3c99', '#4848b3', '#5050cc', '#5c5cd6', '#661a1a', '#993333', '#993c3c', '#b34848', '#cc5050', '#d65c5c', '#1a661a', '#339933', '#3c993c', '#48b348', '#50cc50', '#5cd65c'];
    function getRandomDarkColor() {
      const randomIndex = Math.floor(Math.random() * darkColors.length);
      return darkColors[randomIndex];
    }
    function getContrastingColor(hexColor) {
      const r = parseInt(hexColor.substr(1, 2), 16);
      const g = parseInt(hexColor.substr(3, 2), 16);
      const b = parseInt(hexColor.substr(5, 2), 16);
      const yiq = ((r * 299) + (g * 587) + (b * 114)) / 1000;
      return (yiq >= 128) ? 'black' : 'white';
    }
    function applyRandomBackgroundColor() {
      const bgColor = getRandomDarkColor();
      const textColor = getContrastingColor(bgColor);
      document.body.style.backgroundColor = bgColor;
      document.body.style.color = textColor;
    }
    function fetchJoke() {
      fetch("https://v2.jokeapi.dev/joke/Any")
        .then(response => response.json())
        .then(data => {
          var jokeContainer = document.getElementById("jokeContainer");
          jokeContainer.innerHTML = "";
          if (data.type === "single" || data.type === "twopart") {
            var jokeElements = createJokeElements(data);
            jokeElements.forEach(element => {
              jokeContainer.appendChild(element);
              //jokeContainer.appendChild(document.createElement("br")); // New line for spacing
            });
            // Create a div to hold the buttons
            var buttonContainer = document.createElement("div");
            buttonContainer.style.display = "flex";
            buttonContainer.style.gap = "10px"; // Space between buttons

            // Add copy button for joke
            var copyButton = createCopyButton(data);
            buttonContainer.appendChild(copyButton);

            // Add refresh button for page
            var refreshButton = createRefreshButton();
            buttonContainer.appendChild(refreshButton);

            // Append button container to joke container
            jokeContainer.appendChild(buttonContainer);
          } else {
            var noJokeElement = document.createElement("p");
            noJokeElement.textContent = "No joke found!";
            jokeContainer.appendChild(noJokeElement);
          }
        })
        .catch(error => {
          console.log("Error fetching joke:", error);
        });
    }
    function createJokeElements(data) {
      var elements = [];
      var jokeElement = document.createElement("p");
      jokeElement.classList.add("joke-text");
      jokeElement.setAttribute('title', `Category: ${data.category}`);
      if (data.type === "single") {
        jokeElement.textContent = data.joke;
        elements.push(jokeElement);
      } else {
        jokeElement.textContent = data.setup;
        elements.push(jokeElement);
        var deliveryElement = document.createElement("p");
        deliveryElement.textContent = data.delivery;
        deliveryElement.classList.add("joke-text");
        elements.push(deliveryElement);
      }
      return elements;
    }

    function createCopyButton(data) {
      var copyButton = document.createElement("button");
      copyButton.classList.add("copy-button");
      copyButton.setAttribute('aria-label', 'Copy Joke');
      copyButton.setAttribute('title', 'Copy joke');

      var copyIcon = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      copyIcon.setAttribute('viewBox', '0 0 24 24');
      copyIcon.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
      copyIcon.classList.add('copy-icon');

      var path = document.createElementNS("http://www.w3.org/2000/svg", "path");
      path.setAttribute('d', 'M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z');
      path.setAttribute('fill', 'currentColor');

      copyIcon.appendChild(path);
      copyButton.appendChild(copyIcon);

      copyButton.onclick = function () {
        var textToCopy = data.type === "single" ? data.joke : `${data.setup}\n${data.delivery}`;

        // Use the Clipboard API
        if (navigator.clipboard && navigator.clipboard.writeText) {
          navigator.clipboard.writeText(textToCopy).then(function () {
            playBeep();
            copyButton.classList.add('copied');
            copyIcon.style.display = 'none';
            copyButton.textContent = "Copied!";
            setTimeout(function () {
              copyButton.classList.remove('copied');
              copyButton.textContent = "";
              copyIcon.style.display = '';
              copyButton.appendChild(copyIcon);
            }, 2000);
          }).catch(function (err) {
            console.error('Could not copy text: ', err);
            alert('Failed to copy joke to clipboard.');
          });
        } else {
          // Fallback for browsers that don't support the Clipboard API
          var textArea = document.createElement("textarea");
          textArea.value = textToCopy;
          document.body.appendChild(textArea);
          textArea.select();
          try {
            document.execCommand('copy');
            playBeep();
            copyButton.classList.add('copied');
            copyIcon.style.display = 'none';
            copyButton.textContent = "Copied!";
            setTimeout(function () {
              copyButton.classList.remove('copied');
              copyButton.textContent = "";
              copyIcon.style.display = '';
              copyButton.appendChild(copyIcon);
            }, 2000);
          } catch (err) {
            console.error('Could not copy text: ', err);
            alert('Failed to copy joke to clipboard.');
          }
          document.body.removeChild(textArea);
        }
      };

      return copyButton;
    }
    function playBeep() {
      var audioContext = new (window.AudioContext || window.webkitAudioContext)();
      var oscillator = audioContext.createOscillator();
      oscillator.type = 'sine';
      oscillator.frequency.setValueAtTime(440, audioContext.currentTime);
      oscillator.connect(audioContext.destination);
      oscillator.start();
      oscillator.stop(audioContext.currentTime + 0.1);
    }

    function createRefreshButton() {
      var refreshButton = document.createElement("button");
      refreshButton.classList.add("refresh-button");
      refreshButton.setAttribute('aria-label', 'Refresh Page');
      refreshButton.setAttribute('title', 'Refresh page'); // Tooltip for refresh button

      var refreshIcon = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      refreshIcon.setAttribute('viewBox', '0 0 24 24');
      refreshIcon.setAttribute('xmlns', 'http://www.w3.org/2000/svg');
      refreshIcon.classList.add('refresh-icon');

      var path = document.createElementNS("http://www.w3.org/2000/svg", "path");
      path.setAttribute('d', 'M12 4V1L8 5l4 4V6c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z');
      path.setAttribute('fill', 'currentColor');

      refreshIcon.appendChild(path);
      refreshButton.appendChild(refreshIcon);

      refreshButton.onclick = function () {
        location.reload(); // Refresh the page
      };

      return refreshButton;
    }

    function generateRandomImageUrl() {
      var viewportWidth = window.innerWidth * 0.8;
      var viewportHeight = window.innerHeight * 0.8;
      var randomWidth = Math.floor(Math.random() * (viewportWidth - viewportWidth * 0.8 + 1)) + viewportWidth * 0.8;
      var randomHeight = Math.floor(Math.random() * (viewportHeight - viewportHeight * 0.8 + 1)) + viewportHeight * 0.8;
      var imageUrl = `https://picsum.photos/${Math.floor(randomWidth)}/${Math.floor(randomHeight)}`;
      return imageUrl;
    }
    function debounce(func, wait) {
      let timeout;
      return function (...args) {
        clearTimeout(timeout);
        timeout = setTimeout(() => func.apply(this, args), wait);
      };
    }
    function updateImage() {
      var imageUrl = generateRandomImageUrl();
      document.getElementById('randomImage').src = imageUrl;
    }
    window.onload = function () {
      applyRandomBackgroundColor();
      updateImage();
      fetchJoke();
    }
    window.onresize = debounce(function () {
      applyRandomBackgroundColor();
      updateImage();
      fetchJoke();
    }, 500);
  </script>
</body>

</html>
EOF

# Get the hostname
HOSTNAME=$(hostname)
CURR_DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Logname=$LOGNAME\nHostname=$HOSTNAME\nCurrent date=$CURR_DATE"

# Replace placeholders in the file
sed -i "s|HOSTNAME|[$HOSTNAME]|g" index.gen.html
sed -i "s|CURR_DATE|[$CURR_DATE]|g" index.gen.html
sed -i "s|LOGNAME|[$LOGNAME]|g" index.gen.html

# Copy the file to the Nginx default web folder
sudo cp index.gen.html /var/www/html/index.html

# Set proper permissions
sudo chown www-data:www-data /var/www/html/index.html
sudo chmod 644 /var/www/html/index.html
sudo cp /var/www/html/index.html /usr/share/nginx/html/index.html
# Restart Nginx to apply changes
sudo systemctl restart nginx

echo "Setup complete. You can now access the website through your Nginx server."
