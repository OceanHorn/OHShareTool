//
//  OHSNSCollectionViewCell.m
//  OHShareTool
//
//  Created by 郭玉富 on 16/2/23.
//  Copyright © 2016年 郭玉富. All rights reserved.
//

#import "OHSNSCollectionViewCell.h"

@interface OHSNSCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation OHSNSCollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseID = @"OHSNSCollectionViewCell";
    OHSNSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    if (cell == nil) {
        cell = [self new];
    }
    
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareUIComponent];
    }
    return self;
}

- (void)prepareUIComponent {
    self.backgroundColor =  [UIColor whiteColor];
    
    UIImageView *imageView = [UIImageView new];
    self.imageView = imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imageView];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
}

#pragma mark - setter
-(void)setChannel:(OHShareChannel *)channel {
    _channel = channel;
    self.imageView.image = channel.image;
}

@end

@implementation OHShareChannel

+ (instancetype)shareChannelWithImage:(UIImage *)image type:(OHShareType)type {
    OHShareChannel * channel = [self new];
    channel.image = image;
    channel.type = type;
    return channel;
}

@end
