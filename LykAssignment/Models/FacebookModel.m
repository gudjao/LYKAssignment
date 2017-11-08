//
//  FacebookModel.m
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 08/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import "FacebookModel.h"

@implementation FacebookSummaryModel

@end

@implementation FacebookDataModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"dataId": @"id",
                                                                  @"pictureUrl" : @"picture"
                                                                  }];
}

- (void)setPictureUrlWithNSDictionary:(NSDictionary *)dictionary {
    NSDictionary *data = [dictionary objectForKey:@"data"];
    if([data valueForKey:@"url"]) {
        self.pictureUrl = [data objectForKey:@"url"];
    }
}

@end

@implementation FacebookCursorModel

@end

@implementation FacebookModel

- (void)setPagingWithNSDictionary:(NSDictionary *)dictionary {
    NSDictionary *cursors = [dictionary objectForKey:@"cursors"];
    
    self.paging = [[FacebookCursorModel alloc] init];
    self.paging.after = [cursors objectForKey:@"after"];
    self.paging.before = [cursors objectForKey:@"before"];
}

@end
