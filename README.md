# Yelm.Pay

Create payment - ApplePay

```swift 
YelmPay.start(platform: platform, user: ServerAPI.user.username) { (load) in

    YelmPay.apple_pay.apple_pay(price: 100, delivery: 50, merchant: "", country: "RU", currency: "RUB")

}
```
Create payment - card

```swift 
YelmPay.start(platform: platform, user: ServerAPI.user.username) { (load) in
    YelmPay.core.payment(card_number: self.card, date: self.date, cvv: self.cvv, merchant: ServerAPI.settings.public_id,  price: self.realm.get_price_full(), currency: "RUB") { (load, response, data)  in
                             
    }
}
```
