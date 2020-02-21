# Socket-Starscream-Demo

Originally based off of [this tutorial](https://www.raywenderlich.com/861-websockets-on-ios-with-starscream) (outdated)

Steps to demo:

1. Install node if you don't have it.
2. Open a terminal window and cd into the project directory then run `npm install websocket`.
3. `cd nodeapp`.
4. `node chat-server.js`.
5. See something along the lines of "Fri Feb 21 2020 11:49:06 GMT-0500 (Eastern Standard Time) Server is listening on port 1337".
6. In the nodeapp folder open `frontend.html` this will launch the server in your browser. Enter a name and send a message.
7. Open a terminal window and cd into the project directory then run `pod install`.
8. Open `SocketDemo.xcworkspace` with Xcode.
9. Run the app.
10. Enter your name.
11. Send a message using the app or the webpage previously opened, both should update in real time and display the conversation.
