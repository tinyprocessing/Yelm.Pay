# Yelm.Pay

Create payment - ApplePay

```swift 
YelmPay.start(platform: platform, user: ServerAPI.user.username) { (load) in

    YelmPay.apple_pay.apple_pay(price: 100, delivery: 50, merchant: "", country: "RU", currency: "RUB")

}
```
