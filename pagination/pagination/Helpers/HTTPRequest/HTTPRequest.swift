//
//  HTTPRequest.swift
//  HTTPRequest
//
//  Created by Hardeep Singh on 11/20/16.
//  Copyright © 2016 Hardeep Singh. All rights reserved.
//

import UIKit
import Alamofire

enum NetworkError: Error {
    case noInternet
    var localizedDescription: String {
        switch self {
        case .noInternet:
            return "No internet connection"
        }
    }
}

struct HTTPDefalut {
    static var unauthorized: Int = 401
}

// MARK: - Response
public enum HTTPResponse {
    case success(Any)
    case failure(Error)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Any? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

// MARK: - File
struct CLFile: CustomStringConvertible {
    
    private(set) var name: String?
    private(set) var fileName: String?
    private(set) var mimeType: String?
    private(set) var data: Data?
    private(set) var url: URL?
    private(set) var type: AppendType?
    
    enum AppendType: Int {
        case type1
        case type2
        case type3
    }
    
    init(data: Data, name: String, fileName: String, mimeType: String) {
        self.type = .type1
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        self.data = data
    }
    
    init(url: URL, name: String, fileName: String, mimeType: String) {
        self.type = .type2
        self.url = url
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    init(url: URL, name: String) {
        self.type = .type3
        self.url = url
        self.name = name
    }
    
    func apendFile(mulitpartData: MultipartFormData) {
        
        if let type = type {
            
            switch type {
            case .type1:
                
                if let data = self.data, let name = self.name, let fileName = self.fileName, let mimeType = self.mimeType {
                    mulitpartData.append(data, withName: name, fileName: fileName, mimeType: mimeType)
                }
                break
            case .type2:
                if let url = self.url, let name = self.name, let fileName = self.fileName, let mimeType = self.mimeType {
                    mulitpartData.append(url, withName: name, fileName: fileName, mimeType: mimeType)
                }
                break
            case .type3:
                if let url = self.url, let name = self.name {
                    mulitpartData.append(url, withName: name)
                }
                break
            }
            
        }
        
    }
    
    var description: String {
        return "Name: \(String(describing: name)) fileName: \(String(describing: fileName)) mimeType: \(String(describing: mimeType)) data: \(String(describing: data))"
    }
    
}

struct HTTPModel: CustomStringConvertible {
    
    var statusCode: Int = -1
    var data: Data?
    var message: String = "Unknown message"
    
    var description: String {
        return "Data: {status: \(statusCode) message: \(message), data: \(String(describing: data)) }"
    }
    
    init?(representation: Any) {
        let representation = representation as? [String: Any]
        guard
            let message = representation?["message"],
            let status = representation?["statusCode"]
            else { return nil }
        
        if let data = representation?["data"] as? [String: Any] {
            do {
                self.data = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            } catch {
                print(error.localizedDescription)
            }
        }
        if let code = status as? Int {
            self.statusCode = code
        }
        
        if let msg = message as? String {
            self.message = msg
        }
    }
}

enum EncodingType {
    case json
    case url
    case propertyType
    func value() -> ParameterEncoding {
        switch self {
        case .json:
            return JSONEncoding.default
        case .url:
            return URLEncoding.default
        case .propertyType:
            return PropertyListEncoding.default
        }
    }
}

//public typealias HTTPRequestHandler = (_ response: Any?, Error?) -> Void
public typealias HTTPRequestHandler = (_ result: HTTPResponse) -> Void
public typealias HTTPTimelineHandler = (_ timeline: Timeline) -> Void

// MARK: -
extension Notification.Name {
    /// These notifications are sent out after the equivalent delegate message is called
    public struct HTTPRequestStatus {
        /// These notification will fire when access token expired or not valid.
        public static let unauthorized = Notification.Name(rawValue: "unauthorized")
    }
}
var language: String?

class HTTPRequest {
    
    public typealias HTTPEncodingCompletionHandler = (_ request: HTTPRequest) -> Void
    
    //Public
    //var language: String?
    class var baseURLString: String {
        return "https://reqres.in/api"
    }
    
    private var baseURL: URL?
    private var urlString: String?
    
