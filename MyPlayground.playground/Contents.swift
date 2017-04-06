//: Playground - noun: a place where people can play

import UIKit

func getData() {
    var headers: [AnyHashable: Any] = ["X-Mashape-Key": "xsaxg89C9QmshN6Iq6AintijTIJBp1ifm7cjsnvuXCfjmFcyAY"]
    var asyncConnection: UrlConnection? = UNIRest.get({(_ request: SimpleRequest) -> Void in
        request.url = "https://omgvamp-hearthstone-v1.p.mashape.com/cards"
        request.headers = headers
    }).asJsonAsync({(_ response: HTTPJsonResponse, _ error: Error?) -> Void in
        var code: Int = response.code
        var responseHeaders: [AnyHashable: Any] = response.headers
        var body: JsonNode? = response.body
        var rawBody: Data? = response.rawBody
    })
}

getData()
