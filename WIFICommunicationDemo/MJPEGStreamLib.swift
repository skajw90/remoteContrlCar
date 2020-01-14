//
//  MJPEGStreamLib.swift
//  WIFICommunicationDemo
//
//  Created by Jiwon Nam on 10/8/19.
//  Copyright © 2019 Jiwon Nam. All rights reserved.
//

import UIKit

open class MJPEGStreamLib: NSObject, URLSessionDataDelegate {
    
    fileprivate enum StreamStatus {
        case stop
        case loading
        case play
    }
    
    fileprivate var receivedData: NSMutableData?
    fileprivate var dataTask: URLSessionDataTask?
    fileprivate var session: Foundation.URLSession!
    fileprivate var status: StreamStatus = .stop
    
    open var authenticationHandler: ((URLAuthenticationChallenge) -> (Foundation.URLSession.AuthChallengeDisposition, URLCredential?))?
    open var didStartLoading: (()->Void)?
    open var didFinishLoading: (()->Void)?
    open var contentURL: URL?
    open var imageView: UIImageView
    
    public init(imageView: UIImageView) {
        self.imageView = imageView
        super.init()
        self.session = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    public convenience init(imageView: UIImageView, contentURL: URL) {
        self.init(imageView: imageView)
        self.contentURL = contentURL
    }
    
    deinit {
        dataTask?.cancel()
    }
    
    // Play function with url parameter
    open func play(url: URL){
        // Checking the status for it is already playing or not
        if status == .play || status == .loading {
            stop()
        }
        contentURL = url
        play()
    }
    
    // Play function without URL paremeter
    open func play() {
        guard let url = contentURL , status == .stop else {
            return
        }
        
        status = .loading
        DispatchQueue.main.async { self.didStartLoading?() }
        
        receivedData = NSMutableData()
        let request = URLRequest(url: url)
        dataTask = session.dataTask(with: request)
        dataTask?.resume()
    }
    
    // Stop the stream function
    open func stop(){
        status = .stop
        dataTask?.cancel()
    }
    
    // NSURLSessionDataDelegate
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // Controlling the imageData is not nil
        if let imageData = receivedData {
            let receivedImage = UIImage(data: imageData as Data) 
            if status == .loading {
                status = .play
                DispatchQueue.main.async { self.didFinishLoading?() }
            }
            // Set the imageview as received stream
            DispatchQueue.main.async { self.imageView.image = receivedImage
                self.imageView.setNeedsDisplay()
            }
        }
        print(response)
        print(dataTask)
        receivedData = NSMutableData()
        completionHandler(.allow)
    }
    
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData?.append(data)
    }
}
