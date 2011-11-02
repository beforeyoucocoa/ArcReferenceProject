//
//  Media.h
//  MSTimes
//
//  Created by Matthew Wilkinson on 06/09/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Article;

@interface Media : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * fileURL;
@property (nonatomic, retain) NSSet *articles;
@end

@interface Media (CoreDataGeneratedAccessors)

- (void)addArticlesObject:(Article *)value;
- (void)removeArticlesObject:(Article *)value;
- (void)addArticles:(NSSet *)values;
- (void)removeArticles:(NSSet *)values;
@end
