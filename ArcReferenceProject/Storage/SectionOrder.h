//
//  SectionOrder.h
//  MSTimes
//
//  Created by Matthew Wilkinson on 06/09/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article, Section;

@interface SectionOrder : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * defaultOrder;
@property (nonatomic, retain) Article *article;
@property (nonatomic, retain) Section *section;

@end