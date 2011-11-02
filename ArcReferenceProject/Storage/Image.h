//
//  Image.h
//  MSTimes
//
//  Created by Ben Smith on 26/09/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Media.h"


@interface Image : Media {
@private
}
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSNumber * sizeInBytes;
@property (nonatomic, retain) NSString * imageCredit;
@property (nonatomic, retain) NSString * mimeType;

@end
