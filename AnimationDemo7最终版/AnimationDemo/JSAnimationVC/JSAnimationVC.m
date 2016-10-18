//
//  JSAnimationVC.m
//  AnimationDemo
//
//  Created by 曾家诗 on 16/9/27.
//  Copyright © 2016年 com.lufeifans. All rights reserved.
//

#import "JSAnimationVC.h"
#import <CoreData/CoreData.h>


@interface JSAnimationVC ()<UIAccelerometerDelegate,UIGestureRecognizerDelegate>

#define  kUpdateFrequency  60.0
// 获得屏幕宽高
#define HMScreenW [UIScreen mainScreen].bounds.size.width
#define HMScreenH [UIScreen mainScreen].bounds.size.height



/**
 * 定义一个结构体标记: 滑动方向
 */
typedef enum : NSUInteger {
    directionNome, //不赋值
    directionLetf, //左
    directionRigth//右
    
} direction;



//标记滑动方向
@property(nonatomic,assign) direction dire;


//最初的frame
@property(nonatomic,assign) CGRect firstFrame;
//上一个frame
@property(nonatomic,assign) CGRect higherFrame;
//下一个frame
@property(nonatomic,assign) CGRect nextFrame;


//第一个
@property(nonatomic,strong)UIView *firstView;
@property(nonatomic,strong)UIScrollView *firstScrollView;
@property(nonatomic,strong)UIImageView *firstDeautyImage;

//第二个
@property(nonatomic,strong)UIView *secondView;
@property(nonatomic,strong)UIScrollView *secondScrollView;
@property(nonatomic,strong)UIImageView *secondDeautyImage;

//第三个
@property(nonatomic,strong)UIView *thirdView;
@property(nonatomic,strong)UIScrollView *thirdScrollView;
@property(nonatomic,strong)UIImageView *thirdDeautyImage;



//当前
@property(nonatomic,strong)UIView *presentView;
@property(nonatomic,strong)UIScrollView *present;
@property(nonatomic,strong)UIImageView *presentImg;
//下一个
@property(nonatomic,strong)UIView *nextView;
@property(nonatomic,strong)UIScrollView *next;
@property(nonatomic,strong)UIImageView *nextImg;
//上一个
@property(nonatomic,strong)UIView *higherView;
@property(nonatomic,strong)UIScrollView *higher;
@property(nonatomic,strong)UIImageView *higherImg;

//索引
@property(nonatomic,assign) NSInteger index;
//第二个索引
@property(nonatomic,assign) NSInteger labelIndex;

//索引label
@property(nonatomic,strong)UILabel *indexLabel;

//记录开始的坐标点
@property(nonatomic,assign) CGPoint beginPoint;

//记录上一个偏移值
@property(nonatomic,assign) CGFloat higherX;

//记录上下张图片
@property(nonatomic,strong)UIImage *higImage;
@property(nonatomic,strong)UIImage *nextImage;

@property(nonatomic,assign) NSInteger miao;

@end

@implementation JSAnimationVC


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    self.index = 0;
    self.labelIndex = 1;
    //添加子空间
    [self.view addSubview:self.thirdView];
    [self.view addSubview:self.secondView];
    [self.view addSubview:self.firstView];
    [self.view addSubview:self.indexLabel];
    
    //注册KVO
    [self.presentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    //注册KVO
    [self.higherView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    //记录frame
    self.firstFrame = self.firstView.frame;
    CGSize viewS = self.view.frame.size;
    self.higherFrame = CGRectMake(-viewS.width, 0, viewS.width, viewS.height);
    self.nextFrame = self.secondView.frame;
    //记录ScrollView
    self.higher = self.thirdScrollView;
    self.next = self.secondScrollView;
    self.present = self.firstScrollView;
    //记录图片
    self.higherImg = self.thirdDeautyImage;
    self.nextImg = self.secondDeautyImage;
    self.presentImg = self.firstDeautyImage;
    [self startupAnimationDone];
    
    //添加拖动手势
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGestureWith:)];
    [self.view addGestureRecognizer:panGes];
}


/**
 *
 * 拖动手势
 */
- (void)moveGestureWith:(id)tap{
    
    if ([tap isKindOfClass:[UIPanGestureRecognizer class]]) {//拖动手势
        UIPanGestureRecognizer *pan = tap;
        CGPoint po = [tap translationInView:self.view];
        
        if (pan.state == UIGestureRecognizerStateBegan) {//开始手势
            //开始
            [self beginState];
            NSDate* tmpStartData = [NSDate date];
            self.miao = [self jiSunaMiaoWith:tmpStartData];
            
        }else if (pan.state==UIGestureRecognizerStateChanged){//改变
            //改变
            [self changeStateWithOffSet:po.x];
            
        }else if (pan.state==UIGestureRecognizerStateEnded){//完成
            //结束
            CGFloat pointX = 0.0;
            if (po.x<0) {
                pointX = -(po.x);
            }else{
                pointX = po.x;
            }
            
            [self endStateWithOff:pointX];
        }
    }
    
}

