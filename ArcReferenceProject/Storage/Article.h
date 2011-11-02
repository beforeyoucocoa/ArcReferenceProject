//
//  Article.h
//  MarioDemo
//
//  Created by Anurag Kapur on 04/10/2011.
//  Copyright (c) 2011 News International. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media, Section, SectionOrder;

@interface Article : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * dateLastUpdated;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * storyBody;
@property (nonatomic, retain) NSString * articleID;
@property (nonatomic, retain) NSString * standFirst;
@property (nonatomic, retain) NSString * sectionTitleL1;
@property (nonatomic, retain) NSString * sectionTitleL2;
@property (nonatomic, retain) NSString * sectionTitleL3;
@property (nonatomic, retain) NSSet *medias;
@property (nonatomic, retain) NSSet *sections;
@property (nonatomic, retain) NSSet *sectionOrders;
@end

@interface Article (CoreDataGeneratedAccessors)

- (void)addMediasObject:(Media *)value;
- (void)removeMediasObject:(Media *)value;
- (void)addMedias:(NSSet *)values;
- (void)removeMedias:(NSSet *)values;
- (void)addSectionsObject:(Section *)value;
- (void)removeSectionsObject:(Section *)value;
- (void)addSections:(NSSet *)values;
- (void)removeSections:(NSSet *)values;
- (void)addSectionOrdersObject:(SectionOrder *)value;
- (void)removeSectionOrdersObject:(SectionOrder *)value;
- (void)addSectionOrders:(NSSet *)values;
- (void)removeSectionOrders:(NSSet *)values;
@end
