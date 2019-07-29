//
//  RequestImage.swift
//  
//
//  Created by Carson Katri on 7/28/19.
//

import SwiftUI

/// A view that asynchronously loads an image
///
/// It automatically has animations to transition from a placeholder and the image.
///
/// It takes a `Url` or `Request`, a placeholder, the `ContentMode` for displaying the image, and an `Animation` for switching
public struct RequestImage: View {
    private let request: Request
    private let placeholder: Image
    private let animation: Animation
    private let contentMode: ContentMode
    @State private var image: UIImage? = nil
    
    public init(_ url: Url, placeholder: Image = Image(uiImage: UIImage()), contentMode: ContentMode = .fill, animation: Animation = .easeInOut) {
        self.request = Request {
            url
        }
        self.placeholder = placeholder
        self.animation = animation
        self.contentMode = contentMode
    }
    
    public init(_ request: Request, placeholder: Image = Image(uiImage: UIImage()), contentMode: ContentMode = .fill, animation: Animation = .easeInOut) {
        self.request = request
        self.placeholder = placeholder
        self.animation = animation
        self.contentMode = contentMode
    }
    
    public var body: some View {
        if image != nil {
            return Image(uiImage: image!)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .animation(animation)
        } else {
            self.request.onData { data in
                self.image = UIImage(data: data!)
            }
            .call()
            return placeholder
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .animation(animation)
        }
    }
}
