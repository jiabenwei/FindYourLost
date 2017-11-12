//
//  FYLTabBar.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLTabBar.h"
#import "FYLTabBarItem.h"

@interface FYLTabBar ()

@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) UIView *backgroundView;

@end

@implementation FYLTabBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (void)commonInitialization {
    _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 60+kSafeBottomHeight)];
    _backgroundView.backgroundColor = [UIColor clearColor];
    [self addSubview:_backgroundView];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 16, Screen_Width, 44+kSafeBottomHeight)];
    subView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
    [_backgroundView addSubview:subView];
    
        
    UIButton *middleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [middleBtn addTarget:self action:@selector(middleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    middleBtn.adjustsImageWhenHighlighted = NO;
    [middleBtn setBackgroundImage:[UIImage imageNamed:@"bottom-add.png"]forState:UIControlStateNormal];
    middleBtn.bounds = CGRectMake(0, 0, 60.0, 60.0);
    middleBtn.center = CGPointMake(Screen_Width/2, 60.0f/2);
    [self addSubview:middleBtn];
    
    [self setTranslucent:YES];
}

- (void)middleBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(tabBar:middleItemSelected:)]) {
        [self.delegate tabBar:self middleItemSelected:sender];
    }
    
}

- (void)layoutSubviews {
    CGSize frameSize = self.frame.size;
    CGFloat minimumContentHeight = [self minimumContentHeight];
    
    [[self backgroundView] setFrame:CGRectMake(0, frameSize.height - minimumContentHeight,
                                               frameSize.width, frameSize.height)];
    
    [self setItemWidth:roundf((frameSize.width - [self contentEdgeInsets].left -
                               [self contentEdgeInsets].right-60) / ([[self items] count]))];
    
    NSInteger index = 0;
    
    // Layout items
    
    for (FYLTabBarItem *item in [self items]) {
        CGFloat itemHeight = [item itemHeight];
        
        if (!itemHeight) {
            itemHeight = frameSize.height-17-kSafeBottomHeight;
        }
        
        NSInteger trueIndex = index;
        CGFloat width = 0;
        if (index < [[self items] count]/2) {
//            trueIndex = index;
            width = 0;
        }else{
//            trueIndex = index+1;
            width = 60;
        }
        [item setFrame:CGRectMake(self.contentEdgeInsets.left + (trueIndex * self.itemWidth + width),
                                  roundf(frameSize.height-kSafeBottomHeight - itemHeight) - self.contentEdgeInsets.top,
                                  self.itemWidth, itemHeight - self.contentEdgeInsets.bottom)];
        [item setNeedsDisplay];
        
        index++;
    }
}

#pragma mark - Configuration

- (void)setItemWidth:(CGFloat)itemWidth {
    if (itemWidth > 0) {
        _itemWidth = itemWidth;
    }
}

- (void)setItems:(NSArray *)items {
    for (FYLTabBarItem *item in items) {
        [item removeFromSuperview];
    }
    
    _items = [items copy];
    for (FYLTabBarItem *item in items) {
        [item addTarget:self action:@selector(tabBarItemWasSelected:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:item];
    }
}

- (void)setHeight:(CGFloat)height {
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame),
                              CGRectGetWidth(self.frame), height)];
}

- (CGFloat)minimumContentHeight {
    CGFloat minimumTabBarContentHeight = CGRectGetHeight([self frame]);
    
    for (FYLTabBarItem *item in [self items]) {
        CGFloat itemHeight = [item itemHeight];
        if (itemHeight && (itemHeight < minimumTabBarContentHeight)) {
            minimumTabBarContentHeight = itemHeight;
        }
    }
    
    return minimumTabBarContentHeight;
}

#pragma mark - Item selection

- (void)tabBarItemWasSelected:(id)sender {
    if ([[self delegate] respondsToSelector:@selector(tabBar:shouldSelectItemAtIndex:)]) {
        NSInteger index = [self.items indexOfObject:sender];
        if (![[self delegate] tabBar:self shouldSelectItemAtIndex:index]) {
            return;
        }
    }
    
    [self setSelectedItem:sender];
    
    if ([[self delegate] respondsToSelector:@selector(tabBar:didSelectItemAtIndex:)]) {
        NSInteger index = [self.items indexOfObject:self.selectedItem];
        [[self delegate] tabBar:self didSelectItemAtIndex:index];
    }
}

- (void)setSelectedItem:(FYLTabBarItem *)selectedItem {
    if (selectedItem == _selectedItem) {
        return;
    }
    [_selectedItem setSelected:NO];
    
    _selectedItem = selectedItem;
    [_selectedItem setSelected:YES];
}

#pragma mark - Translucency

- (void)setTranslucent:(BOOL)translucent {
    _translucent = translucent;
    
    //    CGFloat alpha = (translucent ? 0.9 : 1.0);
    //
    //
    //    [_backgroundView setBackgroundColor:[UIColor colorWithRed:245/255.0
    //                                                        green:245/255.0
    //                                                         blue:245/255.0
    //                                                        alpha:alpha]];
    
    //[_backgroundView setBackgroundColor:[UIColor blackColor]];
}


@end
