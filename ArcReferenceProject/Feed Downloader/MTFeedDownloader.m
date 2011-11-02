//
//  MTFeedDownloader.m
//  MSTimes
//
//  Created by Digital Sol on 23/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <ASIHTTPRequestIOS/ASIHTTPRequest.h>
#import "MSCoreDataInterface.h"
#import "MTFeedDownloader.h"
#import "MTStubParser.h"
#import "LogMacro.h"

#define kMTFeedDownloader_FeedUrl @"http://m.apps.thetimes.co.uk/config/ios/1.0b/sections.xml"

@interface MTFeedDownloader (PrivateMethods)

- (NSManagedObjectContext *)createTemporaryManagedObjectContext;

- (void)mergeSections:(NSNotification *)mergeNotification;

-(void)parseSectionsData:(NSData*)responseData 
               withBlock:(MTFeedDownloaderSuccess)successBlock
                 failure:(MTFeedDownloaderFailure)failureBlock
           withinContext:tmpCtx;

-(void)parseTopStoriesData:(NSData*)responseData 
               withBlock:(MTFeedDownloaderSuccess)successBlock
                 failure:(MTFeedDownloaderFailure)failureBlock
           withinContext:tmpCtx;

-(void)parseSectionContentData:(NSData*)responseData 
                 parentSection:(Section*)parentSection
                     withBlock:(MTFeedDownloaderSuccess)successBlock
                       failure:(MTFeedDownloaderFailure)failureBlock 
                 withinContext:tmpCtx;

-(void)updateSectionContent:(Section*)aSection
                  withBlock:(MTFeedDownloaderSuccess)successBlock
                    failure:(MTFeedDownloaderFailure)failureBlock 
              withinContext:tmpCtx;

-(void)syncContext:(NSManagedObjectContext*)ctx;

@end

@implementation MTFeedDownloader

@synthesize _queue;
@synthesize _successBlock;
@synthesize _failureBlock;

static MTFeedDownloader *sharedScheduler = NULL;

+ (MTFeedDownloader *)sharedDownloader
{    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (sharedScheduler == NULL) 
            sharedScheduler = [[MTFeedDownloader allocWithZone:NULL] init];
    });
    
    return sharedScheduler;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self._queue setMaxConcurrentOperationCount:1];
    }
    
    return self;
}

-(void)dealloc {
    [_successBlock release];
    [_failureBlock release];    
    
    [super dealloc];
}

-(void)downloadFeedWithSuccess:(MTFeedDownloaderSuccess)successBlock 
                       failure:(MTFeedDownloaderFailure)failureBlock {
    
    self._successBlock=successBlock;
    self._failureBlock=failureBlock;
    
    // create tmp context to create all objects representing latest feed
    NSManagedObjectContext *tmpCtx=[self createTemporaryManagedObjectContext];
    
    NSURL *url = [NSURL URLWithString:kMTFeedDownloader_FeedUrl];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    
    if (!error) {
        NSData *responseData = [request responseData];
        [self parseTopStoriesData:responseData 
                      withBlock:successBlock 
                        failure:failureBlock 
                  withinContext:tmpCtx];
        DebugLog(@"Sections parsed");
        [self syncContext:tmpCtx];
    } else {
        NSError *error = [request error];
        failureBlock(error); 
    }
}

-(void)downloadFullFeedWithSuccess:(MTFeedDownloaderSuccess)successBlock 
                       failure:(MTFeedDownloaderFailure)failureBlock {
    
    self._successBlock=successBlock;
    self._failureBlock=failureBlock;
    
    // create tmp context to create all objects representing latest feed
    NSManagedObjectContext *tmpCtx=[self createTemporaryManagedObjectContext];
    
    NSURL *url = [NSURL URLWithString:kMTFeedDownloader_FeedUrl];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    
    if (!error) {
        NSData *responseData = [request responseData];
        [self parseSectionsData:responseData 
                      withBlock:successBlock 
                        failure:failureBlock 
                  withinContext:tmpCtx];
        DebugLog(@"Sections parsed");
        [self syncContext:tmpCtx];
    } else {
        NSError *error = [request error];
        failureBlock(error); 
    }
}

@end

@implementation MTFeedDownloader (PrivateMethods)

-(void)syncContext:(NSManagedObjectContext*)ctx {
    //
    // now when all the section are parsed
    // tmpCtx can be merged with datastore to make
    // the changes alive
    //
    // the way to do it is to register for NSManagedObjectContextDidSaveNotification
    // and then trigger save on tmpCtx
    // inside notification handler you can call merge method.
    //
    // merge core data context via notification
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mergeSections:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:ctx];
    
    NSError *error;
    if(![ctx save:&error])
    {
        ErrorLog(@"Error saving data");
    }
}

