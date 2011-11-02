//
//  MTStubParser.m
//  MSTimes
//
//  Created by Matthew Wilkinson on 30/08/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MTStubParser.h"
#import "XMLReader.h"
#import "Article.h"
#import "SectionOrder.h"
#import "Image.h"
#import "LogMacro.h"

@implementation MTStubParser

NSInteger sectionSerial = 0;

// Returns an array of NSDictionaries for the section feed.
+ (NSArray *)parseSectionXMLFeed:(NSData *)xmlFeed
{
    NSDictionary *xml = [XMLReader dictionaryForXMLData:xmlFeed 
                                                  error:nil];
    NSArray *sections = [[xml objectForKey:@"sections"] objectForKey:@"section"];
    
    return sections;
}

// Returns an array of NSDictionaries for the articles feed.
+ (NSArray *)parseArticlesXMLFeed:(NSData *)xmlFeed
{
    NSError *error = nil;
    
    //Get XML into dictionary format
    NSDictionary *feedDictionary = [XMLReader dictionaryForXMLData:xmlFeed 
                                                             error:&error];
    
    //Get the array inside of the dictionary (sections array)
    NSArray *array = [[[feedDictionary objectForKey:@"rss"] objectForKey:@"channel"] objectForKey:@"item"];
    
    return array;
}

+ (void)insertSectionData:(NSArray *)sectionData 
                inContext:(NSManagedObjectContext *)context
               withParent:(Section *)parent
{
    for (NSDictionary *sectionDictionary in sectionData) 
    {
        
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:[NSEntityDescription entityForName:@"Section" 
                                       inManagedObjectContext:context]];
        //asking core data for sections that match the title, to check for duplications, this is recursively called
//        [request setPredicate:[NSPredicate predicateWithFormat:@"sectionTitle == %@",[sectionDictionary objectForKey:@"title"]]];
        //if we do a request according to the title then we will not read in the sections below topstories as they have duplicate titles...although data gets repeated in the coredata, so we should change the feed really...
        [request setPredicate:[NSPredicate predicateWithFormat:@"rssID == %@",[sectionDictionary objectForKey:@"id"]]];
        
        //incorrect way of populating core data by using a non unique section title, instead we should use the ID
        //[request setPredicate:[NSPredicate predicateWithFormat:@"sectionTitle == %@",[sectionDictionary objectForKey:@"title"]]];
        
        //this request predicate checks for duplicates in core data, CountForfetch request is  a better performance way, does not fetch data just does a count to make it quicker
        NSUInteger count = [context countForFetchRequest:request 
                                                   error:nil];
        // Create a new section
        Section *section = nil;
        
        //No duplicates so create a new section, count is zero first time so we create a new section
        if (count == 0) 
        {
            section = [NSEntityDescription insertNewObjectForEntityForName:@"Section"
                                                    inManagedObjectContext:context];
        }
        //if section already exists then count is not zero
        else
        {
            //now do more expensive fetch request to get back first class models, instance of sections
            NSArray *results = [context executeFetchRequest:request 
                                                      error:nil];//use the error handling instead of setting to nil
            //Sanity check, given that count is greater than zero should be same
            if ([results count] > 0) 
            {
                //this should always happen
                //We get the section out of core data that already exists and then we set it to our temporary section so we can update it
                section = [results lastObject];
            }
            else
            {
                // Problem
                abort();
            }
        }
        
        // Set its properties OR update the section that already exists
        [section setColor:[sectionDictionary objectForKey:@"color"]];
        [section setIcon:[sectionDictionary objectForKey:@"icon"]];
        [section setRssID:[sectionDictionary objectForKey:@"id"]];
        [section setSectionTitle:[sectionDictionary objectForKey:@"title"]];
        [section setRssPath:[sectionDictionary objectForKey:@"rssPath"]];
        [section setSerial:[NSNumber numberWithInt:++sectionSerial]];
        //[section setSerial:++sectionSerial];
        
        // Configure its parent (optional)
        [section setParent:parent];
        
        // Configure its child nodes
        if ([sectionDictionary objectForKey:@"section"]) 
        {
            [MTStubParser insertSectionData:[sectionDictionary objectForKey:@"section"] 
                                  inContext:context 
                                 withParent:section];
        }
    }
}

