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
    #if os(OSX)
    @State private var image: NSImage? = nil
    #else
    @State private var image: UIImage? = nil
    #endif
    
    #if os(OSX)
    public init(_ url: Url, placeholder: Image = Image(nsImage: NSImage()), contentMode: ContentMode = .fill, animation: Animation = .easeInOut) {
        self.request = Request {
            url
        }
        self.placeholder = placeholder
        self.animation = animation
        self.contentMode = contentMode
    }
    #else
    public init(_ url: Url, placeholder: Image = Image(uiImage: UIImage()), contentMode: ContentMode = .fill, animation: Animation = .easeInOut) {
        self.request = Request {
            url
        }
        self.placeholder = placeholder
        self.animation = animation
        self.contentMode = contentMode
    }
    #endif
    
    #if os(OSX)
    public init(_ request: Request, placeholder: Image = Image(nsImage: NSImage()), contentMode: ContentMode = .fill, animation: Animation = .easeInOut) {
        self.request = request
        self.placeholder = placeholder
        self.animation = animation
        self.contentMode = contentMode
    }
    #else
    public init(_ request: Request, placeholder: Image = Image(uiImage: UIImage()), contentMode: ContentMode = .fill, animation: Animation = .easeInOut) {
        self.request = request
        self.placeholder = placeholder
        self.animation = animation
        self.contentMode = contentMode
    }
    #endif
    
    public var body: some View {
        if image != nil {
            #if os(OSX)
            return Image(nsImage: image!)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .animation(animation)
            #else
            return Image(uiImage: image!)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .animation(animation)
            #endif
        } else {
            self.request.onData { data in
                #if os(OSX)
                self.image = NSImage(data: data!)
                #else
                self.image = UIImage(data: data!)
                #endif
            }
            .call()
            return placeholder
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .animation(animation)
        }
    }
}
