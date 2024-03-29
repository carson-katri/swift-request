![Request](Resources/banner.png)

![swift 5.1](https://img.shields.io/badge/swift-5.1-blue.svg)
![SwiftUI](https://img.shields.io/badge/-SwiftUI-blue.svg)
![iOS](https://img.shields.io/badge/os-iOS-green.svg)
![macOS](https://img.shields.io/badge/os-macOS-green.svg)
![tvOS](https://img.shields.io/badge/os-tvOS-green.svg)
[![Build](https://github.com/carson-katri/swift-request/workflows/Build/badge.svg)](https://github.com/carson-katri/swift-request/actions)
[![codecov](https://codecov.io/gh/carson-katri/swift-request/branch/master/graph/badge.svg)](https://codecov.io/gh/carson-katri/swift-request)

[Installation](#installation) - [Getting Started](#getting-started) - [Building a Request](#building-a-request) - [Codable](#codable) - [Combine](#combine) - [How it Works](#how-it-works) - [Request Groups](#request-groups) - [Request Chains](#request-chains) - [Json](#json) - [Contributing](#contributing) - [License](#license)

[Using with SwiftUI](Resources/swiftui.md)


## Installation
`swift-request` can be installed via the `Swift Package Manager`.

In Xcode 11, go to `File > Swift Packages > Add Package Dependency...`, then paste in `https://github.com/carson-katri/swift-request`

Now just `import Request`, and you're ready to [Get Started](#getting-started)


## Getting Started
The old way:
```swift
var request = URLRequest(url: URL(string: "https://jsonplaceholder.typicode.com/todos")!)
request.addValue("application/json", forHTTPHeaderField: "Accept")
let task = URLSession.shared.dataTask(with: url!) { (data, res, err) in
    if let data = data {
        ...
    } else if let error = error {
        ...
    }
}
task.resume()
```
The *declarative* way:
```swift
Request {
    Url("https://jsonplaceholder.typicode.com/todo")
    Header.Accept(.json)
}
.onData { data in
    ...
}
.onError { error in
    ...
}
.call()
```
The benefit of declaring requests becomes abundantly clear when your data becomes more complex:
```swift
Request {
    Url("https://jsonplaceholder.typicode.com/posts")
    Method(.post)
    Header.ContentType(.json)
    Body(Json([
        "title": "foo",
        "body": "bar",
        "usedId": 1
    ]).stringified)
}
```
Once you've built your `Request`, you can specify the response handlers you want to use.
`.onData`, `.onString`, `.onJson`, and `.onError` are available.
You can chain them together to handle multiple response types, as they return a modified version of the `Request`.

To perform the `Request`, just use `.call()`. This will run the `Request`, and give you the response when complete.

`Request` also conforms to `Publisher`, so you can manipulate it like any other Combine publisher ([read more](#combine)):
```swift
let cancellable = Request {
    Url("https://jsonplaceholder.typicode.com/todo")
    Header.Accept(.json)
}
.sink(receiveCompletion: { ... }, receiveValue: { ... })
```

## Building a Request
There are many different tools available to build a `Request`:
- `Url`

Exactly one must be present in each `Request`
```swift
Url("https://example.com")
Url(protocol: .secure, url: "example.com")
```
- `Method`

Sets the `MethodType` of the `Request` (`.get` by default)
```swift
Method(.get) // Available: .get, .head, .post, .put, .delete, .connect, .options, .trace, and .patch 
```
- `Header`

Sets an HTTP header field
```swift
Header.Any(key: "Custom-Header", value: "value123")
Header.Accept(.json)
Header.Authorization(.basic(username: "carsonkatri", password: "password123"))
Header.CacheControl(.noCache)
Header.ContentLength(16)
Header.ContentType(.xml)
Header.Host("en.example.com", port: "8000")
Header.Origin("www.example.com")
Header.Referer("redirectfrom.example.com")
Header.UserAgent(.firefoxMac)
```
- `Query`

Creates the query string
```swift
Query(["key": "value"]) // ?key=value
```
- `Body`

Sets the request body
```swift
Body(["key": "value"])
Body("myBodyContent")
Body(myJson)
```
- `Timeout`

Sets the timeout for a request or resource:
```swift
Timeout(60)
Timeout(60, for: .request)
Timeout(30, for: .resource)
```
- `RequestParam`

Add a param directly
> **Important:** You must create the logic to handle a custom `RequestParam`. You may also consider adding a case to `RequestParamType`. If you think your custom parameter may be useful for others, see [Contributing](#contributing)


## Codable
Let's look at an example. Here we define our data:
```swift
struct Todo: Codable {
    let title: String
    let completed: Bool
    let id: Int
    let userId: Int
}
```
Now we can use `AnyRequest` to pull an array of `Todo`s from the server:
```swift
AnyRequest<[Todo]> {
    Url("https://jsonplaceholder.typicode.com/todos")
}
.onObject { todos in ... }
```
In this case, `onObject` gives us `[Todo]?` in response. It's that easy to get data and decode it.

`Request` is built on `AnyRequest`, so they support all of the same parameters.

> If you use `onObject` on a standard `Request`, you will receive `Data` in response.

## Combine
`Request` and `RequestGroup` both conform to `Publisher`:
```swift
Request {
    Url("https://jsonplaceholder.typicode.com/todos")
}
.sink(receiveCompletion: { ... }, receiveValue: { ... })

RequestGroup {
    Request {
        Url("https://jsonplaceholder.typicode.com/todos")
    }
    Request {
        Url("https://jsonplaceholder.typicode.com/posts")
    }
    Request {
        Url("https://jsonplaceholder.typicode.com/todos/1")
    }
}
.sink(receiveCompletion: { ... }, receiveValue: { ... })
```
`Request` publishes the result using `URLSession.DataTaskPublisher`. `RequestGroup` collects the result of each `Request` in its body, and publishes the array of results.

You can use all of the Combine operators you'd expect on `Request`:
```swift
Request {
    Url("https://jsonplaceholder.typicode.com/todos")
}
.map(\.data)
.decode([Todo].self, decoder: JSONDecoder())
.sink(receiveCompletion: { ... }, receiveValue: { ... })
```
However, `Request` also comes with several convenience `Publishers` to simplify the process of decoding:

1. `objectPublisher` - Decodes the data of an `AnyRequest` using `JSONDecoder`
2. `stringPublisher` - Decodes the data to a `String`
3. `jsonPublisher` - Converts the result to a `Json` object

Here's an example of using `objectPublisher`:
```swift
AnyRequest<[Todo]> {
    Url("https://jsonplaceholder.typicode.com/todos")
}
.objectPublisher
.sink(receiveCompletion: { ... }, receiveValue: { ... })
```
This removes the need to constantly use `.map.decode` to extract the desired `Codable` result.

To handle errors, you can use the `receiveCompletion` handler in `sink`:
```swift
Request {
    Url("https://jsonplaceholder.typicode.com/todos")
}
.sink(receiveCompletion: { res in
    switch res {
    case let .failure(err):
        // Handle `err`
    case .finished: break
    }
}, receiveValue: { ... })
```

## How it Works
The body of the `Request` is built using the `RequestBuilder` `@resultBuilder`.

It merges each `RequestParam` in the body into one `CombinedParam` object. This contains all the other params as children.

When you run `.call()`, the children are filtered to find the `Url`, and any other optional parameters that may have been included.

For more information, see [RequestBuilder.swift](Sources/Request/Request/RequestBuilder.swift) and [Request.swift](Sources/Request/Request/Request.swift)


## Request Groups
`RequestGroup` can be used to run multiple `Request`s *simulataneously*. You get a response when each `Request` completes (or fails)
```swift
RequestGroup {
    Request {
        Url("https://jsonplaceholder.typicode.com/todos")
    }
    Request {
        Url("https://jsonplaceholder.typicode.com/posts")
    }
    Request {
        Url("https://jsonplaceholder.typicode.com/todos/1")
    }
}
.onData { (index, data) in
    ...
}
.call()
```


## Request Chains
`RequestChain` is used to run multiple `Request`s *one at a time*. When one completes, it passes its data on to the next `Request`, so you can use it to build the `Request`.

`RequestChain.call` can optionally accept a callback that gives you all the data of every `Request` when completed.

> **Note:** You must use `Request.chained` to build your `Request`. This gives you access to the data and errors of previous `Request`s.
```swift
RequestChain {
    Request.chained { (data, errors) in
        Url("https://jsonplaceholder.typicode.com/todos")
    }
    Request.chained { (data, errors) in
        let json = Json(data[0]!)
        return Url("https://jsonplaceholder.typicode.com/todos/\(json?[0]["id"].int ?? 0)")
    }
}
.call { (data, errors) in
    ...
}
```

## Repeated Calls
`.update` is used to run additional calls after the initial one. You can pass it either a number or a custom `Publisher`. You can also chain together multiple `.update`s. The two `.update`s in the following example are equivalent, so the end result is that the `Request` will be called once immediately and twice every 10 seconds thereafter.
```swift
Request {
    Url("https://jsonplaceholder.typicode.com/todo")
}
.update(every: 10)
.update(publisher: Timer.publish(every: 10, on: .main, in: .common).autoconnect())
.call()
```

If you want to use `Request` as a `Publisher`, use `updatePublisher`:
```swift
Request {
    Url("https://jsonplaceholder.typicode.com/todo")
}
.updatePublisher(every: 10)
.updatePublisher(publisher: ...)
.sink(receiveCompletion: { ... }, receiveValue: { ... })
```
Unlike `update`, `updatePublisher` does not send a value immediately, but will wait for the first value from the `Publisher`.

## Json
`swift-request` includes support for `Json`.
`Json` is used as the response type in the `onJson` callback on a `Request` object.

You can create `Json` by parsing a `String` or `Data`:
```swift
Json("{\"firstName\":\"Carson\"}")
Json("{\"firstName\":\"Carson\"}".data(using: .utf8))
```
You can subscript `Json` as you would expect:
```swift
myJson["firstName"].string // "Carson"
myComplexJson[0]["nestedJson"]["id"].int
```
It also supports `dynamicMemberLookup`, so you can subscript it like so:
```swift
myJson.firstName.string // "Carson"
myComplexJson[0].nestedJson.id.int
```

You can use `.string`, `.int`, `.double`, `.bool`, and `.array` to retrieve values in a desired type.
> **Note:** These return **non-optional** values. If you want to check for `nil`, you can use `.stringOptional`, `.intOptional`, etc.

## Contributing
See [CONTRIBUTING](CONTRIBUTING.md)


## License
See [LICENSE](LICENSE)
