//בעזרת ה׳ החונן לאדם דעת
//  AWSS3Provider.swift
//  Jabrutouch
//
//  Created by Yoni Reiss on 13/09/2017.
//  Copyright © 2017 Ravtech. All rights reserved.
//

import Foundation
import AWSS3

enum AWSAuthenticationType {
    case unauthenticated, staticAuthentication, dynamicAuthentication
}
class AWSS3Provider {

    static let appAWSRegion: AWSRegionType = .USWest2
    // AWS credentials are loaded from AWSConfig.swift
    // The actual config file should not be committed to git
    static let appAccessKey: String = AWSConfig.accessKeyId
    static let appSecretKey: String = AWSConfig.secretAccessKey
    static let appS3BaseUrl = AWSConfig.s3BaseUrl
    static let appS3BucketName = AWSConfig.s3BucketName

    /**
        The singleton instance holder
     */
    private static var manager: AWSS3Provider?
    
    /**
        A client to be used for publicly accessed resources. Used for querys on resources.
     */
    private var unauthenticatedS3Client: AWSS3!
    /**
        A client to be used for resources requiring authentication. Used for querys on resources.
     */
    private var authenticatedS3Client: AWSS3!
    private var staticAuthenticatedS3Client: AWSS3!
    /**
        Used for downloading and updloading files.
     */
    private var transferUtility: AWSS3TransferUtility!

    private var pendingDownloadTasks: [String: (task: AWSS3TransferUtilityDownloadTask?, progressBlock: AWSS3TransferUtilityProgressBlock, completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock)] = [:]
    
    private init(region: AWSRegionType) {
        // Register unauthenticated S3 client
        let anonymousCredentialsProvider = AWSAnonymousCredentialsProvider()
        let unauthenticatedServiceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: anonymousCredentialsProvider)
        AWSS3.register(with: unauthenticatedServiceConfiguration!, forKey: "defaultPublicS3")
        self.unauthenticatedS3Client = AWSS3.s3(forKey: "defaultPublicS3")

        // Register authenticated transfer manager
        AWSS3TransferUtility.register(with: unauthenticatedServiceConfiguration!, forKey: "deaultTransferManager")
        self.transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "deaultTransferManager")
    }

    private init(region: AWSRegionType, accessKey: String, secretKey: String) {
        // Register unauthenticated S3 client
        let staticCredentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let staticAuthenticatedServiceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: staticCredentialsProvider)
        AWSS3.register(with: staticAuthenticatedServiceConfiguration!, forKey: "staticS3")
        self.staticAuthenticatedS3Client = AWSS3.s3(forKey: "staticS3")

        // Register authenticated transfer manager
        AWSS3TransferUtility.register(with: staticAuthenticatedServiceConfiguration!, forKey: "staticTransferManager")
        self.transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "staticTransferManager")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    private init(region: AWSRegionType, identityPoolId: String, identityProviderManager: AWSIdentityProviderManager) {

        // Register unauthenticated S3 client
        let anonymousCredentialsProvider = AWSAnonymousCredentialsProvider()
        let unauthenticatedServiceConfiguration = AWSServiceConfiguration(region: region, credentialsProvider: anonymousCredentialsProvider)
        AWSS3.register(with: unauthenticatedServiceConfiguration!, forKey: "publicS3")
        self.unauthenticatedS3Client = AWSS3.s3(forKey: "publicS3")

        // Register authenticated S3 client
        let cognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: region, identityPoolId: identityPoolId, identityProviderManager: identityProviderManager)
        let authenticatedServiceConfiguration = AWSServiceConfiguration(region:region, credentialsProvider:cognitoCredentialsProvider)
        AWSS3.register(with: authenticatedServiceConfiguration!, forKey: "authenticatedS3")
        self.authenticatedS3Client = AWSS3.s3(forKey: "authenticatedS3")

        // Register authenticated transfer manager
        AWSS3TransferUtility.register(with: authenticatedServiceConfiguration!, forKey: "transferManager")
        self.transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: "transferManager")
    }

    class var shared: AWSS3Provider {
        if self.manager == nil {
            self.manager = AWSS3Provider(region: self.appAWSRegion, accessKey: self.appAccessKey, secretKey: self.appSecretKey)
        }
        return self.manager!
    }

    /**
        Handles file download from S3.
     - parameter fileName: The name of the file.
     - parameter bucketName: The name of the bucket in which the file is stored.
     - parameter progressBlock: A callback excecuted periodacally during the download. Can be used to display progress to the user. Holding data regarding progress of the download.
     - parameter successCompletion: A callback excecuted after a successful download. Holding the downloaded data.
     - parameter errorCompletion: A callback excecuted in case download has failed. Holds an error object representing the error that have occured if one could be found.
     */
    func handleFileDownload(fileName:String,bucketName:String, progressBlock:((_ fileName: String, _ progress: Progress)->Void)?, completion: @escaping (_ result:
        Result<Data,Error>)->Void ){

        
//        let _fileName = self.extractFilenameFromLinkIfNeeded(filename: fileName)
        let progressBlock: AWSS3TransferUtilityProgressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) in
            progressBlock?(fileName,progress)
        }
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = progressBlock
        let completionHandler = { (task:AWSS3TransferUtilityDownloadTask, url: URL?, data: Data?, error: Error?) in
            self.pendingDownloadTasks.removeValue(forKey: fileName)
            if let _error = error {
                completion(.failure(_error))
            }
                
            else if let _data = data{
                completion(.success(_data))
            }
            else {
                completion(.failure(JTError.unknown))
            }
        }
        
        let task = self.transferUtility.downloadData(fromBucket: bucketName, key: fileName, expression: expression, completionHandler: completionHandler).result
        self.pendingDownloadTasks[fileName] = (task,progressBlock,completionHandler)
    }

    /**
        Helper method to extract the file name from the end of a URL
     - parameter fileName: The full url containing the file name.
     */

    private func extractFilenameFromLinkIfNeeded(filename: String) -> String {
        if let url = URL(string: filename) {
            return url.lastPathComponent
        }
        return filename
    }

    /**
     Handles file upload from S3.
     - parameter fileUrl: URL of the file in the local file system.
     - parameter fileName: The name of the file.
     - parameter bucketName: The name of the bucket to which the file is uploaded.
     - parameter progressBlock: A callback excecuted periodacally during the upload. Can be used to display progress to the user. Holding data regarding progress of the upload.
     - parameter successCompletion: A callback excecuted after a successful upload. Holding the file name.
     - parameter errorCompletion: A callback excecuted in case upload has failed. Holds an error object representing the error that have occured if one could be found.
     */

    func handleFileUpload(fileUrl: URL, fileName:String, contentType:String, bucketName:String, progressBlock:((_ progress: Progress)->Void)?, completion: ((_ result: Result<String, Error>)->Void)?){

        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) in
            progressBlock?(progress)
        }
        let task = self.transferUtility.uploadFile(fileUrl, bucket: bucketName, key: fileName, contentType: contentType, expression: expression) { (task: AWSS3TransferUtilityUploadTask, error: Error?) in
            if let _error = error {
                completion?(.failure(_error))
            }
                
            else {
                completion?(.success(fileName))
            }
        }.result
        
