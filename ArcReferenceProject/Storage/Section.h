//
//  Section.h
//  MSTimes
//
//  Created by Ben Smith on 28/09/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article, Section, SectionOrder;

@interface Section : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * sectionTitle;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * rssPath;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * rssID;
//@property (assign) NSInteger serial;
@property (nonatomic, retain) NSNumber * serial;

@property (nonatomic, retain) Section * parent;
@property (nonatomic, retain) NSSet* articles;
@property (nonatomic, retain) NSSet* children;
@property (nonatomic, retain) SectionOrder * sectionOrders;

@end
