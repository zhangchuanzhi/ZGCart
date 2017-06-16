//
//  ZGCartController.m
//  ZGCart
//
//  Created by offcn_zcz32036 on 2017/6/13.
//  Copyright © 2017年 offcn. All rights reserved.
//

#import "ZGCartController.h"
#import "ZGCartCell.h"
#import "ZGCartModel.h"
static NSString *ZG_BackButtonString = @"back_button";
static NSString *ZG_Bottom_UnSelectButtonString = @"cart_unSelect_btn";
static NSString *ZG_Bottom_SelectButtonString = @"cart_selected_btn";
static NSString *ZG_CartEmptyString = @"cart_default_bg";

@interface ZGCartController ()
<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,assign)BOOL isHiddenNavigationBarWhenDisappear;//记录当页面消失时是否需要隐藏系统导航
@property(nonatomic,assign)BOOL isHasTabBarController;//是否含有tabbar
@property(nonatomic,assign)BOOL isHasNavitationController;//是否含有导航
@property(nonatomic,strong)NSMutableArray*dataArray;
@property(nonatomic,strong)NSMutableArray*selectedArray;
@property(nonatomic,strong)UITableView*myTableView;
@property(nonatomic,strong)UIButton*allSellectedButton;
@property(nonatomic,strong)UILabel*totlePriceLabel;
@end

@implementation ZGCartController
-(void)viewWillAppear:(BOOL)animated
{
    
    if (_isHasNavitationController==YES) {
        if (self.navigationController.navigationBarHidden==YES) {
            _isHiddenNavigationBarWhenDisappear=NO;
        }
        else
        {
            self.navigationController.navigationBarHidden=YES;
            _isHiddenNavigationBarWhenDisappear=YES;
        }
    }
    //当进入购物车的时候判断是否有已选择的商品，有就清空
    //主要是提交订单后再返回到购物车，如果不清空，还会显示
    if (self.selectedArray.count>0) {
        for (ZGCartModel *model in self.selectedArray) {
            model.select=NO;
        }
        [self.selectedArray removeAllObjects];
    }
    //初始化显示状态
    _allSellectedButton.selected=NO;
    _totlePriceLabel.attributedText=[self ZGSetString:@"¥0.00"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (_isHiddenNavigationBarWhenDisappear==YES) {
        self.navigationController.navigationBarHidden=NO;
    }
}
-(void)createData
{
    for (int i=0; i<10; i++) {
        ZGCartModel *model=[[ZGCartModel alloc]init];
        model.nameStr=[NSString stringWithFormat:@"测试数据%d",i];
        model.price=@"100.00";
        model.number=1;
        model.image=[UIImage imageNamed:@"aaa.jpg"];
        model.sizeStr=@"18*20cm";
        model.dateStr=@"2017.06.13";
        [self.dataArray addObject:model];
    }
}
-(void)loadData
{
    [self createData];
    [self changeView];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.isHasTabBarController=self.tabBarController?YES:NO;
    self.isHasNavitationController=self.navigationController?YES:NO;
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2];
    [self setupCustomNavigationBar];
    if (self.dataArray.count>0) {
        [self setupCartView];
    }
    else
    {
        [self setUpCartEmptyView];
    }
    
}
//计算已选中商品金额
-(void)countPrice
{
    double totlePrice=0.0;
    for (ZGCartModel *model in self.selectedArray) {
        double price=[model.price doubleValue];
        totlePrice+=price*model.number;
    }
    NSString *string=[NSString stringWithFormat:@"¥%.2f",totlePrice];
    self.totlePriceLabel.attributedText=[self ZGSetString:string];
}
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray=[[NSMutableArray alloc]init];
    }
    return _dataArray;
}
-(NSMutableArray *)selectedArray
{
    if (!_selectedArray) {
        _selectedArray=[[NSMutableArray alloc]init];
    }
    return _selectedArray;
}
//布局页面视图
-(void)setupCustomNavigationBar
{
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, ZGSCREEN_WIDTH, ZGNaigationBarHeight)];
    backgroundView.backgroundColor=ZGColorFromRGB(236, 236, 236);
    [self.view addSubview:backgroundView];
    
    UIView *lineView=[[UIView alloc]initWithFrame:CGRectMake(0, ZGNaigationBarHeight-0.5, ZGSCREEN_WIDTH, 0.5)];
    lineView.backgroundColor=[UIColor lightGrayColor];
    [self.view addSubview:lineView];
    UILabel *titleLabel=[[UILabel alloc]init];
    titleLabel.text=@"购物车";
    titleLabel.font=[UIFont systemFontOfSize:20];
    titleLabel.center=CGPointMake(self.view.center.x, (ZGNaigationBarHeight-20)/2+20);
    CGSize size=[titleLabel sizeThatFits:CGSizeMake(300, 44)];
    titleLabel.bounds=CGRectMake(0, 0, size.width+20, size.height);
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame=CGRectMake(10, 20, 40, 44);
    [backButton setImage:[UIImage imageNamed:ZG_BackButtonString] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}
