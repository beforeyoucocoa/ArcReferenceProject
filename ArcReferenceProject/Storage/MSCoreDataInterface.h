/**
 * A set of helper methods that act as an interface to core data.
 *
 * @author Ben Smith
 * @since 04/07/2011
 */
#import "Section.h"
#import "Article.h"
#import "Image.h"
#import "Video.h"
#import "Media.h"

@interface MSCoreDataInterface : NSObject 
{	
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

#pragma mark 
#pragma mark Section Retrieval
- (NSArray *)sections;

- (NSArray *)sectionsWithContext:(NSManagedObjectContext*)ctx;

- (NSArray *)rootSections;

/**
 * Gets all the subsections from a section with RSSID that is passed into the method of a section and returns them in order
 *
 * @param sectionID  This is the rssID of that section
 * @return array of subsections in order
 */
- (NSArray *)subsectionsOfASectionInOrderWithRssID:(NSString *)sectionID;

/**
 * Gets all the subsections of a section and returns them in order
 *
 * @param parentSection  This is the section that you want the children returned in order of
 * @return array of children of the subsections in the order they are fed into the feed
 */
- (NSArray *)childSectionsOfSubsectionsInOrder:(Section*)parentSection;

/**
 * Find out if a section is a main section or not by using the RSSID for that section, if it is then it will not have a parent and return TRUE, if it is not then it will and will return FALSE
 *
 */
- (BOOL)isMainSectionByRSSID:(NSString*)rssID;

/**
 * Get a section with an ID
 *
 */
- (Section *)sectionWithRSSID:(NSString*)rssID;

/**
 * Get an array of sections that an article belongs to by using the article ID
 * @param articleID   The article ID that you need to pass in to get the array of sections it belongs to
 * @return NSArray    Array of sections that the article belongs to
 */
- (NSArray *)sectionWithArticleID:(NSString*)articleID;

/**
 * Get the section name by passing in the section RSSID
 * @param rssID   The RSSID that you need to pass in to get the section name returned
 * @return NSString    Section name that needs to be returned
 */
- (NSString*)sectionNameForSectionRSSID:(NSString*)rssID;

#pragma mark 
#pragma mark Image Retrieval

/**
 * Get first image returned for an article by passing in the article object and returning an HTTP string address for that picture
 * @param articleInQuestion   Article you require the image for
 * @return NSString    HTTP address for the image retrieved from the media object in core data
 */
- (NSString *)firstImageForArticle:(Article*)articleInQuestion;

#pragma mark 
#pragma mark Article Retrieval
/**
 *  Get all articles in a specific section with the section ID
 * @param section   This is the section ID that you pass in
 * @return NSSet    The array of articles for that section
 */
- (NSArray*)articlesForASectionID:(NSString*)rssID;

- (NSArray *)articles;

- (NSArray *)articlesWithContext:(NSManagedObjectContext*)ctx;

- (Article *)articleByUUID:(NSString *)uuid;

- (Article *)topArticleForSection:(Section *)section;

- (NSArray *)topArticlesForSection:(Section *)section;

#pragma mark 
#pragma mark Default Instance

/**
 * Default global download manager.
 *
 * @return downloadManager Default global download manager
 */
+ (MSCoreDataInterface *)defaultInterface;


#pragma mark Context

- (NSString *)applicationDocumentsDirectory;

@end
