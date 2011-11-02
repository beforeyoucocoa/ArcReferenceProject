//
//  Section.m
//  MSTimes
//
//  Created by Ben Smith on 28/09/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Section.h"
#import "Article.h"
#import "Section.h"
#import "SectionOrder.h"


@implementation Section
@dynamic sectionTitle;
@dynamic color;
@dynamic rssPath;
@dynamic icon;
@dynamic rssID;
@dynamic serial;
@dynamic parent;
@dynamic articles;
@dynamic children;
@dynamic sectionOrders;


- (void)addArticlesObject:(Article *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"articles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"articles"] addObject:value];
    [self didChangeValueForKey:@"articles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeArticlesObject:(Article *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"articles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"articles"] removeObject:value];
    [self didChangeValueForKey:@"articles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addArticles:(NSSet *)value {    
    [self willChangeValueForKey:@"articles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"articles"] unionSet:value];
    [self didChangeValueForKey:@"articles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeArticles:(NSSet *)value {
    [self willChangeValueForKey:@"articles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"articles"] minusSet:value];
    [self didChangeValueForKey:@"articles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addChildrenObject:(Section *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"children" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"children"] addObject:value];
    [self didChangeValueForKey:@"children" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeChildrenObject:(Section *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"children" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"children"] removeObject:value];
    [self didChangeValueForKey:@"children" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addChildren:(NSSet *)value {    
    [self willChangeValueForKey:@"children" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"children"] unionSet:value];
    [self didChangeValueForKey:@"children" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeChildren:(NSSet *)value {
    [self willChangeValueForKey:@"children" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"children"] minusSet:value];
    [self didChangeValueForKey:@"children" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}



@end
