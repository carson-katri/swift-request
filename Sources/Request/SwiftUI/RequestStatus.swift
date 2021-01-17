//
//  RequestStatus.swift
//  
//
//  Created by Carson Katri on 1/17/21.
//

public enum RequestStatus<Value: Decodable> {
    case loading
    case success(Value)
    case failure(Error)
}
