//
//  CustomParameterEncoding.swift
//  TransmissionClient-Swift
//
//  Created by SUN on 16/9/21.
//  Copyright © 2016年 SUN. All rights reserved.
//

import Foundation
import Alamofire


// MARK: -

/// Uses `JSONSerialization` to create a JSON representation of the parameters object, which is set as the body of the
/// request. The `Content-Type` HTTP header field of an encoded request is set to `application/json`.
public struct CustomParameterEncoding: ParameterEncoding {
    
    
    public static func `default`(_ content:String) -> ParameterEncoding {
        return CustomParameterEncoding({ (convertible, params) throws -> URLRequest in
            /// 这个地方是用来手动的设置POST消息体的,思路就是通过ParameterEncoding.Custom闭包来设置请求的HTTPBody
            var urlRequest = try convertible.asURLRequest()
            
            urlRequest.httpBody = content.data(using: String.Encoding.utf8, allowLossyConversion: false)
            
            return urlRequest
        })
    }
    
    // MARK: Properties
    
    private let encoder : (URLRequestConvertible,Parameters?) throws -> URLRequest
    
    // MARK: Initialization
    
    /// Creates a `JSONEncoding` instance using the specified options.
    ///
    /// - parameter options: The options for writing the parameters as JSON data.
    ///
    /// - returns: The new `JSONEncoding` instance.
    public init(_ encoder:@escaping (URLRequestConvertible,Parameters?) throws -> URLRequest) {
        self.encoder = encoder
    }
    
    // MARK: Encoding
    
    /// Creates a URL request by encoding parameters and applying them onto an existing request.
    ///
    /// - parameter urlRequest: The request to have parameters applied.
    /// - parameter parameters: The parameters to apply.
    ///
    /// - throws: An `Error` if the encoding process encounters an error.
    ///
    /// - returns: The encoded request.
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        
        return try self.encoder(urlRequest,parameters)
    }
}