- (NSManagedObjectContext *)createTemporaryManagedObjectContext
{
    NSManagedObjectContext *result = [[[NSManagedObjectContext alloc] init] autorelease];
    MSCoreDataInterface *interface = [MSCoreDataInterface defaultInterface]; 
    [result setPersistentStoreCoordinator:[interface persistentStoreCoordinator]];
    [result setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    return result;
}

-(void)parseTopStoriesData:(NSData*)responseData 
               withBlock:(MTFeedDownloaderSuccess)successBlock
                 failure:(MTFeedDownloaderFailure)failureBlock 
           withinContext:tmpCtx {
 
    // nsdictionaries with section details
    NSArray *sectionsDicts=[MTStubParser parseSectionXMLFeed:responseData];

    // save section dictionaries in core data
    [MTStubParser insertSectionData:sectionsDicts inContext:tmpCtx withParent:nil];
    
    // query core data to retrieve section objects
    NSArray *sections=[[MSCoreDataInterface defaultInterface] sectionsWithContext:tmpCtx];
    for (Section *section in sections) 
    {
        if ([[section sectionTitle] isEqualToString:@"Top Stories"])
        {
            // Send a job to update this section
            [self updateSectionContent:section
                             withBlock:successBlock 
                               failure:failureBlock 
                         withinContext:tmpCtx];
        }
    }
}

-(void)parseSectionsData:(NSData*)responseData 
               withBlock:(MTFeedDownloaderSuccess)successBlock
                 failure:(MTFeedDownloaderFailure)failureBlock 
           withinContext:tmpCtx {
    
    // nsdictionaries with section details
    NSArray *sectionsDicts=[MTStubParser parseSectionXMLFeed:responseData];
    
    // save section dictionaries in core data
    [MTStubParser insertSectionData:sectionsDicts inContext:tmpCtx withParent:nil];
    
    // query core data to retrieve section objects
    NSArray *sections=[[MSCoreDataInterface defaultInterface] sectionsWithContext:tmpCtx];
    
    // iterate over sections and fetch articles
    for (Section *section in sections) 
    {
        [self updateSectionContent:section
                         withBlock:successBlock 
                           failure:failureBlock 
                     withinContext:tmpCtx];
    }
}

-(void)updateSectionContent:(Section*)aSection
                  withBlock:(MTFeedDownloaderSuccess)successBlock
                    failure:(MTFeedDownloaderFailure)failureBlock 
              withinContext:tmpCtx {

    //DebugLog(@"---- Updating Section: %@",aSection.sectionTitle);
    
    NSString *rssPath=[aSection rssPath];
    if(rssPath!=nil) {
        NSURL *url = [NSURL URLWithString:rssPath];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        
        NSMutableDictionary *headers=[[NSMutableDictionary alloc] init];
        [headers setObject:@"7RPejQ4YJcG4Ezm"
                    forKey:@"X-NewsInternational-Times-Token"];
        [request setRequestHeaders:headers];
        [headers release];
        
        [request startSynchronous];
        
        NSError *error = [request error];
        if (!error) {
            NSData *responseData = [request responseData];
            [self parseSectionContentData:responseData
                            parentSection:aSection
                                withBlock:successBlock
                                  failure:failureBlock
                            withinContext:tmpCtx];
        } else {
            //DebugLog(@"Problem downloading url: %@",rssPath);
            NSError *error = [request error];
            failureBlock(error); 
        }
    } else {
        // do nothing ?
        ErrorLog(@"***WARNING: section [%@] with nil rssPath. No articles to download",aSection.sectionTitle);
    }
}

-(void)parseSectionContentData:(NSData*)responseData 
                 parentSection:(Section*)parentSection
                     withBlock:(MTFeedDownloaderSuccess)successBlock
                       failure:(MTFeedDownloaderFailure)failureBlock 
                 withinContext:tmpCtx {
    // nsdictionaries with articles
    NSArray *articles=[MTStubParser parseArticlesXMLFeed:responseData];

    //DebugLog(@"Section [%@] has [%i] articles",parentSection.sectionTitle, [articles count]);
    
    // save articles in core data
    [MTStubParser insertArticlesData:articles 
                           inContext:tmpCtx 
                         withParents:[NSArray arrayWithObject:parentSection]];
}

- (void)mergeSections:(NSNotification *)mergeNotification
{
    [[[MSCoreDataInterface defaultInterface] managedObjectContext] mergeChangesFromContextDidSaveNotification:mergeNotification];  
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSError *error;
        if([[[MSCoreDataInterface defaultInterface] managedObjectContext] save:&error]) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            if(_successBlock) _successBlock();
        } else {
            if(_failureBlock) _failureBlock(error);
        }
    });
}

@end
