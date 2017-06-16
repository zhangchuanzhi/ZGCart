//
//  ZGCartModel.h
//  ZGCart
//
//  Created by offcn_zcz32036 on 2017/6/13.
//  Copyright © 2017年 offcn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGCartModel : NSObject
@property(nonatomic,assign)BOOL select;
@property(nonatomic,assign)NSInteger number;
@property(nonatomic,copy)NSString*price;
@property(nonatomic,copy)NSString*sizeStr;
@property(nonatomic,copy)NSString*nameStr;
@property(nonatomic,copy)NSString*dateStr;
@property(nonatomic,strong)UIImage*image;
@end
