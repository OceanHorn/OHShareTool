//
//  OHSNSCollectionViewCell.h
//  OHShareTool
//
//  Created by 郭玉富 on 16/2/23.
//  Copyright © 2016年 郭玉富. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHShareType.h"

#define kSNSCellWidth 40
#define kSNSCellHeight 40

@interface OHShareChannel : NSObject

@property (strong, nonatomic) UIImage *image;

@property (nonatomic, assign) OHShareType type;

+ (instancetype)shareChannelWithImage:(UIImage *)image type:(OHShareType)type;

@end

@interface OHSNSCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) OHShareChannel *channel;

//@property (nonatomic, copy) UIImage *shareImage;

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;


@end
