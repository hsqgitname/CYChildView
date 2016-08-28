//
//  SXTitleLable.m
//  85 - 网易滑动分页
//
//  Created by 董 尚先 on 15-1-31.
//  Copyright (c) 2015年 shangxianDante. All rights reserved.
//

#import "SXTitleLable.h"

@implementation SXTitleLable {
        UIView *topLine;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        self.scale = 0.0;
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont systemFontOfSize:18];
        self.font = [UIFont fontWithName:@"HYQiHei" size:17];

        
        
//        topLine = [[UIView alloc] initWithFrame:
//                   CGRectMake(20, frame.size.height-2, frame.size.width-40, 2)];
//        topLine.backgroundColor = [UIColor blackColor];
//        topLine.layer.cornerRadius = 1;//圆角
//        topLine.alpha = 0;
//        [self addSubview:topLine];
        
        
    }
    return self;
}

/** 通过scale的改变改变多种参数 */
- (void)setScale:(CGFloat)scale{
    _scale = scale;
//    topLine.alpha = scale;
    
    self.textColor = [UIColor colorWithRed:0.2 green:scale*0.2 blue:scale*0.5 alpha:1];
    
    CGFloat minScale = 0.9;
    CGFloat trueScale = minScale + (1-minScale)*scale;
    
    self.transform = CGAffineTransformMakeScale(trueScale, trueScale);
    
    
    
}

@end