    class var baseUrl: URL {
        if let url = URL(string: HTTPRequest.baseURLString) {
            return url
        }
        fatalError("HTTPRequest:- Base url issue")
    }
    
    private var isEnableCache: Bool = false
    private var successRange: Range = 200..<300
    
    private var methodType: Alamofire.HTTPMethod
    private var parameters: Parameters?
    private var encoding: ParameterEncoding
    private var headers = [String: String]()
    private var files: [CLFile]?
    private var isIndicatorEnable = true
    private var isAlertEnable = true
    private var isDataRequired = false // Pass Data in completion callBack if model conforms to codable or decodable protocols
    private(set) var timeline: Timeline?
    
    private var dataRequest: DataRequest?
    //private var uploadRequest: UploadRequest? = nil
    //private var downloadRequest: DownloadRequest? = nil
    
    //CallBack
    private var completionCallBack: HTTPRequestHandler?
    private var progressCallBack: HTTPRequestHandler?
    private var timelineCallBack: HTTPTimelineHandler?
    private var encodingCompletion: HTTPEncodingCompletionHandler?
    var networkManager: NetworkReachabilityManager?
    
    var sessionManager: Alamofire.SessionManager!
    
    // MARK: - END
    // MARK: - init
    init() {
        self.methodType = .get
        self.encoding = URLEncoding.default
        self.urlString = HTTPRequest.baseURLString
        
        //----
//        if let defaultHeaders: [String : String] = LoginManager.share.requestHeaders {
//            self.headers.appendDictionary(other: defaultHeaders)
//        }
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        
    }
    
    @discardableResult
    convenience init(method: Alamofire.HTTPMethod = .get,
                     fullURLStr: String,
                     parameters: Parameters? = nil,
                     encoding: EncodingType = .url,
                     files: [CLFile]? = nil) {
        self.init()
        self.urlString = fullURLStr
        self.methodType = method
        self.parameters = parameters
        self.files = files
        self.encoding = encoding.value()
    }
    
    convenience init(method: Alamofire.HTTPMethod = .get,
                     path: String,
                     parameters: Parameters? = nil,
                     encoding: EncodingType = .url,
                     files: [CLFile]? = nil) {
        self.init(method: method,
                  fullURLStr: "\(HTTPRequest.baseURLString)/\(path)",
            parameters: parameters,
            encoding: encoding,
            files: files)
    }
    
    class func request(method: Alamofire.HTTPMethod = .get,
                       path: String,
                       parameters: Parameters? = nil,
                       encoding: EncodingType = .url,
                       files: [CLFile]? = nil) -> HTTPRequest {
        return HTTPRequest(method: method, path: path, parameters: parameters, encoding: encoding, files: files)
    }
    
    // MARK: - Public Methods.
    @discardableResult
    func uploadEncodingCompletion(encodingCompletion: @escaping HTTPEncodingCompletionHandler) -> HTTPRequest {
        self.encodingCompletion = encodingCompletion
        return self
    }
    
    @discardableResult
    func headers(headers: [String: String]) -> HTTPRequest {
       // self.headers.appendDictionary(other: headers)
        return self
    }
    
    @discardableResult
    func removeAccessToken() -> HTTPRequest {
        self.headers["authorization"] = nil
        print(headers)
        return self
    }
    
    @discardableResult
    func config(isIndicatorEnable: Bool, isAlertEnable: Bool) -> HTTPRequest {
        self.isIndicatorEnable = isIndicatorEnable
        self.isAlertEnable = isAlertEnable
        return self
    }
    
    @discardableResult
    func encodingType(encoding: EncodingType) -> HTTPRequest {
        self.encoding = encoding.value()
        return self
    }
    
    @discardableResult
    func cache(enable: Bool) -> HTTPRequest {
        self.isEnableCache = enable
        return self
    }
    
    @discardableResult
    func requestTimeline(_ timeline: @escaping HTTPTimelineHandler) -> HTTPRequest {
        self.timelineCallBack = timeline
        return self
    }
    
    @discardableResult
    func setDataRequired() -> HTTPRequest {
        self.isDataRequired = true
        return self
    }
    
