# FloatingActionButton

FloatingActionButton is floating action button component of [material design](https://www.google.com/design/spec/material-design/introduction.html), inspired by [Material In a Liquid State](http://www.materialup.com/posts/material-in-a-liquid-state).
Adapted from (https://github.com/yoavlt/LiquidFloatingActionButton) by Takuma Yoshida

## Features
- [x] Material design animation
- [x] easily customizable
- [x] Objective-C compatible

## Usage

You just need implement `FloatingActionButtonDataSource` and `FloatingActionButtonDelegate` similar to well-known UIKit design.

```swift
let floatingActionButton = FloatingActionButton(frame: floatingFrame)
floatingActionButton.dataSource = self
floatingActionButton.delegate = self
```

### FloatingActionButtonDataSource
* func numberOfCells(floatingActionButton: FloatingActionButton) -> Int
* func cellForIndex(index: Int) -> FloatingCell

### FloatingActionButtonDelegate
* optional func dloatingActionButton(floatingActionButton: FloatingActionButton, didSelectItemAtIndex index: Int)

## License

FloatingActionButton is available under the MIT license. See the LICENSE file for more info.
