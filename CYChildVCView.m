//
//  CYChildVCView.m
//  ChildVCDemo
//
//  Created by Fly on 16/4/14.
//  Copyright © 2016年 Fly. All rights reserved.
//

#import "CYChildVCView.h"
#import "SXTitleLable.h"
#import "CYChildController.h"

#define labelWidth 100//标题的宽度
#define labelHight 30//标题高度
#define bottomWidth 50//标题底部横线长度


@interface CYChildVCView () <UIScrollViewDelegate> {
    NSUInteger index;
    NSMutableArray *titleArr;
    UIScrollView *smallScroll;
    UIScrollView *bigScroll;
    UIView *bottomLine;
    CGRect selfFrame;
}

@end

@implementation CYChildVCView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        selfFrame = frame;
        #pragma mark 布局页面
        //日期栏scrollView背景
        smallScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, selfFrame.size.width, labelHight)];
        smallScroll.backgroundColor = [UIColor whiteColor];
        smallScroll.showsHorizontalScrollIndicator = NO;
        smallScroll.showsVerticalScrollIndicator = NO;
        [self addSubview:smallScroll];
        
        //主页面scrollView背景
        bigScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, labelHight, selfFrame.size.width, selfFrame.size.height-labelHight)];
        bigScroll.showsHorizontalScrollIndicator = NO;
        bigScroll.showsVerticalScrollIndicator = NO;
        [self addSubview:bigScroll];
        bigScroll.delegate =self;
        
        //底部分割线
        UIView *longLine = [[UIView alloc] initWithFrame:CGRectMake(0, labelHight-0.5, selfFrame.size.width, 0.5)];
        longLine.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:longLine];
    }
    return self;
}


#pragma mark 设置子控制器
- (void)setControllers:(NSArray *)controllers {
    _controllers = controllers;
    [smallScroll.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [bigScroll.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addTopSmallScrolTitleLables];
    [self addBigScrollViewControllers];
}

#pragma mark 根据数组添加标题
- (void)addTopSmallScrolTitleLables {
    titleArr = [NSMutableArray array];
    smallScroll.contentSize = CGSizeMake(labelWidth * _controllers.count, 0);
    
    for (int i = 0; i < _controllers.count; i++) {
        CGRect lblFrame =CGRectMake(labelWidth*i, -0, labelWidth, labelHight);
        SXTitleLable *lbl = [[SXTitleLable alloc]initWithFrame:lblFrame];
        lbl.text = ((UIViewController *)self.controllers[i]).title;
        lbl.userInteractionEnabled = YES;
        lbl.tag = i;
        [titleArr addObject:lbl];
        [smallScroll addSubview:lbl];
        [lbl addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lblClick:)]];
    }
}

- (void)lblClick:(UITapGestureRecognizer *)recognizer {
    SXTitleLable *titlelable = (SXTitleLable *)recognizer.view;
    CGFloat offsetX = titlelable.tag * bigScroll.frame.size.width;
    CGFloat offsetY = bigScroll.contentOffset.y;
    CGPoint offset = CGPointMake(offsetX, offsetY);
    [bigScroll setContentOffset:offset animated:YES];
}

#pragma mark 设置默认控制器和标题
- (void)addBigScrollViewControllers {
    CGFloat contentX = self.controllers.count * selfFrame.size.width;
    bigScroll.contentSize = CGSizeMake(contentX, 0);
    bigScroll.pagingEnabled = YES;
    
    SXTitleLable *lable = [titleArr firstObject];
    lable.scale = 1.0;
    
    CYChildController *vc = [self.controllers firstObject];
    vc.view.frame = bigScroll.bounds;
    [bigScroll addSubview:vc.view];
    vc.index = 0;
    
    bottomLine = [[UIView alloc] initWithFrame:CGRectMake((labelWidth-bottomWidth)/2.0, labelHight-3, bottomWidth, 2)];
    bottomLine.layer.masksToBounds = YES;
    bottomLine.layer.cornerRadius = 2;
    bottomLine.backgroundColor = [UIColor redColor];
    [smallScroll addSubview:bottomLine];
}



#pragma mark - ******************** scrollView代理方法
//正在滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    // 取出绝对值 避免最左边往右拉时形变超过1
    CGFloat value = ABS(scrollView.contentOffset.x / scrollView.frame.size.width);
    
    
    NSUInteger leftIndex = (int)value;
    NSUInteger rightIndex = leftIndex + 1;
    CGFloat scaleRight = value - leftIndex;
    CGFloat scaleLeft = 1 - scaleRight;
    SXTitleLable *labelLeft = titleArr[leftIndex];
    labelLeft.scale = scaleLeft;
    
    if (rightIndex < titleArr.count) {// 考虑到最后一个板块，如果右边已经没有板块了 就不在下面赋值scale了
        SXTitleLable *labelRight = titleArr[rightIndex];
        labelRight.scale = scaleRight;
    }
    
    CGFloat bottomLineX = value*labelWidth;
    bottomLine.frame = CGRectMake(bottomLineX+(labelWidth-bottomWidth)/2.0, bottomLine.frame.origin.y, bottomWidth, labelHight);
    
}

//滚动结束后调用（代码导致)
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView   {
    index = scrollView.contentOffset.x / bigScroll.frame.size.width;//获得索引
    SXTitleLable *titleLable = (SXTitleLable *)titleArr[index];    //滚动标题栏
    
    CGFloat offsetx = titleLable.center.x - smallScroll.frame.size.width * 0.5;
    CGFloat offsetMax = smallScroll.contentSize.width - smallScroll.frame.size.width;
    if (offsetx < 0) {
        offsetx = 0;
    }else if (offsetx > offsetMax) {
        offsetx = offsetMax;
    }
    CGPoint offset = CGPointMake(offsetx, smallScroll.contentOffset.y);
    [smallScroll setContentOffset:offset animated:YES];
    
    // 向右滑动时 添加控制器
    CYChildController *newsVc = self.controllers[index];
    newsVc.index = index;
    [titleArr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != index) {
            SXTitleLable *temlabel = titleArr[idx];
            [temlabel setScale:0.0];
        }
    }];
    if (newsVc.view.superview) return;
    newsVc.view.frame = scrollView.bounds;
    [bigScroll addSubview:newsVc.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {//滚动结束（手势导致)
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma mark -  计算字符串长度
- (CGFloat)WidthForString:(NSString *)text withSizeOfFont:(UIFont *)font {
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGSize size = [text sizeWithAttributes:dict];
    return size.width;
}






@end
