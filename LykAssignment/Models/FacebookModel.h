//
//  FacebookModel.h
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 08/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol FacebookDataModel;

@interface FacebookSummaryModel : JSONModel

@property (nonatomic) int total_count;

@end

@interface FacebookDataModel : JSONModel

@property (nonatomic) NSString *dataId;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *pictureUrl;

@end

@interface FacebookCursorModel : JSONModel

@property (nonatomic) NSString *after;
@property (nonatomic) NSString *before;

@end

@interface FacebookModel : JSONModel

@property (nonatomic) FacebookSummaryModel *summary;
@property (nonatomic) NSArray <FacebookDataModel> *data;
@property (nonatomic) FacebookCursorModel *paging;

@end
