# FLOOP

Floop is a "fallup" style game with added gravity physics towards the vertical center of the screen.
The object of the game is to survive as long as you can without hitting any of the falling bars.
- Any and all assets used in this game were obtained from free and open source means. (opengameart.org, assetstore.unity3d.com, etc...)

## Getting Started

You can run this game in the Xcode simulator, or download it to your iPhone.
This game was created to fulfill the final project requirements for Udacity iOS Nanodegree.

### Requirements

The requirements and how this app fulfills them:

1) README file

- The app contains a README that fully describes the intended user experience. After reading the document, a user can easily use the app.
```
Self-fulfilling...
```

- The README provides all necessary information to enable the reviewer to build, run, and access the app.
```
You can run this game in the Xcode simulator, or download it to your iPhone
```

2) User Interface

- The app contains multiple pages of interface in a navigation controller or tab controller, or a single view controller with a view that shows and hides significant new content.
```
The app contains 3 view controllers: MenuViewController, GameViewController, EndGameViewController
MenuViewController - Start Screen
GameViewController - Loads the GameScene for gameplay
EndGameViewController - Game Over Screen
```

- The user interface includes more than one type of control.
```
The app utilizes multiple types of control for user workflow
```

3) Networking

- The app includes data from a networked source.
```
Facebook Login and Facebook Share
```

- The networking code is encapsulated in its own classes.
```
See Facebook file
```

- The app clearly indicates network activity, displaying activity indicators and/or progress bars when appropriate.
```
When logging in/out the facebook button is updated with status.
If network error is encountered an alert is displayed to the user.
```

- The app displays an alert view if the network connection fails.
```
If network error is encountered an alert is displayed to the user.
```

4) Persistent State

- The app has a persistent state that is stored using Core Data or a service with local persistence capabilities (e.g. Firebase or Realm).
```
The game uses Core Data to persistently save and access the players best score.
(Massive overkill, but needed to fulfill the requirement.)
```

5) App Functionality

- The app functions as described in the README, without crashes or other runtime errors.
```
The only runtime errors we encounter are the known issues with Xcode 8 (https://github.com/p2/OAuth2/issues/186) and those created by Facebook simulator bug (https://stackoverflow.com/questions/41047345/ios-facebook-login-access-token-error-falling-back-to-loading-access-token-fro).
```


## Author

* **Jordan Marshall** - [github](https://github.com/jtmarshall)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
