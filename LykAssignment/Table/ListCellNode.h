//
//  ListCellNode.h
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <ChameleonFramework/Chameleon.h>

@interface ListCellNode : ASCellNode

@property (strong, nonatomic) ASNetworkImageNode *profileImageNode;

@property (strong, nonatomic, readonly) ASTextNode *nameTextNode;

@property (strong, nonatomic, readonly) ASTextNode *emailTextNode;
@property (strong, nonatomic, readonly) ASTextNode *phoneTextNode;

@property (nonatomic, copy) NSString *nameText;
@property (nonatomic, copy) NSString *emailText;
@property (nonatomic, copy) NSString *phoneText;

@property (strong, nonatomic) ASButtonNode *inviteButtonNode;

@end