    // MARK: - Handler...
    func handler(httpModel: Bool = false, delay: TimeInterval = 0.0, completion: @escaping HTTPRequestHandler) {
        self.completionCallBack = completion
        
        if delay > 0 {
            self.startRequest(httpModelOn: httpModel)
        } else {
            self.startRequest(httpModelOn: httpModel)
        }
    }
    
    func multipartHandler(httpModel: Bool = false, delay: TimeInterval = 0.0, completion: @escaping HTTPRequestHandler) {
        self.completionCallBack = completion
        if delay > 0 {
            self.upload(httpModelOn: httpModel)
        } else {
            self.upload(httpModelOn: httpModel)
        }
    }
    
    // MARK: -
    class func removeAllCacheData() {
        URLCache.shared.removeAllCachedResponses()
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
        
    }
    
    // MARK: - Private Methods
    private func authorized(code: Int) -> Bool {
        if code == HTTPDefalut.unauthorized {
            //NotificationCenter.default.post(name: Notification.Name.HTTPRequestStatus.unauthorized, object: nil)
            return false
        }
        return true
    }
    
    private func showAlertMessage(message: String) {
//        if self.isAlertEnable == false {
//            return
//        }
//        UIAlertController.presentAlert(title: "", message: message, style: UIAlertControllerStyle.alert).action(title: "Ok".localized, style: UIAlertActionStyle.default) { (action: UIAlertAction) in
//        }
    }
    
    private func showAlertMessageWhenUnauthorized(message: String) {
        
    }
    
    private func showIndicator() {
        if self.isIndicatorEnable == false {
            return
        }
        ProgressHUD.present(animated: true)
    }
    
    private func hideIndicator() {
        ProgressHUD.dismiss(animated: true)
    }
    
    private func upload(httpModelOn: Bool) {
        
        guard let urlString = self.urlString else {
            fatalError("HTTPRequest:- URL string is not exist")
        }
        
        self.showIndicator()
        
        Alamofire.upload( multipartFormData: { [weak self] multipartFormData in
            
            //Append files
            if let files = self?.files {
                for file in files {
                    file.apendFile(mulitpartData: multipartFormData)
                }
            }
            
            //Append files
            if let parameters = self?.parameters {
                for (key, value) in parameters {
                    if value is [String : Any] || value is [Any] {
                        do {
                            
                            let data  = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted )
                            if  let jsonString: NSString = NSString(data: data, encoding: String.Encoding.utf8.rawValue), let data = jsonString.data(using: String.Encoding.utf8.rawValue) {
                                multipartFormData.append(data, withName: key)
                            }
                            
                        } catch {
                            print ("Error in parsing" )
                        }
                    } else {
                        if let data = "\(value)".data(using: String.Encoding.utf8) {
                            multipartFormData.append(data, withName: key)
                        }
                    }
                }
            }
            },
                          to: urlString,
                          method: self.methodType,
                          headers: self.headers,
                          encodingCompletion: { encodingResult in
                            
                            if let encodingCompletion = self.encodingCompletion {
                                encodingCompletion(self)
                            }
                            
                            switch encodingResult {
                                
                            case .success(let upload, _, _):
                                
                                self.dataRequest = upload
                                
                                if httpModelOn == true {
                                    //fatalError("HTTPModel is not availabel")
                                    if let dataRequest = self.dataRequest {
                                        dataRequest.responseJSON(completionHandler: { (response: DataResponse<Any>) in
                                            self.hideIndicator()
                                            switch response.result {
                                            case .success(_):
                                                print(response.result.value ?? "")
                                                if let value = response.result.value,
                                                    let httpModel = HTTPModel(representation: value) {
                                                    switch httpModel.statusCode {
                                                    case 200..<300:
                                                        if let data = httpModel.data {
                                                            self.completionCallBack?(HTTPResponse.success(data))
                                                        } else {
                                                            self.completionCallBack?(HTTPResponse.success(""))
                                                        }
                                                    default:
                                                        if httpModel.statusCode == 401 {
                                                            let error = self.errorWithDescription(description: "Session Expired.", code: httpModel.statusCode)
                                                            self.requestFailedWith(error: error)
                                                        } else {
                                                            let message = httpModel.message
                                                            let error = self.errorWithDescription(description: message, code: httpModel.statusCode)
                                                            self.requestFailedWith(error: error)
                                                        }
                                                    }
                                                }
                                            case .failure(let error):
                                                self.requestFailedWith(error: error)
                                            }
                                        })
                                    }
                                } else {
                                    upload.responseJSON { response in
                                        self.requestSucceededWith(response: response)
                                    }
                                }
                                
                            case .failure(let encodingError):
                                self.requestFailedWith(error: encodingError)
                            }
                            
        })
    }
    