+ (void)insertArticlesData:(NSArray *)articlesData 
                 inContext:(NSManagedObjectContext *)context
               withParents:(NSArray *)parents
{
    // configure a dateformatter
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
    // Reset the default orders for each section
    for (Section *parentSection in parents) 
    {
        NSFetchRequest *resetRequest = [[[NSFetchRequest alloc] init] autorelease];
        
        [resetRequest setEntity:[NSEntityDescription entityForName:@"SectionOrder" 
                                            inManagedObjectContext:context]];
        
        //Each managed object context has a graph of objects, objects have objectID, made distinct by this so...
        //Here objectID same across contexts but objects are different, so we want to get a seciton for ID across contexts, so we can find that section in two different contexts
        Section *movedParentSection = (Section *)[context objectWithID:[parentSection objectID]];
        
        [resetRequest setPredicate:[NSPredicate predicateWithFormat:@"section == %@",movedParentSection]];
        
        NSUInteger orderCount = [context countForFetchRequest:resetRequest 
                                                        error:nil];
        
        //Found a seciton so need to reset an order of articles, so we are resetting the order of the articles
        if (orderCount > 0) 
        {
            NSArray *results = [context executeFetchRequest:resetRequest 
                                                      error:nil];
            
            for (SectionOrder *order in results) 
            {
                [context deleteObject:order];
            }
        }
    }
    
    int order = 1;
    
    for (NSDictionary *articleData in articlesData) 
    {
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:[NSEntityDescription entityForName:@"Article" 
                                       inManagedObjectContext:context]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"articleID == %@",[articleData objectForKey:@"guid"]]];
        
        //this request predicate checks for duplicates in core data
        NSUInteger count = [context countForFetchRequest:request 
                                                   error:nil];
        Article *article = nil;
        
        //No duplicates so create a new section
        if (count > 0) {
            // Duplicate found
            article = [[context executeFetchRequest:request error:nil] lastObject];
        }
        else {
            // Create a new article
            article = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                    inManagedObjectContext:context];
        }
        
        // remove leading spaces from date
        NSString *trimmedDate = [[articleData objectForKey:@"pubDate"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDate *pubdate = [dateFormatter dateFromString:trimmedDate];
        
        [article setArticleID:[articleData objectForKey:@"guid"]];
        [article setAuthor:[articleData objectForKey:@"author"]];
        [article setDateLastUpdated:pubdate];
        [article setPubDate:pubdate];
        [article setStandFirst:[articleData objectForKey:@"standfirst"]];
        [article setStoryBody:[articleData objectForKey:@"tol-text:story"]];
        [article setTitle:[articleData objectForKey:@"shortTitle"]];
        [article setSectionTitleL1:[articleData objectForKey:@"section-l1"]];
        [article setSectionTitleL2:[articleData objectForKey:@"section-l2"]];
        [article setSectionTitleL3:[articleData objectForKey:@"section-l3"]];
        
        //check if there are enclosures or images associated with the story
        NSMutableArray *enclosures = [articleData objectForKey:@"enclosure"];
        if (enclosures && [enclosures count] > 0){
            [article setMedias:[self storeImages:[articleData objectForKey:@"enclosure"] withContext:context]];
        } else {
            DebugLog(@"No enclosure found for article with title %@", article.title);
        }
        
        //Building the order of sections
        for (Section *section in parents) 
        {
            //Getting the section witht the objectID across contexts
            Section *movedSection = (Section *)[context objectWithID:[section objectID]];
            
            //adding the section to that article
            [article addSectionsObject:movedSection];
            
            
            NSFetchRequest *orderRequest = [[[NSFetchRequest alloc] init] autorelease];
            
            //create order request using the sectionorder table
            [orderRequest setEntity:[NSEntityDescription entityForName:@"SectionOrder" 
                                                inManagedObjectContext:context]];
            //find articles that equal articles and sections that equal the section, won't find anything the first time. So we know to create a new sectionORder
            [orderRequest setPredicate:[NSPredicate predicateWithFormat:@"article == %@ AND section == %@",article,section]];
            
            //less expensive order count request
            NSUInteger orderCount = [context countForFetchRequest:orderRequest 
                                                            error:nil];
            
            SectionOrder *sectionOrder = nil;
            
            //if zero then create section order
            if (orderCount == 0) 
            {
                //create object for seciton order
                sectionOrder = [NSEntityDescription insertNewObjectForEntityForName:@"SectionOrder"
                                                             inManagedObjectContext:context];
                //add the section to sectionORder
                [sectionOrder setSection:movedSection];
                //add moved article to the sectionORder
                [sectionOrder setArticle:article];
            }
            //if does exist then we update it
            else
            {
                sectionOrder = [[context executeFetchRequest:request error:nil] lastObject];
            }
            //then here set order of that instance
            [sectionOrder setDefaultOrder:[NSNumber numberWithInt:order]];
        }
        
        order += 1;
    }
}

