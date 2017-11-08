//
//  ListCellNode.m
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import "ListCellNode.h"

@implementation ListCellNode {
    NSDictionary *_attrsNameText;
    NSDictionary *_attrsOtherText;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.automaticallyManagesSubnodes = YES;
        
        self.profileImageNode = [[ASNetworkImageNode alloc] init];
        self.profileImageNode.placeholderColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
        self.profileImageNode.imageModificationBlock = ASImageNodeRoundBorderModificationBlock(0.0f, nil);
        
        // Attrs
        _attrsNameText = @{
                           NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0f],
                           NSForegroundColorAttributeName : [UIColor flatBlackColorDark]
                           };
        
        _attrsOtherText = @{
                            NSFontAttributeName : [UIFont systemFontOfSize:15.0f],
                            NSForegroundColorAttributeName : [UIColor flatBlackColor]
                            };
        
        _nameTextNode = [[ASTextNode alloc] init];
        _nameTextNode.maximumNumberOfLines = 2;
        
        _emailTextNode = [[ASTextNode alloc] init];
        _emailTextNode.maximumNumberOfLines = 1;
        
        _phoneTextNode = [[ASTextNode alloc] init];
        _phoneTextNode.maximumNumberOfLines = 1;
        
        _inviteButtonNode = [[ASButtonNode alloc] init];
        [_inviteButtonNode setTitle:@"Invite"
                           withFont:[UIFont boldSystemFontOfSize:14.0f]
                          withColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
        _inviteButtonNode.backgroundColor = [UIColor flatBlueColor];
        _inviteButtonNode.hitTestSlop = UIEdgeInsetsMake(-5, -10, -5, -10);
        _inviteButtonNode.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        _inviteButtonNode.cornerRadius = 4.0f;
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    // Image
    ASRatioLayoutSpec *ratioProfileImage = [ASRatioLayoutSpec ratioLayoutSpecWithRatio:1.0f
                                                                                 child:self.profileImageNode];
    ratioProfileImage.style.flexBasis = ASDimensionMakeWithFraction(0.18f);
    ratioProfileImage.style.minWidth = ASDimensionMake(40.0f);
    ratioProfileImage.style.maxWidth = ASDimensionMake(100.0f);
    
    // Text
    ASStackLayoutSpec *stackEmailPhone = [ASStackLayoutSpec
                                          stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                          spacing:10.0f
                                          justifyContent:ASStackLayoutJustifyContentStart
                                          alignItems:ASStackLayoutAlignItemsStretch
                                          children:@[self.phoneTextNode,
                                                     self.emailTextNode]];
    
    ASStackLayoutSpec *stackNameWithEmailPhone = [ASStackLayoutSpec
                                                  stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                  spacing:10.0f
                                                  justifyContent:ASStackLayoutJustifyContentStart
                                                  alignItems:ASStackLayoutAlignItemsStretch
                                                  children:@[self.nameTextNode,
                                                             stackEmailPhone]];
    
    // Content
    ASLayoutSpec *spacer = [ASLayoutSpec new];
    spacer.style.flexGrow = 1.0f;
    
    ratioProfileImage.style.alignSelf = ASStackLayoutAlignSelfCenter;
    self.inviteButtonNode.style.alignSelf = ASStackLayoutAlignSelfCenter;
    stackNameWithEmailPhone.style.flexShrink = 1.0f;
    
    ASStackLayoutSpec *stackMain = [ASStackLayoutSpec
                                    stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                    spacing:10.0f
                                    justifyContent:ASStackLayoutJustifyContentStart
                                    alignItems:ASStackLayoutAlignItemsStretch
                                    children:@[ratioProfileImage,
                                               stackNameWithEmailPhone,
                                               spacer,
                                               self.inviteButtonNode]];
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(10, 15, 10, 15)
                                                  child:stackMain];
}

// Name
- (void)setNameText:(NSString *)nameText {
    if (ASObjectIsEqual(_nameText, nameText)) return;
    
    _nameText = [nameText copy];
    
    if (_nameText == nil || _nameText.length == 0) {
        _nameTextNode.attributedText = [[NSAttributedString alloc] initWithString:@"<Unknown Name>"
                                                                       attributes:_attrsNameText];
        [self setNeedsLayout];
        return;
    }
    
    _nameTextNode.attributedText = [[NSAttributedString alloc] initWithString:self.nameText
                                                                   attributes:_attrsNameText];
    [self setNeedsLayout];
}

// Email
- (void)setEmailText:(NSString *)emailText {
    if (ASObjectIsEqual(_emailText, emailText)) return;
    
    _emailText = [emailText copy];
    
    if (_emailText == nil) {
        _emailTextNode.attributedText = nil;
        return;
    }
    
    _emailTextNode.attributedText = [[NSAttributedString alloc] initWithString:self.emailText
                                                                    attributes:_attrsOtherText];
    [self setNeedsLayout];
}

// Phone
- (void)setPhoneText:(NSString *)phoneText {
    if (ASObjectIsEqual(_phoneText, phoneText)) return;
    
    _phoneText = [phoneText copy];
    
    if (_phoneText == nil) {
        _phoneTextNode.attributedText = nil;
        return;
    }
    
    _phoneTextNode.attributedText = [[NSAttributedString alloc] initWithString:self.phoneText
                                                                    attributes:_attrsOtherText];
    [self setNeedsLayout];
}

@end
