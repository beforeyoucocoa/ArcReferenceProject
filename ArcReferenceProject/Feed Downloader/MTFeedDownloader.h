//
//  MTFeedDownloader.h
//  MSTimes
//
//  Created by Digital Sol on 23/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void(^MTFeedDownloaderSuccess)(void);
typedef void(^MTFeedDownloaderFailure)(NSError* error);


@interface MTFeedDownloader : NSObject {
    NSOperationQueue        *_queue;
    MTFeedDownloaderSuccess _successBlock;
    MTFeedDownloaderFailure _failureBlock;
}

@property(nonatomic,copy) MTFeedDownloaderSuccess _successBlock;
@property(nonatomic,copy) MTFeedDownloaderFailure _failureBlock;


+ (MTFeedDownloader *)sharedDownloader;

-(void)downloadFeedWithSuccess:(MTFeedDownloaderSuccess)successBlock 
                       failure:(MTFeedDownloaderFailure)failureBlock;

-(void)downloadFullFeedWithSuccess:(MTFeedDownloaderSuccess)successBlock 
                       failure:(MTFeedDownloaderFailure)failureBlock;

@property(nonatomic,assign) NSOperationQueue *_queue;

@end
