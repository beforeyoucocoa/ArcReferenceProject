//
//  MTStubParser.h
//  MSTimes
//
//  Created by Matthew Wilkinson on 30/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Section.h"
#import "Article.h"
#import <CoreData/CoreData.h>

@interface MTStubParser : NSObject

#pragma mark - Simple Parser

/** Returns a simple clean array of NSDictionaries, that contain the section's for the section feed.
 *
 * @param xmlFeed, the XML of the sections feed
 */
+ (NSArray *)parseSectionXMLFeed:(NSData *)xmlFeed;

/** Returns a simple clean array of NSDictionaries, that contain the articles for the articles feed.
 *
 * @param xmlFeed, the XML of the article feed
 */
+ (NSArray *)parseArticlesXMLFeed:(NSData *)xmlFeed;

#pragma mark - Core Data Integration

/**  Recursively adds sections into the Core Data stack
 * 
 *  @param sectionData, a dictionary that has been returned by parseXMLFeed: that represents a section to be added to Core Data
 *  @param context, the managed object context we wish to add the section to
 *  @param parent, this may be nil, specifies the parent section, it must be in the same managed object context we wish to insert our child section to.
 */
+ (void)insertSectionData:(NSArray *)sectionData 
                inContext:(NSManagedObjectContext *)context
               withParent:(Section *)parent;


/** Adds articles for a given section feed
 * @param articlesData   The list of images returned by an enclosure
 * @param context  The context with which to store core data
 * @param parents
 */
+ (void)insertArticlesData:(NSArray *)articlesData 
                 inContext:(NSManagedObjectContext *)context
               withParents:(NSArray *)parents;

/** Stores images
 * @param arrayOfImages   The list of images returned by an enclosure
 * @param context  The context with which to store core data
 * @return Returns an NSSet of image objects that can be added to the media model
 */
+(NSSet*)storeImages:(id)arrayOfImages  
         withContext:(NSManagedObjectContext*)context;

@end