- (NSInteger)jiSunaMiaoWith:(NSDate *)date{
    
    NSCalendar *calender=[NSCalendar currentCalendar];
    //枚举保存日期的每一天
    NSCalendarUnit unitsave=NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    
    //当前的时分秒获得
    NSDateComponents *comps =[calender components:unitsave fromDate:date];
    
    NSInteger hour = [comps hour];
    
    NSInteger minute = [comps minute];
    
    NSInteger second = [comps second];
    
    NSInteger endMiao = hour*60*60+minute*60+second;
    
    return endMiao;
}

/**
 *
 * 拖动手势开始状态
 */
- (void)beginState{
    
    //开始点击的时候为图片赋值
    //NSLog(@"索引 = %zd",self.index);
    //NSLog(@"索引 = %zd",self.labelIndex);
    [self.view bringSubviewToFront:self.indexLabel];
    
    if (self.index==0) {
        self.presentImg.image = self.imgArr[self.index];
        self.nextImg.image = self.imgArr[self.index+1];
        self.higherImg.image = self.imgArr.lastObject;
        
    } else if(self.index>0) {
        
        self.presentImg.image = self.imgArr[self.index];
        if (self.index+1>=self.imgArr.count) {
            self.nextImg.image = self.imgArr.firstObject;
        }else{
            self.nextImg.image = self.imgArr[self.index+1];
        }
        self.higherImg.image = self.imgArr[self.index-1];
        
    }else{
        
        self.presentImg.image = self.imgArr[self.imgArr.count + self.index];
        self.nextImg.image = self.nextImage;
        self.higherImg.image = self.imgArr[self.imgArr.count + self.index-1];
        
    }
    
    //设置当前的
    self.presentView.frame = self.firstFrame;
    self.presentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    //设置下一个的
    self.nextView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    //设置上一个的
    self.higherView.frame = self.higherFrame;
    self.higherView.transform = CGAffineTransformMakeScale(1.0, 1.0);
}
/**
 *
 * 拖动手势改变状态
 */
- (void)changeStateWithOffSet:(CGFloat)off{
    
    //计算开始点和当前点的偏移值
    CGFloat beginOffX = off;
    //NSLog(@"偏移值 = %lf",beginOffX);
    if(beginOffX > 0&&self.dire==directionNome){//向右滑动
        
        self.dire = directionRigth;
        
    }else if(self.dire==directionNome&&beginOffX < 0){//向左滑动
        
        self.dire = directionLetf;
    }
    //NSLog(@"%lf",beginOffX);
    //改变当前的frame
    CGRect frameP = self.presentView.frame;
    //判断是否右滑
    if (self.dire==directionRigth) {
        
        CGRect frameH = self.higherView.frame;
        [self.view bringSubviewToFront:self.higherView];
        self.present.hidden = NO;
        self.higher.hidden = NO;
        self.higherView.hidden = NO;
        self.presentView.hidden = NO;
        self.nextView.hidden = YES;
        self.next.hidden = YES;
        //设置上一个的frame滑回来
        frameH.origin.x = (-self.view.frame.size.width) + beginOffX;
        NSLog(@"%lf",frameH.origin.x);
        self.higherView.frame = frameH;
        //设置不能越边界
        if(frameP.origin.x<=0){
            frameP.origin.x = 0;
        }
    }else{//左滑
        
        //显示
        self.presentView.hidden = NO;
        self.nextView.hidden = NO;
        self.present.hidden = NO;
        self.next.hidden = NO;
        
        frameP.origin.x = beginOffX;
        //设置不能越边界
        if (frameP.origin.x>=0) {
            frameP.origin.x = 0;
        }
        self.presentView.frame = frameP;
    }
    
    [self.view bringSubviewToFront:self.indexLabel];
    
}

/**
 *
 * 拖动手势结束状态
 */
