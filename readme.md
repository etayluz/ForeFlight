# ForeFlight Assignment App

The ForeFlight Assignment app implements a weather report application. 

## Features

- The user can enter and search for an airport symbol.
- The application will fetch the weather report per said airport symbol from ForeFlight server endpoint
- If airport symbol is invalid, app will alert the user that the airport symbol is invalid
- If airport symbol is valid, app will display the weather report in a new “Details View”.
- Reports are parsed out for "conditions" and "forecast" data - both of which are stored in Core Data as a json String (for simplicity).
- User can toggle a switch to alternate between "conditions" and "forecast" data in the “Details View”. 
- Previously looked up airports weather reports are loaded from Core Data and displayed in a table view upon app launch
- Upon first launch - the app will fetch the weather reports for KPWM & KAUS airports
- User can tap on an airport in the table view - which will drill down to “Details View” for said airport symbol
- Weather report is automatically fetched at a regular interval for previously search airports
- 8 hours or so were spent building this app (I got bugged down with Core Data issues for several hours)


## Architecture
- App employs UIKit and storyboards
- App employs Core Data
- App architecture is based on models, view controllers, and services
- The services are for Core Data access and remote api call
- Core Data and Remote API services are "injected" into the main View Controller (AirportListVC) inside SceneDelegate.swift
- App employs the new await/async design pattern (introduced in Swift 5.5) in order to invoke services

## Installation
Open foreflight.xcodeproj in XCode and build
## License

MIT

