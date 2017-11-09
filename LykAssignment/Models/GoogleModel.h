//
//  GoogleModel.h
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol GooglePhotoModel;
@protocol GoogleNameModel;
@protocol GooglePhoneModel;
@protocol GoogleEmailModel;
@protocol GoogleConnectionModel;

@interface GoogleMetadataModel : JSONModel

@property (nonatomic) BOOL primary;
@property (nonatomic) NSString *sourceId;
@property (nonatomic) NSString *type;
    
@end

@interface GooglePhotoModel : JSONModel

@property (nonatomic) NSString *url;

@end

@interface GoogleNameModel : JSONModel

@property (nonatomic) GoogleMetadataModel *metadata;
@property (nonatomic) NSString *givenName;
@property (nonatomic) NSString *displayName;
@property (nonatomic) NSString *familyName;
@property (nonatomic) NSString *displayNameLastFirst;

@end

@interface GooglePhoneModel : JSONModel

@property (nonatomic) NSString *value;
@property (nonatomic) NSString *formattedType;

@end

@interface GoogleEmailModel : JSONModel

@property (nonatomic) NSString *value;

@end

@interface GoogleConnectionModel : JSONModel

@property (nonatomic) NSArray <GooglePhotoModel> *photos;
@property (nonatomic) NSArray <GoogleNameModel> *names;
@property (nonatomic) NSArray <GooglePhoneModel> *phoneNumbers;
@property (nonatomic) NSArray <GoogleEmailModel> *emailAddresses;
@property (nonatomic) NSString *etag;
@property (nonatomic) NSString *resourceName;

@end

@interface GoogleModel : JSONModel

@property (nonatomic) NSArray <GoogleConnectionModel> *connections;
@property (nonatomic) int totalPeople;
@property (nonatomic) int totalItems;
@property (nonatomic) NSString *nextPageToken;

@end

