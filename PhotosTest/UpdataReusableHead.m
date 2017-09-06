//
//  UpdataReusableHead.m
//  PhotosTest
//
//  Created by Scofield on 17/9/6.
//  Copyright © 2017年 谢航. All rights reserved.
//

#import "UpdataReusableHead.h"
#import "UIView+CGRect.h"

@implementation UpdataReusableHead

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _SectionLab = [[UILabel alloc] init];
        _SectionLab.CustomFrame = CGRectMake(10, 0, 200, 20);
        
        _SectionLab.font = [UIFont systemFontOfSize:14*ScreenHeight_scale];
        [self addSubview:_SectionLab];
        
        
    }
    return self;
}

@end
