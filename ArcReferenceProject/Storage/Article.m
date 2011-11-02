//
//  Article.m
//  MarioDemo
//
//  Created by Ben Smith on 12/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Article.h"
#import "Media.h"
#import "Section.h"
#import "SectionOrder.h"


@implementation Article
@dynamic author;
@dynamic sectionTitleL3;
@dynamic pubDate;
@dynamic articleID;
@dynamic sectionTitleL1;
@dynamic title;
@dynamic dateLastUpdated;
@dynamic standFirst;
@dynamic storyBody;
@dynamic sectionTitleL2;
@dynamic medias;
@dynamic sections;
@dynamic sectionOrders;

- (void)addMediasObject:(Media *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"medias" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"medias"] addObject:value];
    [self didChangeValueForKey:@"medias" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeMediasObject:(Media *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"medias" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"medias"] removeObject:value];
    [self didChangeValueForKey:@"medias" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addMedias:(NSSet *)value {    
    [self willChangeValueForKey:@"medias" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"medias"] unionSet:value];
    [self didChangeValueForKey:@"medias" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeMedias:(NSSet *)value {
    [self willChangeValueForKey:@"medias" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"medias"] minusSet:value];
    [self didChangeValueForKey:@"medias" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addSectionsObject:(Section *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sections"] addObject:value];
    [self didChangeValueForKey:@"sections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSectionsObject:(Section *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sections"] removeObject:value];
    [self didChangeValueForKey:@"sections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSections:(NSSet *)value {    
    [self willChangeValueForKey:@"sections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"sections"] unionSet:value];
    [self didChangeValueForKey:@"sections" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSections:(NSSet *)value {
    [self willChangeValueForKey:@"sections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"sections"] minusSet:value];
    [self didChangeValueForKey:@"sections" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addSectionOrdersObject:(SectionOrder *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sectionOrders" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sectionOrders"] addObject:value];
    [self didChangeValueForKey:@"sectionOrders" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSectionOrdersObject:(SectionOrder *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"sectionOrders" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"sectionOrders"] removeObject:value];
    [self didChangeValueForKey:@"sectionOrders" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSectionOrders:(NSSet *)value {    
    [self willChangeValueForKey:@"sectionOrders" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"sectionOrders"] unionSet:value];
    [self didChangeValueForKey:@"sectionOrders" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSectionOrders:(NSSet *)value {
    [self willChangeValueForKey:@"sectionOrders" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"sectionOrders"] minusSet:value];
    [self didChangeValueForKey:@"sectionOrders" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