+(NSSet*)storeImages:(id)arrayOfImages  
         withContext:(NSManagedObjectContext*)context
{    
    //set used to store all the images
    NSMutableSet *media = [NSMutableSet set];
    
    //If there is only one image in the article then the feed returns this as a dictionary, else if there are more than one
    //then the feed returns this as and array which we can enumerate as below, we must check which one though
    if([arrayOfImages isKindOfClass:[NSArray class]])
    {
        //enumerate array of images
        for (NSDictionary *imagesDict in arrayOfImages) 
        {
            NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
            [request setEntity:[NSEntityDescription entityForName:@"Image" 
                                           inManagedObjectContext:context]];
            
            //this request predicate checks for duplicates in core data
            [request setPredicate:[NSPredicate predicateWithFormat:@"fileURL == %@",[imagesDict objectForKey:@"url"]]];
            NSUInteger count = [context countForFetchRequest:request 
                                                       error:nil];
            Image *image = nil;
            
            if (count > 0) {
                // Duplicate found
                NSArray *results = [context executeFetchRequest:request 
                                                          error:nil];
                //
                if ([results count] > 0) 
                {
                    image = [results lastObject];
                    
                }
                else
                {
                    // Problem
                    abort();
                }
            }
            else {
                // Create a new Image
                image = [NSEntityDescription insertNewObjectForEntityForName:@"Image"
                                                      inManagedObjectContext:context]; 
            }
            
            //cut off last 5 characters of URL
            NSString *url = [[imagesDict objectForKey:@"url"] substringWithRange:NSMakeRange(0, [[imagesDict objectForKey:@"url"] length]-5)];
            //add the prefix .jpg so we have a certain type of image
            url = [url stringByAppendingString:@".jpg"];
            //store this ammended URL
            [image setFileURL:url];
            
            [image setCaption:[imagesDict objectForKey:@"caption"]];
            [image setImageCredit:[imagesDict objectForKey:@"tol-text:imagecredit"]];
            
            // Converts our string from core data to an nsnumber
            NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * articleID = [numberFormatter numberFromString:[imagesDict objectForKey:@"length"]];
            [numberFormatter release];
            [image setSizeInBytes:articleID];
            
            [image setMimeType:[imagesDict objectForKey:@"type"]];
            //add image to set
            [media addObject:image];
        }
    }
    
    //Only one image, feed gives us a dictionary, so just get the elements from the dictionary and store it
    if([arrayOfImages isKindOfClass:[NSDictionary class]])
    {
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:[NSEntityDescription entityForName:@"Image" 
                                       inManagedObjectContext:context]];
        
        //this request predicate checks for duplicates in core data
        [request setPredicate:[NSPredicate predicateWithFormat:@"fileURL == %@",[arrayOfImages objectForKey:@"url"]]];
        NSUInteger count = [context countForFetchRequest:request 
                                                   error:nil];
        Image *image = nil;
        
        if (count > 0) {
            // Duplicate found
            NSArray *results = [context executeFetchRequest:request 
                                                      error:nil];
            //
            if ([results count] > 0) 
            {
                image = [results lastObject];
                
            }
            else
            {
                // Problem
                abort();
            }
        }
        else {
            // Create a new Image
            image = [NSEntityDescription insertNewObjectForEntityForName:@"Image"
                                                  inManagedObjectContext:context]; 
        }
        
        //cut off last 5 characters of URL
        NSString *url = [[arrayOfImages objectForKey:@"url"] substringWithRange:NSMakeRange(0, [[arrayOfImages objectForKey:@"url"] length]-5)];
        //add the prefix .jpg so we have a certain type of image
        url = [url stringByAppendingString:@".jpg"];
        //store this ammended URL
        [image setFileURL:url];
        
        [image setCaption:[arrayOfImages objectForKey:@"caption"]];
        [image setImageCredit:[arrayOfImages objectForKey:@"tol-text:imagecredit"]];
        
        // Converts our string from core data to an nsnumber
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * articleID = [numberFormatter numberFromString:[arrayOfImages objectForKey:@"length"]];
        [numberFormatter release];
        [image setSizeInBytes:articleID];
        
        [image setMimeType:[arrayOfImages objectForKey:@"type"]];
        //add image to set
        [media addObject:image];
    }
    return media;
}

@end
