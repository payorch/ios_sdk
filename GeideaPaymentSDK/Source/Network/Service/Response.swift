//
//  Response.swift
//  GeideaPaymentSampleSwift
//
//  Created by euvid on 13/10/2020.
//

import Foundation

struct ResponseConstants {
    static let ErrorJson = "Unexpected error trying to parse Json"
}

class Response {
    
    var success = false
    var url: URL?
    var code: Int
    var error: NSError?
    var body: JSON?
    var data: Data?
    var headers: [String: String]?
    
    init(data: Data?, response: URLResponse?, error: NSError?) {
        self.data = data
        self.code = -1
        
        do {
            guard let response = response as? HTTPURLResponse else {
                throw error ?? NSError.unexpectedError()
            }
            
            self.url = response.url
            self.headers = response.allHeaderFields as? [String: String]
            self.code = response.statusCode
            
            guard data != nil else {
                throw NSError.unexpectedError(debugMessage: "data is nil", code: self.code)
            }
            
            let json = try data.map(JSON.dataToJson)
            guard let status = json?["status"]?.toBool() else {
                throw NSError.unexpectedError(debugMessage: ResponseConstants.ErrorJson)
            }
            
            self.success = status
            if self.success {
                self.body = json?["data"]
            } else {
//                self.error = ErrorManager().error(from: json)
            }
        } catch let error as NSError {
            self.success = false
            self.code = error.code
            self.error = error
        }
        
        self.logResponse()
    }
    
    
    // MARK: - Private Helpers
    
    fileprivate func logResponse() {
        guard GlobalConfig.shared.logLevel == .debug else { return }
        
        log("******** RESPONSE \(self.url?.path ?? "") ********")
        log(" - URL:\t" + self.logURL())
        log(" - CODE:\t" + "\(self.code)")
        self.logHeaders()
        log(" - DATA:\n" + self.logData())
        log("*************************\n")
    }
    
    fileprivate func logURL() -> String {
        guard let url = self.url?.absoluteString else {
            return "NO URL"
        }
        
        return url
    }
    
    fileprivate func logHeaders() {
        guard let headers = self.headers else { return }
        
        log(" - HEADERS: {")
        
        for key in headers.keys {
            if let value = headers[key] {
                log("\t\t\(key): \(value)")
            }
        }
        
        log("}")
    }
    
    fileprivate func logData() -> String {
        guard let data = self.data else {
            return "NO DATA"
        }
        
        guard let dataJson = try? JSON.dataToJson(data) else {
            return String(data: data, encoding: String.Encoding.utf8) ?? "Error parsing JSON"
        }
        
        return "GeideaPaymentSDK :: \(dataJson)"
    }
}