//自定义底部视图
-(void)setupCustomBottomView
{
    UIView *backgroundView=[[UIView alloc]init];
    backgroundView.backgroundColor=ZGColorFromRGB(245, 245, 245);
    backgroundView.tag=TAG_CartEmptyView+1;
    [self.view addSubview:backgroundView];
    //当有tabBarController时，在tabBar的上面
    if (_isHasTabBarController==YES) {
        backgroundView.frame=CGRectMake(0, ZGSCREEN_HEIGHT-2*ZGTabBarHeight, ZGSCREEN_WIDTH, ZGTabBarHeight);
    }
    else
    {
        backgroundView.frame=CGRectMake(0, ZGSCREEN_HEIGHT-ZGTabBarHeight, ZGSCREEN_WIDTH, ZGTabBarHeight);
    }
    
    UIView *lineView=[[UIView alloc]init];
    lineView.frame=CGRectMake(0, 0, ZGSCREEN_WIDTH, 1);
    lineView.backgroundColor=[UIColor lightGrayColor];
    [backgroundView addSubview:lineView];
    //全选按钮
    UIButton *selectAll=[UIButton buttonWithType:UIButtonTypeCustom];
    selectAll.titleLabel.font=[UIFont systemFontOfSize:16];
    selectAll.frame=CGRectMake(10, 5, 80, ZGTabBarHeight-10);
    [selectAll setImage:[UIImage imageNamed:ZG_Bottom_UnSelectButtonString] forState:UIControlStateNormal];
    [selectAll setImage:[UIImage imageNamed:ZG_Bottom_SelectButtonString] forState:UIControlStateSelected];
    [selectAll setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectAll addTarget:self action:@selector(selectAllbtnclick:) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:selectAll];
    self.allSellectedButton=selectAll;
    
    //结算按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor=BASECOLOR_RED;
    btn.frame=CGRectMake(ZGSCREEN_WIDTH-80, 0, 80, ZGTabBarHeight);
    [btn setTitle:@"确认购买" forState:UIControlStateNormal];
    [backgroundView addSubview:btn];
    //合计
    UILabel *label=[[UILabel alloc]init];
    label.font=[UIFont systemFontOfSize:18];
    label.textColor=BASECOLOR_RED;
    [backgroundView addSubview:label];
    label.attributedText=[self ZGSetString:@"¥0.00"];
    CGFloat maxWidth=ZGSCREEN_WIDTH-selectAll.bounds.size.width-btn.bounds.size.width-30;
    label.frame=CGRectMake(selectAll.bounds.size.width+20, 0, maxWidth-10, ZGTabBarHeight);
    self.totlePriceLabel=label;
    
}
//全选按钮点击事件
-(void)selectAllbtnclick:(UIButton*)sender
{
    sender.selected=!sender.selected;
    //点击全选时，把之前已选择的全部删除
    for (ZGCartModel *model in self.dataArray) {
        model.select=NO;
    }
    [self.selectedArray removeAllObjects];
    if (sender.selected) {
        for (ZGCartModel *model in self.dataArray) {
            model.select=YES;
            [self.selectedArray addObject:model];
        }
    }
    [self.myTableView reloadData];
    [self countPrice];
}
//返回按钮点击
-(void)backButtonClick:(UIButton*)sender
{
    if (_isHasNavitationController==NO) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//购物车有商品时的视图
-(void)setupCartView
{
    //创建底部视图
    [self setupCustomBottomView];
    UITableView *table=[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate=self;
    table.dataSource=self;
    table.rowHeight=100;
    table.separatorStyle=UITableViewCellSeparatorStyleNone;
    table.backgroundColor=ZGColorFromRGB(245, 246, 248);
    [self.view addSubview:table];
    self.myTableView=table;
    if (_isHasTabBarController) {
        table.frame=CGRectMake(0, ZGNaigationBarHeight, ZGSCREEN_WIDTH, ZGSCREEN_HEIGHT-ZGNaigationBarHeight-2*ZGTabBarHeight);
    }
    else
    {
        table.frame=CGRectMake(0, ZGNaigationBarHeight, ZGSCREEN_WIDTH, ZGSCREEN_HEIGHT-ZGNaigationBarHeight-ZGTabBarHeight);
    }
}
-(void)setUpCartEmptyView
{
   //默认视图背景
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, ZGNaigationBarHeight, ZGSCREEN_WIDTH, ZGSCREEN_HEIGHT-ZGNaigationBarHeight)];
    backgroundView.tag=TAG_CartEmptyView;
    //默认图片
    UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:ZG_CartEmptyString]];
    img.center=CGPointMake(ZGSCREEN_WIDTH/2, ZGSCREEN_HEIGHT/2-120);
    img.bounds=CGRectMake(0, 0, 247/187*100, 100);
    [backgroundView addSubview:img];
    UILabel *warnLabel=[[UILabel alloc]init];
    warnLabel.center=CGPointMake(ZGSCREEN_WIDTH/2, ZGSCREEN_HEIGHT/2-10);
    warnLabel.bounds=CGRectMake(0, 0, ZGSCREEN_WIDTH, 30);
    warnLabel.textAlignment=NSTextAlignmentCenter;
    warnLabel.text=@"购物车为空！";
    warnLabel.font=[UIFont systemFontOfSize:15];
    warnLabel.textColor=ZGCOLOR(0x706f6f);
    [backgroundView addSubview:warnLabel];
}
//购物车为空时的默认视图
-(void)changeView
{
    if (self.dataArray.count>0) {
        UIView *view=[self.view viewWithTag:TAG_CartEmptyView];
        if (view!=nil) {
            [view removeFromSuperview];
        }
        [self setupCartView];
    }
    else
    {
        UIView *bottomView=[self.view viewWithTag:TAG_CartEmptyView+1];
        [bottomView removeFromSuperview];
        [self.myTableView removeFromSuperview];
        self.myTableView=nil;
        [self setUpCartEmptyView];
    }
}
-(NSMutableAttributedString*)ZGSetString:(NSString*)string
{
    NSString *text=[NSString stringWithFormat:@"合计:%@",string];
    NSMutableAttributedString *zgString=[[NSMutableAttributedString alloc]initWithString:text];
    NSRange range=[text rangeOfString:@"合计:"];
    [zgString addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16]} range:range];
    return zgString;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"ZGCartCellID";
    ZGCartCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell=[[ZGCartCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    ZGCartModel *model=self.dataArray[indexPath.row];
    __block typeof(cell)weakCell=cell;
    [cell numberAddWithBlock:^(NSInteger number) {
        weakCell.zgNumber=number;
        model.number=number;
        [self.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        if ([self.selectedArray containsObject:model]) {
            [self.selectedArray removeObject:model];
            [self.selectedArray addObject:model];
            [self countPrice];
        }
    }];
    [cell numberCutWithBlock:^(NSInteger number) {
        weakCell.zgNumber=number;
        model.number=number;
        [self.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        //判断已选择数组里有无该对象，有就删除重新添加
        if ([self.selectedArray containsObject:model]) {
            [self.selectedArray removeObject:model];
            [self.selectedArray addObject:model];
            [self countPrice];
        }
    }];
    [cell cellSelectedwithBlock:^(BOOL select) {
        model.select=select;
        if (select) {
            [self.selectedArray addObject:model];
        }
        else
        {
            [self.selectedArray removeObject:model];
        }
        if (self.selectedArray.count==self.dataArray.count) {
            _allSellectedButton.selected=YES;
        }
        else
        {
            _allSellectedButton.selected=NO;
        }
        [self countPrice];
    }];
    [cell reloadDataWithModel:model];
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:@"确定要删除该商品？删除后无法恢复!" preferredStyle:1];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ZGCartModel *model=self.dataArray[indexPath.row];
            [self.dataArray removeObjectAtIndex:indexPath.row];
            //删除
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //判断删除的商品是否已选择
            if ([self.selectedArray containsObject:model]) {
                //从已选中删除，重新计算价格
                [self.selectedArray removeObject:model];
                [self countPrice];
            }
            if (self.selectedArray.count==self.dataArray.count) {
                _allSellectedButton.selected=YES;
            }
            else
            {
                _allSellectedButton.selected=NO;
            }
            if (self.dataArray.count==0) {
                [self changeView];
            }
            //如果删除的时候数据紊乱，可以延迟刷新
            [self performSelectorOnMainThread:@selector(reloadTable) withObject:nil waitUntilDone:0.5];
            
        }];
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(void)reloadTable
{
    [self.myTableView reloadData];
}
#pragma mark --- 确认选择,提交订单按钮点击事件
- (void)goToPayButtonClick:(UIButton*)button {
    if (self.selectedArray.count > 0) {
        for (ZGCartModel *model in self.selectedArray) {
            NSLog(@"选择的商品>>%@>>>%ld",model,(long)model.number);
        }
    } else {
        NSLog(@"你还没有选择任何商品");
    }
    
}



@end