    // MARK: - Cached URL Response
    private func storeURLResponse(response: DataResponse<Any>) {
        if self.methodType == .get && self.isEnableCache {
            if let resposne = response.response, let data = response.data ,
                let request = response.request {
                let cache = CachedURLResponse(response: resposne, data: data)
                URLCache.shared.storeCachedResponse(cache, for: request)
            }
        }
    }
    
    private func getCachedResponse() {
        
        guard let urlRequest = self.dataRequest?.request else {
            return
        }
        
        if !self.isEnableCache {
            URLCache.shared.removeCachedResponse(for: urlRequest)
            return
        }
        
        let cachedResponse = URLCache.shared.cachedResponse(for: urlRequest)
        let data = cachedResponse?.data
        if let urlContent = data {
            print(urlContent)
            do {
                let parsedData = try JSONSerialization.jsonObject(with: urlContent)
                print(parsedData)
                let result = HTTPResponse.success(parsedData)
                self.completionCallBack?(result)
            } catch {
                print("JSON serialization failed")
            }
        } else {
            print("ERROR FOUND HERE//No Cache data Found")
        }
    }
    
    //Start request...
    private func startRequest(httpModelOn: Bool) {
        
        guard let urlString = self.urlString else {
            fatalError("HTTPRequest:- URL is not exist")
        }
        
        self.showIndicator()
        print("------>", urlString)
        let dataRequest = Alamofire.request(urlString,
                                            method: self.methodType,
                                            parameters: self.parameters,
                                            encoding: self.encoding,
                                            headers: self.headers)
        
        self.dataRequest = dataRequest
        self.getCachedResponse()
        
        if httpModelOn == true {
            if let dataRequest = self.dataRequest {
                dataRequest.responseJSON(completionHandler: { (response: DataResponse<Any>) in
                    self.hideIndicator()
                    switch response.result {
                    case .success(_):
                        print(response.result.value ?? "")
                        if let value = response.result.value {
                            do {
                                var data: Data?
                                data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
                                self.completionCallBack?(HTTPResponse.success(data))
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    case .failure(let error):
                        self.requestFailedWith(error: error)
                    }
                })
            }
        } else {
            
            if let dataRequest = self.dataRequest {
                dataRequest.responseJSON(completionHandler: { (response: DataResponse<Any>) in
                    
                    self.timeline = response.timeline
                    if let timeLine = self.timeline {
                        if let timelineCallBack = self.timelineCallBack {
                            timelineCallBack(timeLine)
                        }
                    }
                    
                    switch response.result {
                        
                    case .success(_):
                        self.storeURLResponse(response: response)
                        self.requestSucceededWith(response: response)
                        
                    case .failure(let error):
                        self.requestFailedWith(error: error)
                    }
                })
            }
        }
    }
    
    private func requestSucceededWith(response: DataResponse<Any>) {
        //TODO: After Success simple request.
        self.hideIndicator()
        if let value = response.result.value {
            let response = HTTPResponse.success(value)
            self.completionCallBack?(response)
        }
    }
    
    private func requestFailedWith(error: Error) {
        
        self.hideIndicator()
        
        let message: String = error.localizedDescription
        
        guard self.authorized(code: (error as NSError).code) else {
            let result = HTTPResponse.failure(error)
            if (error as NSError).code == 401 {
                showAlertMessageWhenUnauthorized(message: message)
            }
            self.completionCallBack?(result)
            return
        }
        
        showAlertMessage(message: message)
        let result = HTTPResponse.failure(error)
        self.completionCallBack?(result)
        
    }
    
    private func errorWithDescription(description: String, code: Int) -> Error {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: "app", code: code, userInfo: userInfo) as Error
    }
}
