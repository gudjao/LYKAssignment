//
//  GoogleModel.m
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import "GoogleModel.h"

@implementation GoogleMetadataModel

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
                                                                  @"sourceId" : @"source"
                                                                  }];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)setSourceIdWithNSDictionary:(NSDictionary *)dictionary {
    if([dictionary valueForKey:@"id"]) {
        self.sourceId = [dictionary valueForKey:@"id"];
    }
    if([dictionary valueForKey:@"type"]) {
        self.type = [dictionary valueForKey:@"type"];
    }
}

@end

@implementation GooglePhotoModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation GoogleNameModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation GooglePhoneModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation GoogleEmailModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation GoogleConnectionModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end

@implementation GoogleModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

@end
