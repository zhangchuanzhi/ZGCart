//
//  ZGCartCell.m
//  ZGCart
//
//  Created by offcn_zcz32036 on 2017/6/13.
//  Copyright © 2017年 offcn. All rights reserved.
//

#import "ZGCartCell.h"
#import "ZGCartModel.h"
static NSString *ZG_BackButtonString = @"back_button";
static NSString *ZG_Bottom_UnSelectButtonString = @"cart_unSelect_btn";
static NSString *ZG_Bottom_SelectButtonString = @"cart_selected_btn";
static NSString *ZG_CartEmptyString = @"cart_default_bg";
static NSInteger ZG_CartRowHeight = 100;


@interface ZGCartCell()
{
    ZGNumberChangedBlock numberAddBlock;
    ZGNumberChangedBlock numberCutBlock;
    ZGCellSelectedBlick cellSelectedBlock;
}
//选中按钮
@property(nonatomic,strong)UIButton*selectBtn;
//显示照片
@property(nonatomic,strong)UIImageView*zgImgView;
//商品名
@property(nonatomic,strong)UILabel*nameLabel;
//尺寸
@property(nonatomic,strong)UILabel*sizeLabel;
//时间
@property(nonatomic,strong)UILabel*dateLabel;
//价格
@property(nonatomic,strong)UILabel*priceLabel;
//数量
@property(nonatomic,strong)UILabel*numberLabel;
@end
@implementation ZGCartCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setUpMainView];
    }
    return self;
}
-(void)setUpMainView
{
    self.backgroundColor=ZGColorFromRGB(245, 246, 248);
    self.selectionStyle=UITableViewCellSelectionStyleNone;
   //白色背景
    UIView *bgView=[[UIView alloc]init];
    bgView.frame=CGRectMake(10, 10, ZGSCREEN_WIDTH-20, ZG_CartRowHeight-10);
    bgView.backgroundColor=[UIColor whiteColor];
    bgView.layer.borderColor=ZGCOLOR(0xeeeeee).CGColor;
    bgView.layer.borderWidth=1;
    [self addSubview:bgView];
    //选中按钮
    UIButton *selectBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.center=CGPointMake(20, bgView.height/2);
    selectBtn.bounds=CGRectMake(0, 0, 30, 30);
    [selectBtn setImage:[UIImage imageNamed:ZG_Bottom_UnSelectButtonString] forState:UIControlStateNormal];
    [selectBtn setImage:[UIImage imageNamed:ZG_Bottom_SelectButtonString] forState:UIControlStateSelected];
    [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:selectBtn];
    self.selectBtn=selectBtn;
    //照片背景
    UIView *imageBgView=[[UIView alloc]init];
    imageBgView.frame=CGRectMake(selectBtn.right+5, 5, bgView.height-10, bgView.height-10);
    imageBgView.backgroundColor=ZGCOLOR(0xf3f3f3);
    [bgView addSubview:imageBgView];
    //显示照片
    UIImageView *imageView=[[UIImageView alloc]init];
    imageView.image=[UIImage imageNamed:@"default_pic_1"];
    imageView.frame=CGRectMake(imageBgView.left+5, imageBgView.top+5, imageBgView.width-10, imageBgView.height-10);
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    [bgView addSubview:imageView];
    self.zgImgView=imageView;
    CGFloat width=(bgView.width-imageBgView.right-30)/2;
    //价格
    UILabel *priceLabel=[[UILabel alloc]init];
    priceLabel.frame=CGRectMake(bgView.width-width-10, 10, width, 30);
    priceLabel.font=[UIFont boldSystemFontOfSize:16];
    priceLabel.textColor=BASECOLOR_RED;
    priceLabel.textAlignment=NSTextAlignmentRight;
    [bgView addSubview:priceLabel];
    self.priceLabel=priceLabel;
    //商品名
    UILabel *nameLabel=[[UILabel alloc]init];
    nameLabel.frame=CGRectMake(imageBgView.right+10, 10, width, 25);
    nameLabel.font=[UIFont systemFontOfSize:15];
    [bgView addSubview:nameLabel];
    self.nameLabel=nameLabel;
    //尺寸
    UILabel *sizeLabel=[[UILabel alloc]init];
    sizeLabel.frame=CGRectMake(nameLabel.left, nameLabel.bottom+5, width, 20);
    sizeLabel.textColor=ZGColorFromRGB(132, 132, 132);
    sizeLabel.font=[UIFont systemFontOfSize:12];
    [bgView addSubview:sizeLabel];
    self.sizeLabel=sizeLabel;
    //时间
    UILabel *dateLabel=[[UILabel alloc]init];
    dateLabel.frame=CGRectMake(nameLabel.left, sizeLabel.bottom, width, 20);
    dateLabel.font=[UIFont systemFontOfSize:10];
    dateLabel.textColor=ZGColorFromRGB(132, 132, 132);
    [bgView addSubview:dateLabel];
    self.dateLabel=dateLabel;
    //数量加按钮
    UIButton *addBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame=CGRectMake(bgView.width-35, bgView.height-35, 25, 25);
    [addBtn setImage:[UIImage imageNamed:@"cart_addBtn_nomal"] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"cart_addBtn_highlight"] forState:UIControlStateHighlighted];
    [addBtn addTarget:self action:@selector(addbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:addBtn];
    //数量
    UILabel *numberLabel=[[UILabel alloc]init];
    numberLabel.frame=CGRectMake(addBtn.left-30, addBtn.top, 30, 25);
    numberLabel.textAlignment=NSTextAlignmentCenter;
    numberLabel.text=@"1";
    numberLabel.font=[UIFont systemFontOfSize:15];
    [bgView addSubview:numberLabel];
    self.numberLabel=numberLabel;
    //数量减按钮
    UIButton *cutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    cutBtn.frame=CGRectMake(numberLabel.left-25, addBtn.top, 25, 25);
    [cutBtn setImage:[UIImage imageNamed:@"cart_cutBtn_nomal"] forState:UIControlStateNormal];
    [cutBtn setImage:[UIImage imageNamed:@"cart_cutBtn_highlight"] forState:UIControlStateHighlighted];
    [cutBtn addTarget:self action:@selector(cutbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:cutBtn];
}
-(void)selectBtnClick:(UIButton *)sender
{
    sender.selected=!sender.selected;
    if (cellSelectedBlock) {
        cellSelectedBlock(sender.selected);
    }
}
-(void)addbtnClick:(UIButton *)sender
{
    NSInteger count=[self.numberLabel.text integerValue];
    count++;
    if (numberAddBlock) {
        numberAddBlock(count);
    }
}
-(void)cutbtnClick:(UIButton *)sender
{
    NSInteger count=[self.numberLabel.text integerValue];
    count--;
    if (count<=0) {
        return;
    }
    if (numberCutBlock) {
        numberCutBlock(count);
    }
}

-(void)reloadDataWithModel:(ZGCartModel *)model
{
    self.zgImgView.image=model.image;
    self.nameLabel.text=model.nameStr;
    self.priceLabel.text=model.price;
    self.dateLabel.text=model.dateStr;
    self.numberLabel.text=[NSString stringWithFormat:@"%ld",(long)model.number];
    self.sizeLabel.text=model.sizeStr;
    self.selectBtn.selected=model.select;
    
}

-(void)numberAddWithBlock:(ZGNumberChangedBlock)block
{
    numberAddBlock = block;
}
-(void)numberCutWithBlock:(ZGNumberChangedBlock)block
{
    numberCutBlock = block;
}
-(void)cellSelectedwithBlock:(ZGCellSelectedBlick)block
{
    cellSelectedBlock = block;
}

-(void)setZgNumber:(NSInteger)zgNumber
{
    _zgNumber=zgNumber;
    self.numberLabel.text=[NSString stringWithFormat:@"%ld",(long)zgNumber];
}
-(void)setZgSelected:(BOOL)zgSelected
{
    _zgSelected=zgSelected;
    self.selectBtn.selected=zgSelected;
}














































@end
