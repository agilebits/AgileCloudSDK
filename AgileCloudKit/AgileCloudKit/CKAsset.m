//
//  CKAsset.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>
#import "CKAsset_Private.h"
#import "CKDatabase_Private.h"
#import "Defines.h"

@interface CKAsset () <NSURLSessionDelegate>

@end

@implementation CKAsset {
    NSString *_downloadURL;
    NSString *_fileChecksum;
    NSString *_referenceChecksum;
    NSUInteger _fileSize;
    NSString *_wrappingKey;
    NSString *_receipt;
    NSURLSessionDownloadTask *_downloadTask;
    NSError *_downloadError;

    dispatch_semaphore_t _downloadSema;
    void (^_progressBlock)(double);
}

static NSOperationQueue *_downloadQueue;


+ (NSOperationQueue *)downloadQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 1;
    });
    return _downloadQueue;
}

- (instancetype)init
{
    if (self = [super init]) {
        _downloadSema = dispatch_semaphore_create(0);
    }
    return self;
}

- (NSError *)downloadError
{
    return _downloadError;
}

/* Initialize an asset to be saved with the content at the given file URL */
- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    if (self = [super init]) {
        _fileURL = fileURL;
        _downloadSema = dispatch_semaphore_create(0);
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _fileURL = nil;
        _downloadURL = dictionary[@"downloadURL"];
        _downloadSema = dispatch_semaphore_create(0);
        [self updateWithDictionary:dictionary];
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    _fileChecksum = dictionary[@"fileChecksum"];
    _referenceChecksum = dictionary[@"referenceChecksum"];
    _fileSize = [dictionary[@"size"] unsignedIntegerValue];
    _wrappingKey = dictionary[@"wrappingKey"];
    _receipt = dictionary[@"receipt"];
}

- (NSString *)fileChecksum
{
    return _fileChecksum;
}

- (NSString *)referenceChecksum
{
    return _referenceChecksum;
}

- (NSUInteger)fileSize
{
    return _fileSize;
}

- (NSString *)wrappingKey
{
    return _wrappingKey;
}

- (NSString *)receipt
{
    return _receipt;
}

#pragma mark - Downloading

- (void)downloadSynchronouslyWithProgressBlock:(void (^)(double progress))progressBlock
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:[CKAsset downloadQueue]];
    NSString *esc = [_downloadURL stringByReplacingOccurrencesOfString:@"{" withString:@"%7B"];
    esc = [esc stringByReplacingOccurrencesOfString:@"}" withString:@"%7D"];
    NSURL *downloadURL = [NSURL URLWithString:esc];
    if (downloadURL && !_fileURL) {
        _progressBlock = progressBlock;
        _downloadTask = [session downloadTaskWithRequest:[NSURLRequest requestWithURL:downloadURL]];
        [_downloadTask resume];
        dispatch_semaphore_wait(_downloadSema, DISPATCH_TIME_FOREVER);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // Calculate Progress
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    if (_progressBlock)
        _progressBlock(progress);
}

- (void)URLSession:(NSURLSession *)session
                 downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location
{
    _progressBlock = nil;
    _fileURL = location;
    _downloadError = nil;
    dispatch_semaphore_signal(_downloadSema);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        _progressBlock = nil;
        _downloadError = error;
        _fileURL = nil;
    }
    dispatch_semaphore_signal(_downloadSema);
}

#pragma mark - Uploading


- (void)uploadSynchronouslyIntoRecord:(CKRecord *)record andField:(NSString *)fieldName inDatabase:(CKDatabase *)database
{
    DebugLog(@"uploading into %@ at %@", record.recordID, fieldName);

    NSDictionary *requestDictionary = @{};
    [database sendPOSTRequestTo:@"assets/upload" withJSON:requestDictionary completionHandler:^(id jsonResponse, NSError *error) {
        DebugLog(@"uploaded prepped: %@", jsonResponse);
    }];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"[CKAsset: %@]", self.fileURL];
}

@end
