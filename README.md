# MathMinigames
A Flutter Math Game that allows players to do a sequence of questions in a game-quiz-like setting to learn math at a 4th grade level

# How to setup the environment
Run the following in the command line to install dependencies:

flutter pub get

Run this to check everything was installed correctly:

flutter doctor

# Run the app

You will need a Google Firebase setup to save the data this app pushes. Add your API key to enable this.

Run the app  with the following command:

flutter run

You can generate (or regenerate) the build output by running the following:

flutter build web

# Firebase
The happi account with Firebase access is: thehapiilab@gmail.com
Please use this account to manage data storage

If the app isn't deployed at the same link (https://fir-79444.web.app/), you may need to re-deploy to access it on the web.
Project Settings > General > Scroll Down
Reveals the project setup for the API key and other code snippets. Please fetch the key here first to run the data storage. It can be the same key and code snippets as the firebase ones

You need to add this key in the lib/firebase_options.dart file.

You can deploy the latest build of the app using:

firebase deploy

You need to login to do this. You can set this up with this command:
firebase login

You might need to run this to setup your project:

flutterfire configure --project-fir-79444