- (void)endStateWithOff:(CGFloat)off{
    
    NSDate* tmpStartData = [NSDate date];
    NSInteger endMiao = [self jiSunaMiaoWith:tmpStartData];
    
    NSLog(@"%zd",endMiao-self.miao);
    if (endMiao==self.miao&&off<(self.view.frame.size.width/2)) {
        NSLog(@"轻扫");
        if(self.dire==directionLetf){//左
            
            [UIView animateWithDuration:0.25 animations:^{
                self.higImage = self.presentImg.image;
                //设置当前的
                self.presentView.frame = self.higherFrame;
                self.presentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                //设置下一个的
                self.nextView.frame = self.firstFrame;
                self.nextView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                //设置上一个的
                self.higherView.frame = self.firstFrame;
                self.higherView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                
                //                [self.view insertSubview:self.higherView atIndex:0];
                //                [self.view insertSubview:self.presentView atIndex:1];
                //交换View
                UIView *tempView2 = [[UIView alloc] init];
                tempView2 = self.presentView;
                self.presentView = self.nextView;
                self.nextView = self.higherView;
                self.higherView = tempView2;
                //交换ScrollView
                UIScrollView *tempScrollView2 = [[UIScrollView alloc] init];
                tempScrollView2 = self.present;
                self.present = self.next;
                self.next = self.higher;
                self.higher = tempScrollView2;
                //交换图片
                UIImageView *tempImg2 = [[UIImageView alloc] init];
                tempImg2 = self.presentImg;
                self.presentImg = self.nextImg;
                self.nextImg = self.higherImg;
                self.higherImg = tempImg2;
                       
                if (self.index>=self.imgArr.count-1) {
                    
                    self.index = 0;
                }else{
                    
                    self.index++;
                }
                
                self.indexLabel.text = [NSString stringWithFormat:@"%zd",self.index+1];
            } completion:^(BOOL finished) {
                [self.view insertSubview:self.higherView atIndex:0];
                //[self.view insertSubview:self.presentView atIndex:0];
                //[self.view insertSubview:self.nextView atIndex:2];
            }];
            
            
        }else if(self.dire==directionRigth){//右
            [UIView animateWithDuration:0.25 animations:^{
                
                self.nextImage = self.presentImg.image;
                //滑动完成
                //设置上一个的
                self.higherView.frame = self.firstFrame;
                self.higherView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                
                //设置当前的
                self.presentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                //设置下一个的
                self.nextView.frame = self.higherFrame;
                self.nextView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                
                //交换view
                UIView *tempView1 = [[UIView alloc] init];
                tempView1 = self.presentView;
                self.presentView = self.higherView;
                self.higherView = self.nextView;
                self.nextView = tempView1;
                
                //交换ScrollView
                UIScrollView *tempScrollView1 = [[UIScrollView alloc] init];
                tempScrollView1 = self.present;
                self.present = self.higher;
                self.higher = self.next;
                self.next = tempScrollView1;
                
                //交换图片
                UIImageView *tempImg1 = [[UIImageView alloc] init];
                tempImg1 = self.presentImg;
                self.presentImg = self.higherImg;
                self.higherImg = self.nextImg;
                self.nextImg = tempImg1;
                
                if (self.index<=0) {
                    
                    self.index = self.imgArr.count-1;
                }else{
                    
                    self.index--;
                }
                
                self.indexLabel.text = [NSString stringWithFormat:@"%zd",self.index+1];
                
            }];
            
        }
        
    }else{
        
        //判断滑动方向
        if (self.dire==directionRigth) {//右滑
            
            CGRect frame = self.higherView.frame;
            
            if (frame.origin.x>(-frame.size.width/2)) {
                [UIView animateWithDuration:0.25 animations:^{
                    
                    self.nextImage = self.presentImg.image;
                    //滑动完成
                    //设置上一个的
                    self.higherView.frame = self.firstFrame;
                    self.higherView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    
                    //设置当前的
                    self.presentView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                    //设置下一个的
                    self.nextView.frame = self.higherFrame;
                    self.nextView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    
                    //交换view
                    UIView *tempView1 = [[UIView alloc] init];
                    tempView1 = self.presentView;
                    self.presentView = self.higherView;
                    self.higherView = self.nextView;
                    self.nextView = tempView1;
                    
                    //交换ScrollView
                    UIScrollView *tempScrollView1 = [[UIScrollView alloc] init];
                    tempScrollView1 = self.present;
                    self.present = self.higher;
                    self.higher = self.next;
                    self.next = tempScrollView1;
                    
                    //交换图片
                    UIImageView *tempImg1 = [[UIImageView alloc] init];
                    tempImg1 = self.presentImg;
                    self.presentImg = self.higherImg;
                    self.higherImg = self.nextImg;
                    self.nextImg = tempImg1;
                    
                    if (self.index<=0) {
                        
                        self.index = self.imgArr.count-1;
                    }else{
                        
                        self.index--;
                    }
                    
                    self.indexLabel.text = [NSString stringWithFormat:@"%zd",self.index+1];
                    
                }];
            }else{
                
                [UIView animateWithDuration:0.25 animations:^{
                    self.higherView.frame = self.higherFrame;
                }];
                
            }
            
        }else if (self.dire==directionLetf){//左滑
            
            CGRect frame = self.presentView.frame;
            if (frame.origin.x<(-frame.size.width/2)) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.higImage = self.presentImg.image;
                    //设置当前的
                    self.presentView.frame = self.higherFrame;
                    self.presentView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    //设置下一个的
                    self.nextView.frame = self.firstFrame;
                    self.nextView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    //设置上一个的
                    self.higherView.frame = self.firstFrame;
                    self.higherView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                    
                    //                [self.view insertSubview:self.higherView atIndex:0];
                    //                [self.view insertSubview:self.presentView atIndex:1];
                    //交换View
                    UIView *tempView2 = [[UIView alloc] init];
                    tempView2 = self.presentView;
                    self.presentView = self.nextView;
                    self.nextView = self.higherView;
                    self.higherView = tempView2;
                    //交换ScrollView
                    UIScrollView *tempScrollView2 = [[UIScrollView alloc] init];
                    tempScrollView2 = self.present;
                    self.present = self.next;
                    self.next = self.higher;
                    self.higher = tempScrollView2;
                    //交换图片
                    UIImageView *tempImg2 = [[UIImageView alloc] init];
                    tempImg2 = self.presentImg;
                    self.presentImg = self.nextImg;
                    self.nextImg = self.higherImg;
                    self.higherImg = tempImg2;
                    
                    
                    if (self.index>=self.imgArr.count-1) {
                        
                        self.index = 0;
                    }else{
                        
                        self.index++;
                    }
                    
                    self.indexLabel.text = [NSString stringWithFormat:@"%zd",self.index+1];
                } completion:^(BOOL finished) {
                    [self.view insertSubview:self.higherView atIndex:0];
                    
                }];
                
            }else{
                [UIView animateWithDuration:0.25 animations:^{
                    self.presentView.frame = self.firstFrame;
                }];
            }
        }
        
    }
    
    [self.view bringSubviewToFront:self.indexLabel];
    //注册KVO
    [self.presentView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    //注册KVO
    [self.higherView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    //设置不赋值状态
    self.dire = directionNome;
    
   
}



/**
 *
 * KVO :回调
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        
        if (self.dire==directionLetf) {//左滑
            [UIView animateWithDuration:0.25 animations:^{
                CGRect frame = self.presentView.frame;
                //计算出缩放百分比
                CGFloat f = (-frame.origin.x)/self.view.frame.size.width;
                //NSLog(@"%lf",f);
                self.nextView.transform = CGAffineTransformMakeScale(0.9+(f/10), 0.9+(f/10));
                //NSLog(@"%f",frame.origin.x);
            }];
        }else if (self.dire==directionRigth){//右滑
            
           // if(self.index!=0){//不是第一个
                CGRect frame = self.higherView.frame;
                //计算出缩放百分比
                CGFloat f = (-frame.origin.x)/self.view.frame.size.width;
                //NSLog(@"%lf",f);
                f = 1-f;
                [UIView animateWithDuration:0.25 animations:^{
                    self.presentView.transform = CGAffineTransformMakeScale(1.0-(f/10), 1.0-(f/10));
                    
                }];
            //}
        }
        
    }
}

/**
 *
 * 重力感应效果
 */
- (void)startupAnimationDone{
    
    NSLog(@"动画执行完毕");
    //创建重力类
    [UIAccelerometer sharedAccelerometer].updateInterval = 2.0/kUpdateFrequency;
    [[UIAccelerometer sharedAccelerometer] setDelegate:self];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration NS_DEPRECATED_IOS(2_0, 5_0) {
    //NSLog(@"X轴 = %lf  Y轴 = %lf  Z轴 = %lf",acceleration.x*100,acceleration.y*100,acceleration.z*100);
    
    CGPoint scrP = self.present.contentOffset;
    scrP.x = self.present.contentOffset.x-acceleration.x*10;
    CGFloat offX = self.firstDeautyImage.frame.origin.x;
    if(scrP.x<offX){
        
        scrP.x = offX;
    }
    
    if(scrP.x>(-offX)){
        
        scrP.x = (-offX);
    }
    
    [UIView animateWithDuration:2 animations:^{
        
        self.present.contentOffset = scrP;
    }];
}


/**
 *
 * 当前懒加载
 */
- (UIView *)firstView{
  
    if (!_firstView) {
        
        _firstView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.presentView = _firstView;
    }
    
    return _firstView;
}

- (UIScrollView *)firstScrollView{
    
    if(!_firstScrollView){
        
        _firstScrollView = [[UIScrollView alloc] initWithFrame:self.firstView.bounds];
        _firstScrollView.contentSize = CGSizeMake(0,0);
        _firstScrollView.scrollEnabled = YES;
        _firstScrollView.bounces = NO;
        _firstScrollView.userInteractionEnabled = NO;
        [self.firstView addSubview:_firstScrollView];
    }
    return _firstScrollView;
}
- (UIImageView *)firstDeautyImage{
    
    if (!_firstDeautyImage) {
        
        _firstDeautyImage = [[UIImageView alloc] init];
        _firstDeautyImage.userInteractionEnabled = NO;
        _firstDeautyImage.image = self.imgArr.firstObject;
        //_firstDeautyImage.image = [UIImage imageNamed:@"3"];
        CGFloat width = self.view.bounds.size.width+200;
        CGFloat heigth = self.view.bounds.size.height+200;
        
        _firstDeautyImage.frame = CGRectMake((-100),0,width,heigth);
        [self.firstScrollView addSubview:_firstDeautyImage];
    }
    return _firstDeautyImage;
}


/**
 *
 * 下一个懒加载
 */
- (UIView *)secondView{
    
    if (!_secondView) {
        
        _secondView = [[UIView alloc] initWithFrame:self.view.bounds];
        _secondView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
        self.nextView = _secondView;
    }
    
    return _secondView;
}

- (UIScrollView *)secondScrollView{
    
    if(!_secondScrollView){
        
        _secondScrollView = [[UIScrollView alloc] initWithFrame:self.secondView.bounds];
        _secondScrollView.contentSize = CGSizeMake(0,0);
        _secondScrollView.scrollEnabled = YES;
        _secondScrollView.bounces = NO;
        _secondScrollView.userInteractionEnabled = NO;
        [_secondScrollView addSubview:self.secondDeautyImage];
        [self.secondView addSubview:_secondScrollView];
    }
    return _secondScrollView;
}
- (UIImageView *)secondDeautyImage{
    
    if (!_secondDeautyImage) {
        
        _secondDeautyImage = [[UIImageView alloc] init];
        _secondDeautyImage.userInteractionEnabled = NO;
        //_secondDeautyImage.image = [UIImage imageNamed:@"1"];
        CGFloat width = self.view.bounds.size.width+200;
        CGFloat heigth = self.view.bounds.size.height+200;
        _secondDeautyImage.frame = CGRectMake((-100),0,width,heigth);
        
    }
    return _secondDeautyImage;
}

/**
 *
 * 上一个懒加载
 */
- (UIView *)thirdView{
    
    if (!_thirdView) {
        CGSize viewS = self.view.frame.size;
        _thirdView = [[UIView alloc] initWithFrame:CGRectMake(-viewS.width, 0, viewS.width, viewS.height)];
        self.higherView = _thirdView;
    }
    return _thirdView;
}
- (UIScrollView *)thirdScrollView{
    
    if(!_thirdScrollView){
        
        _thirdScrollView = [[UIScrollView alloc] initWithFrame:self.thirdView.bounds];
        _thirdScrollView.contentSize = CGSizeMake(0,0);
        _thirdScrollView.scrollEnabled = YES;
        _thirdScrollView.bounces = NO;
        _thirdScrollView.userInteractionEnabled = NO;
        [_thirdScrollView addSubview:self.thirdDeautyImage];
        [self.thirdView addSubview:_thirdScrollView];
    }
    return _thirdScrollView;
}
- (UIImageView *)thirdDeautyImage{
    
    if (!_thirdDeautyImage) {
        
        _thirdDeautyImage = [[UIImageView alloc] init];
        _thirdDeautyImage.userInteractionEnabled = NO;
        //_thirdDeautyImage.image = [UIImage imageNamed:@"2"];
        CGFloat width = self.view.bounds.size.width+200;
        CGFloat heigth = self.view.bounds.size.height+200;
        _thirdDeautyImage.frame = CGRectMake((-100),0,width,heigth);
        
    }
    return _thirdDeautyImage;
}

- (UILabel *)indexLabel{
    
    if (!_indexLabel) {
        
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 30, 20)];
        _indexLabel.font = [UIFont systemFontOfSize:18];
        _indexLabel.backgroundColor = [UIColor blackColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.text = [NSString stringWithFormat:@"%zd",self.index+1];
    }
    return _indexLabel;
}




@end
