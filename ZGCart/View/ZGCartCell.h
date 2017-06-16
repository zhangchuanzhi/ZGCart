//
//  ZGCartCell.h
//  ZGCart
//
//  Created by offcn_zcz32036 on 2017/6/13.
//  Copyright © 2017年 offcn. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZGCartModel;
typedef void(^ZGNumberChangedBlock) (NSInteger number);
typedef void(^ZGCellSelectedBlick) (BOOL select);
@interface ZGCartCell : UITableViewCell
@property(nonatomic,assign)NSInteger zgNumber;
@property(nonatomic,assign)BOOL zgSelected;
-(void)reloadDataWithModel:(ZGCartModel*)model;
-(void)numberAddWithBlock:(ZGNumberChangedBlock)block;
-(void)numberCutWithBlock:(ZGNumberChangedBlock)block;
-(void)cellSelectedwithBlock:(ZGCellSelectedBlick)block;
@end