//        print("upload task: \(task)")
    }

    /**
        Maked a head object request, that returns metadata of that object, regarding the content type, size , last modified etc.
     - parameter fileName: The name of the file.
     - parameter bucketName: The name of the bucket in which the file is stored.
     - parameter authType: An indicator whether this file has public access or not, by which to determine the client to be used.
     - parameter successCompletion: A callback excecuted after a successful request. Holding the object metadata.
     - parameter errorCompletion: A callback excecuted in case request has failed. Holds an error object representing the error that have occured if one could be found.
     */
    func handleHeadObjectRequest(fileName:String,bucketName:String, authType: AWSAuthenticationType,completion:((_ result: Result<AWSS3HeadObjectOutput, Error>)->Void)?){

        let headRequest = self.createHeadObjectRequest(fileName: fileName, bucketName: bucketName)

        var s3 : AWSS3?
        switch authType {
        case .unauthenticated:
            s3 = self.unauthenticatedS3Client
        case .dynamicAuthentication:
            s3 = self.authenticatedS3Client
        case .staticAuthentication:
            s3 = self.staticAuthenticatedS3Client
        }

        s3?.headObject(headRequest).continueWith { (task:AWSTask<AWSS3HeadObjectOutput>) -> Any? in
            if let error = task.error {
                completion?(.failure(error))
        }
            else if let result = task.result {
                completion?(.success(result))
            }
            else {
                completion?(.failure(JTError.unknown))
            }
            return true
        }

    }

    func handleHeadBucketRequest(bucketName:String, authType: AWSAuthenticationType,completion:((_ result: Result<Void, Error>)->Void)? ) {

        let headRequest = self.createHeadBucketRequest(bucketName: bucketName)

        var s3 : AWSS3?
        switch authType {
        case .unauthenticated:
            s3 = self.unauthenticatedS3Client
        case .dynamicAuthentication:
            s3 = self.authenticatedS3Client
        case .staticAuthentication:
            s3 = self.staticAuthenticatedS3Client
        }

        s3?.headBucket(headRequest).continueOnSuccessWith(block: { (task) -> Any? in
            if let error  = task.error {
               completion?(.failure(error))
            }
            else {
               completion?(.success(()))
            }
            return nil
        })

    }
    
    /**
        Helper method to create object head request
     - parameter fileName: The name of the file.
     - parameter bucketName: The name of the bucket to which the file is uploaded.
     */
    private func createHeadObjectRequest(fileName:String, bucketName: String)->AWSS3HeadObjectRequest{
        let headRequest = AWSS3HeadObjectRequest()!
        headRequest.key = fileName
        headRequest.bucket =  bucketName
        return headRequest
    }

    /**
     Helper method to create bucket head request
     - parameter bucketName: The name of the bucket to which the file is uploaded.
     */
    private func createHeadBucketRequest(bucketName: String)->AWSS3HeadBucketRequest{
        let headRequest = AWSS3HeadBucketRequest()!
        headRequest.bucket =  bucketName
        return headRequest
    }
    
    @objc func applicationWillEnterForeground() {
        for task in self.pendingDownloadTasks.values {
            task.task?.setProgressBlock(task.progressBlock)
            task.task?.setCompletionHandler(task.completionHandler)            
        }
    }
}