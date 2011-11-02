#import "MSCoreDataInterface.h"
#import "LogMacro.h"
#import "SectionOrder.h"
@implementation MSCoreDataInterface
static MSCoreDataInterface *defaultInstance = nil;

#pragma mark 
#pragma mark DEFAULT INSTANCE

- (NSArray *)sectionsWithContext:(NSManagedObjectContext*)ctx
{
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:[NSEntityDescription entityForName:@"Section" inManagedObjectContext:ctx]];
    
    return [ctx executeFetchRequest:request 
                                                                                        error:nil];
}
     
 - (NSArray *)articlesWithContext:(NSManagedObjectContext*)ctx
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:ctx]];
    
    return [ctx executeFetchRequest:request 
                                                                                        error:nil];
}

#pragma mark 
#pragma mark Sections   

- (NSArray *)sections
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:@"Section" inManagedObjectContext:[[MSCoreDataInterface defaultInterface] managedObjectContext]]];
    return [[[MSCoreDataInterface defaultInterface] managedObjectContext] executeFetchRequest:request 
                                                                                        error:nil];
}

- (NSArray *)rootSections;
{
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];    
    [request setEntity:[NSEntityDescription entityForName:@"Section" inManagedObjectContext:[[MSCoreDataInterface defaultInterface] managedObjectContext]]];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parent == NULL"];
    [request setPredicate:predicate];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"serial" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
    [sort release];
    [request setSortDescriptors:sortDescriptors];
    
    return [[[MSCoreDataInterface defaultInterface] managedObjectContext] executeFetchRequest:request error:nil];
}

- (NSArray *)subsectionsOfASectionInOrderWithRssID:(NSString *)sectionID{
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:@"Section" inManagedObjectContext:[[MSCoreDataInterface defaultInterface] managedObjectContext]]];

    [request setPredicate:[NSPredicate predicateWithFormat:@"rssID == %@",sectionID]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"serial" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
    [sort release];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *results = [[[MSCoreDataInterface defaultInterface] managedObjectContext] executeFetchRequest:request error:nil];
    
    return results;
}


- (NSArray *)childSectionsOfSubsectionsInOrder:(Section*)parentSection{
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:@"Section" inManagedObjectContext:[[MSCoreDataInterface defaultInterface] managedObjectContext]]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"parent == %@",parentSection]];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"serial" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject: sort];
    [sort release];
    [request setSortDescriptors:sortDescriptors];
    
    NSArray *results = [[[MSCoreDataInterface defaultInterface] managedObjectContext] executeFetchRequest:request error:nil];
    
    return results;
}

- (BOOL)isMainSectionByRSSID:(NSString*)rssID
{
    Section *tempSection = [self sectionWithRSSID:rssID];
    if(tempSection.parent == NULL)
        return TRUE;
    else
        return FALSE;
}

- (Section *)sectionWithRSSID:(NSString*)rssID
{
    NSError *error;
	NSManagedObjectContext *context = [[MSCoreDataInterface defaultInterface] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" 
											  inManagedObjectContext:context];
    
    NSPredicate *fetchPredicate = nil;
    fetchPredicate = [NSPredicate predicateWithFormat:@"rssID == %@",rssID];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:fetchPredicate];
    
	NSArray *fetchedSection = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
    
    if ([fetchedSection count] > 0)
    {
        return [fetchedSection objectAtIndex:0];
    }
    else
        return nil;
}

- (NSArray *)sectionWithArticleID:(NSString*)articleID
{
    NSError *error;
	NSManagedObjectContext *context = [[MSCoreDataInterface defaultInterface] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" 
											  inManagedObjectContext:context];
    
    NSPredicate *fetchPredicate = nil;
    fetchPredicate = [NSPredicate predicateWithFormat:@"articleID == %@",articleID];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:fetchPredicate];
    
	NSArray *fetchedArticle = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
    
    if ([fetchedArticle count] > 0)
    {
        Article *tempArticle = [fetchedArticle objectAtIndex:0];
        NSEnumerator *e = [[tempArticle.sections allObjects] objectEnumerator];
        Section *object;
        while (object = (Section*)[e nextObject]) {
            DebugLog(@"object.sectionTitle %@", object.sectionTitle);
            // do something with object
        }

        
//        for(NSArray *temp in [tempArticle.sections allObjects])
//        {
//            DebugLog(@"%@", [temp ]);
//        }
        return [tempArticle.sections allObjects];
    }
    else
        return nil;
}

/**
 * Get the section name by passing in the section RSSID
 * @param rssID   The RSSID that you need to pass in to get the section name returned
 * @return NSString    Section name that needs to be returned
 */
