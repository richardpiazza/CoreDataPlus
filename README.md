# CoreDataPlus

A collection of extensions and helpers for working with Core Data.

<p>
    <img src="https://github.com/richardpiazza/CoreDataPlus/workflows/Swift/badge.svg?branch=main" />
    <img src="https://img.shields.io/badge/Swift-5.3-orange.svg" />
    <a href="https://twitter.com/richardpiazza">
        <img src="https://img.shields.io/badge/twitter-@richardpiazza-blue.svg?style=flat" alt="Twitter: @richardpiazza" />
    </a>
</p>

## Installation

**CoreDataPlus** is distributed using the [Swift Package Manager](https://swift.org/package-manager).
To install it into a project, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/CoreDataPlus.git", .upToNextMinor(from: "0.1.0")
    ],
    ...
)
```

Then import the **CoreDataPlus** packages wherever you'd like to use it:

```swift
import CoreDataPlus
```
