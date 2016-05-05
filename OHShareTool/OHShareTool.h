//
//  OHShareTool.h
//  OHShareTool
//
//  Created by 郭玉富 on 16/3/29.
//  Copyright © 2016年 郭玉富. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OHShareType.h"

@interface OHShareContent : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *shareURL;
@property (nonatomic, copy) NSString *imageURL;

@end


@class OHShareTool;
typedef void (^ShareBlock)(OHShareType type);
typedef OHShareContent *(^AdjustableShareBlock)(OHShareType type, OHShareContent *shareContent);


@interface OHShareTool : NSObject

+ (instancetype)sharedTool;

/**
 *  普通分享方法，视分享平台不同，有些字段可能无法分享成功，则需使用shareWithDelegate:adjustContent:
 *
 *  @param title    分享标题
 *  @param text     分享内容
 *  @param shareURL 分享目标链接
 *  @param imageURL 图片URL地址，为空则显示默认图片
 *  @param vc       友盟分享的代理，需要视情况实现代理方法
 */
- (void)shareTitle:(NSString *)title text:(NSString *)text shareURL:(NSString *)shareURL imageURL:(NSString *)imageURL delegate:(id)vc;

/**
 *  需要根据平台改变分享内容的分享方法
 *
 *  @param vc                友盟分享的代理，需要视情况实现代理方法
 *  @param shareSettingblock 至少传入shareObject的title或text属性
 */
- (void)shareWithDelegate:(id)vc adjustContent:(AdjustableShareBlock)adjustableShareBlock;

@end