- (NSString*)sectionNameForSectionRSSID:(NSString*)rssID {
    NSError *error;
	NSManagedObjectContext *context = [[MSCoreDataInterface defaultInterface] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" 
											  inManagedObjectContext:context];
    
    NSPredicate *fetchPredicate = nil;
    fetchPredicate = [NSPredicate predicateWithFormat:@"rssID == %@",rssID];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:fetchPredicate];
    
	NSArray *fetchedSection = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
    
    
    if ([fetchedSection count] > 0)
    {
        Section *tempSection = [fetchedSection objectAtIndex:0];
        return tempSection.sectionTitle;
    }
    else
        return nil;
}

#pragma mark 
#pragma mark Image Retrieval

/**
 * Get first image returned for an article by passing in the article object and returning an HTTP string address for that picture
 * @param articleInQuestion   Article you require the image for
 * @return NSString    HTTP address for the image retrieved from the media object in core data
 */
- (NSString *)firstImageForArticle:(Article*)articleInQuestion{
    
    
    __block NSString *fileURL = nil;
    for (NSDictionary *mediaObject in [articleInQuestion medias]) {
        DebugLog(@"Media file URL :: %@",[(Image *)mediaObject fileURL]);
        fileURL = [(Image *)mediaObject fileURL];
        
        if(fileURL != nil) {
            return fileURL;
        }else {
            ErrorLog(@"No image for leading article of section :: %@ found", articleInQuestion.title);
        } 
    }
    
    NSString *placeHolder = [[NSBundle mainBundle] pathForResource:@"placeholder" ofType:@"png"];
    return placeHolder;
}

#pragma mark 
#pragma mark Article Retrieval
/**
 *  Get all articles in a specific section with the section ID
 * @param section   This is the section ID that you pass in
 * @return NSSet    The array of articles for that section
 */
- (NSArray*)articlesForASectionID:(NSString*)rssID {
    
    Section *temp =[self sectionWithRSSID:rssID];
    if(temp)
    {
        NSManagedObjectContext *context = [[MSCoreDataInterface defaultInterface] managedObjectContext];
        NSFetchRequest *ordersRequest= [[[NSFetchRequest alloc] init] autorelease];
        [ordersRequest setEntity:[NSEntityDescription entityForName:@"SectionOrder" 
                                             inManagedObjectContext:context]];
        [ordersRequest setPredicate:[NSPredicate predicateWithFormat:@"section == %@",temp]];
        [ordersRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"defaultOrder" 
                                                                                                 ascending:YES]]];
        NSArray *sectionOrders = [context executeFetchRequest:ordersRequest error:nil];
        NSArray *articles = [sectionOrders valueForKey:@"article"];
        
        return articles;
    }
    else
        return nil;
}

- (NSArray *)articles
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:[[MSCoreDataInterface defaultInterface] managedObjectContext]]];
    
    return [[[MSCoreDataInterface defaultInterface] managedObjectContext] executeFetchRequest:request error:nil];
}

- (Article *)articleByUUID:(NSString *)uuid
{
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:[[MSCoreDataInterface defaultInterface] managedObjectContext]]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"articleID == %@",uuid]];
    
    NSArray *results = [[[MSCoreDataInterface defaultInterface] managedObjectContext] executeFetchRequest:request error:nil];
    
    if (results.count > 0) 
    {
        return [results lastObject];
    }
    else
    {
        return nil;
    }   
}

- (Article *)topArticleForSection:(Section *)section
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:[NSEntityDescription entityForName:@"SectionOrder" inManagedObjectContext:[[MSCoreDataInterface defaultInterface] managedObjectContext]]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"section == %@",section]];
    
    NSArray *results = [[[MSCoreDataInterface defaultInterface] managedObjectContext] executeFetchRequest:request error:nil];
    
    if (results.count > 0) 
    {
        SectionOrder *order = [results lastObject];
        
        return [order article];
    }
    
    return nil;
}

- (NSArray *)topArticlesForSection:(Section *)section
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:[NSEntityDescription entityForName:@"SectionOrder" inManagedObjectContext:[[MSCoreDataInterface defaultInterface] managedObjectContext]]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"section == %@",section]];
    
    NSArray *results = [[[MSCoreDataInterface defaultInterface] managedObjectContext] executeFetchRequest:request error:nil];
    
    return results;
}

/**
 * Default global download manager.
 *
 * @return downloadManager Default global download manager
 */
+ (MSCoreDataInterface *)defaultInterface
{
	@synchronized([MSCoreDataInterface class]) // Synchronised to make thread safe
	{
		// Has global download manager been initialised?
		if (!defaultInstance)
		{
			// No, so initialise
			defaultInstance = [[MSCoreDataInterface alloc] init];
		}
	}
	
	return defaultInstance;
}

#pragma mark -
#pragma mark managedObjectModel methods

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel 
{    
    if (managedObjectModel_ != nil)
        return managedObjectModel_;
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"DataModel" 
                                                          ofType:@"momd"];
    
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"DataModel.db"]];
    NSLog(@"Database location: %@",[storeURL absoluteString]);
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType 
                                                  configuration:nil 
                                                            URL:storeURL 
                                                        options:nil 
                                                          error:&error]) 
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
    
    return persistentStoreCoordinator_;

}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
