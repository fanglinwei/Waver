# Waver

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Platform](https://img.shields.io/badge/platforms-iOS-orange.svg)



A Siri like wave effect

## Effect

![素材](/Users/calm/Documents/个人/Github/Waver/Design/素材.gif)



## Usage

Copy the Waver folder to your project

### Example

```swift

        waver.set { [weak self]() -> Float in
            guard let self = self, let recorder = self.recorder else { return 0 }
            recorder.updateMeters()
            return pow(10, recorder.averagePower(forChannel: 0) / 40)
        }
        
        waver.start()
        
```



## SpecialThanks

> [Waver](https://github.com/kevinzhow/Waver)

## Contributing

If you have the need for a specific feature that you want implemented or if you experienced a bug, please open an issue.
If you extended the functionality of Spring yourself and want others to use it too, please submit a pull request.


## License

Spring is under MIT license. See the [LICENSE](LICENSE) file for more info.

```

```
