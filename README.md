## iOS Project Boilerplate for SwiftUI
[![IDE](https://img.shields.io/badge/Xcode-26+-blue.svg)](https://developer.apple.com/xcode/)
[![Language](https://img.shields.io/badge/swift-6.2-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/iOS-17+-green.svg)](https://developer.apple.com/ios/)
[![TCA](https://img.shields.io/badge/TCA-1.26-purple.svg)](https://github.com/pointfreeco/swift-composable-architecture)
[![Build Status](https://github.com/rokon-uddin/swiftui-tca-boilerplate/actions/workflows/build.yml/badge.svg)](https://github.com/rokon-uddin/swiftui-tca-boilerplate/actions/workflows/build.yml)


A boilerplate to jumpstart your next app for Apple platforn using SwiftUI and TCA with integrating best practices and tools.

## Motivation

Accelerate your iOS/macOS development by eliminating repetitive setup tasks and establishing a solid, best-practice-driven foundation. This boilerplate empowers you to focus on building features, not reinventing the wheel.


## Best practices
* [Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) 1.26: Robust, scalable state management with SwiftUI friendly patterns, using native Observation (`@ObservableState`, `@Bindable`).
* **Swift 6 strict concurrency:** Every module builds in the Swift 6 language mode with complete data-race checking. See [Concurrency model](#concurrency-model).
* [R.swift](https://github.com/mac-cain13/R.swift): Get strong typed, autocompleted resources like images, fonts and segues in Swift projects.
* [Standard gitignore](https://github.com/github/gitignore/blob/master/Swift.gitignore): Keep your repository clean and focused.
* **Native networking:** A small `async`/`await` HTTP client on `URLSession`, with no third-party networking dependency. Endpoints are plain `Sendable` values, and a swappable transport serves bundled JSON stubs for tests and previews.
* [Swift-Format](https://github.com/apple/swift-format): Enforce consistent code style for maintainability.
* **App Flavors:** (Development, Staging, Production): Separate configurations for different environments.
* **Build Configuration per Flavor:** Fine-grained control over build settings.

## Architecture overview
The boilerplate is structured using a Clean Architecture to promote modularity, maintainability, and testability.

![](assets/clean.jpeg)

### Presentation Layer
* **Purpose:** This layer is responsible for rendering the user interface (UI) and handling user interactions. It uses SwiftUI to build views and the Composable Architecture (TCA) for state management.

* **Responsibilities:**
	* UI Rendering: Displays the product title, description, and interactive buttons.
	* User Input: Captures button taps and other user interactions.
	* State Management (TCA): Manages the application state.
	* Navigation: Handles transitions between screens (e.g., showing a sheet or full-screen cover).
	
### Domain Layer
* **Purpose:** This layer contains the core business logic and models of the application. It defines how data is structured. Additionally, it defines repository protocols to create an abstraction for data access.

* **Responsibilities:**
	* Business Logic: Implements the rules and operations that define the core functionality of the app.
	* Data Modeling: Defines the structure of the Product data and other entities relevant to the domain.
	* Use Cases: Defines abstract interactions with the domain (e.g., ProductUseCase for fetching a product).
	* Repository Protocols: Defines interfaces for interacting with data sources. These protocols act as contracts, specifying the operations (e.g., read, create, update) that the data access layer must implement. This separation of concerns keeps the domain layer clean and independent of specific data access technologies.

### Data Access Layer
* **Purpose:** This layer handles the communication with external data sources, such as remote APIs or local databases. It implements the repository protocols defined in the domain layer.

* **Responsibilities:**
	* Data Retrieval: Fetches product data from a remote API.
	* Data Persistence: (If applicable) Saves, updates or deletes persistent data in a local database.
	* Networking: Manages network requests, error handling, and authentication.
	* Data Mapping: Translates data between the format used by the data source and the domain models.
	* Repository Implementations: Provides concrete implementations of the repository protocols, defining how data is actually retrieved or stored.
	
## Concurrency model
All packages and the app target build in the **Swift 6 language mode** (complete strict concurrency checking).

* **Sendable domain:** Entities, errors, use cases and repository protocols are `Sendable`. Use cases are structs that hold `@Sendable` closures.
* **Actors own mutable state:**
  * `PersistenceController` is an actor that owns the Core Data stack. All work runs in `context.perform` on a private background context, and only `Sendable` domain structs leave the actor.
  * `TokenRefresher` is an actor that runs at most one token refresh at a time, even when several requests get a `401` concurrently.
  * `AsyncBroadcaster` is an actor that fans values out to many `AsyncStream` subscribers.
* **AsyncStream:** Long-lived data is exposed as `AsyncStream`s:
  * network reachability (`NWPathMonitor`)
  * network request activity (drives the loading indicator)
  * saved products (Core Data change stream)

  `ProductFeature` consumes them in `Effect.run` loops started from the view's `.task`, so they are cancelled automatically when the view disappears.
* **@MainActor UI:** Views and the `Store` live on the main actor. The app's `Store` is created once, as a `static let` on the `App`.

## Testing
Each package has its own test target using [Swift Testing](https://developer.apple.com/documentation/testing). Reducers are tested with TCA's `TestStore`, and the streams in those tests are driven by hand so they are deterministic.

```
swift test --package-path Features
```

###Additional Features (ToDo in the boilerplate)

* Deeplink handling base classes
* Notification handling base classes
* Integration with analytics and crash reporting tools

### Supporting Tools
Xcode 26 or later and Swift 6.2 or later.

### Prerequisites
* Xcode 26 or later
* Swift 6.2 or later
* iOS 17 / macOS 14 deployment target
* [Cookiecutter](https://cookiecutter.readthedocs.io/en/latest/installation.html)

Install cookiecutter by runing below terminal command.

```
brew install cookiecutter
```

## Usage
The boilerplate uses Cookiecutter to create your project from it.

1.  Run the below command to create your project:

	```
	cookiecutter https://github.com/rokon-uddin/swiftui-tca-boilerplate.git
	```
2. Follow the prompts for app name and company name.
3. Update bundle IDs for main and test targets.

## Build configurations
Boilerplate uses `.xcconfig` and `BuildConfiguration.plist` for managing environment-specific settings. Refer to the linked guide for detailed instructions.
[link](https://medium.com/better-programming/how-to-create-development-staging-and-production-configs-in-xcode-ec58b2cc1df4).


## TCA XCTemplate installation (optional)
All the Xcode custom template files are located in ~/Library/Developer/Xcode/Templates/ and grouped into sections by folder name. 

1. Create a folder with name `Custom Templates` manually or by running the following command from the terminal:

	```
	mkdir ~/Library/Developer/Xcode/Templates/Custom Templates
	```

2. Drag and drop the `TCA.xctemplate` file(included with the repo to the `Custom Templates` directory). 
3. The TCA template now will be available in Xcode's File Templates.

![](assets/tca_template.gif)

## Contributing guidelines
Please see [Contributing Guidelines](https://github.com/rokon-uddin/swiftui-tca-boilerplate/blob/main/CONTRIBUTING.md) before participating.


## Acknowledgments

* [iOS Project Best Practices and Tools](https://medium.com/@piotr.gorzelany/ios-project-best-practices-and-tools-c46135b8116d)
* [Development, Staging and Production Configs in Xcode](https://medium.com/better-programming/how-to-create-development-staging-and-production-configs-in-xcode-ec58b2cc1df4)
* [iOS Build Management using Custom Build Scheme](https://www.talentica.com/blogs/ios-build-management-using-custom-build-scheme/)

## 👥 Credits
This boilerplate project is a collaborative effort, made with ❤️ by:

* [Arman Morshed](https://github.com/Arman-Morshed)
* [Mohammed Rokon Uddin](https://github.com/rokon-uddin)
