//
//  FHYPieChartView.m
//  FHY_PieChart
//
//  Created by fuhuayou on 16/8/31.
//  Copyright © 2016年 fuhuayou. All rights reserved.
//

#import "KFEPieChartView.h"

#define  rgb(r,g,b) [UIColor colorWithRed:(float)(r/255.0) green:(float)(g/255.0) blue:(float)(b/255.0) alpha:1.0]


@interface KFEPieChartView ()

@property(nonatomic,strong)NSMutableArray *pieChartViewsArray;//5 parts of the pie chart.

@property(nonatomic,strong)NSMutableArray *aroundPointsArray;// 60 points around the pie chart.

@property(nonatomic,strong)NSMutableArray *aroundSpreadShortLinesArray;//5 short line shape around.

@property(nonatomic,strong)NSMutableArray *selectedAroundPointsIndexsArray;// 60 points around the pie chart.

@property(nonatomic, assign)CGPoint picChartCenter;//the pic chart center.

@property(nonatomic,strong)KFEMaskView *maskView;//just for the click event.

@end

@implementation KFEPieChartView

+(instancetype)drawPicChartViewWithPieChartPartModels:(NSArray<KFEPieChartPartModel *> *)models
                                      picChartRadius:(CGFloat)radius
{
    return [[KFEPieChartView alloc] initWithPartModels:models picChartRadius:radius];
}

-(instancetype)initWithPartModels:(NSArray<KFEPieChartPartModel *> *)models picChartRadius:(CGFloat)radius
{
    if(self=[super init])
    {
        _picChartRadius=radius;
        _pieChartPartModels=models;
        _pieChartViewsArray=[NSMutableArray array];
        _aroundPointsArray=[NSMutableArray array];
        _aroundSpreadShortLinesArray=[NSMutableArray array];
        _selectedAroundPointsIndexsArray=[NSMutableArray array];
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
     _picChartCenter=CGPointMake(self.bounds.size.width/2.000, self.bounds.size.height/2.000);
    [self drawAllViews];
}

-(void)drawAllViews
{
    //get the circle around selected point.
    _selectedAroundPointsIndexsArray=[KFEPieChartPartModel caculateTheAroundPointsSelectedIndexsFromModels:_pieChartPartModels];
    
    //1. draw the around point and short line
    [self drawAllAroundPointsWithCircleRadius:_picChartRadius center:_picChartCenter];
    
    //2. draw the circle in the midle.
    [self drawPieChartsWithRadius:_picChartRadius center:_picChartCenter];
    
    //3. add the mask view for touch event, just for he control event.
    [self addMaskViewForEvent];
}

-(void)addMaskViewForEvent
{
    _maskView =[[KFEMaskView alloc] initWithCenter:_picChartCenter radius:_picChartRadius];
    
    __weak KFEPieChartView *weakSelf=self;
    _maskView.didSlectedResponeBlock=^(int index){
        if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(pieChartView:didSelectedWithIndex:)]){
            [weakSelf.delegate  pieChartView:weakSelf didSelectedWithIndex:index];
        }
    };
    _maskView.picChartViewsArray=_pieChartViewsArray;
    [self addSubview:_maskView];
}


-(void)drawPieChartsWithRadius:(CGFloat)radius center:(CGPoint)center
{
    double perPointAngle=2.0000*M_PI/5.00;
    for(int index=0; index<5;index++)
    {
        KFEPieChartShapeView* pieView=[[KFEPieChartShapeView alloc] initWithCenter:center beginAngle:-M_PI_2+index*perPointAngle endAngle:-M_PI_2+index*perPointAngle+perPointAngle circleRadius:radius-8 lineWidth:5 index:index];
        [_pieChartViewsArray addObject:pieView];
        
        KFEPieChartPartModel *model=[_pieChartPartModels objectAtIndex:index];
        pieView.chartShapeLayer.fillColor=model.backgroundColor.CGColor;
        pieView.chartShapeLayer.strokeColor=[UIColor blackColor].CGColor;
        pieView.titleView.titleLabel.text=model.title;
        pieView.titleView.totalNumLabel.text=model.totalCountStr;
        pieView.titleView.completeNumLabel.text=model.completeCountStr;
        
        [self addSubview:pieView];
    }
}


-(void)drawAllAroundPointsWithCircleRadius:(CGFloat)cirecleRadius center:(CGPoint)center
{
    double perPointAngle=2.0000*M_PI/65.000;
    for(int index=0; index<65; index++)// all is 65 point.
    {
        if((index+1)%13==0)
        {
            KFELine *oneLine=[[KFELine alloc] initWithPerPointAngle:perPointAngle index:index bigCirRadius:cirecleRadius bigCirCenter:center];
            [self.layer addSublayer:oneLine];
            [_aroundSpreadShortLinesArray addObject:oneLine];
            continue;
        }
        KFEPoint *onePoint=[[KFEPoint alloc] initWithPerPointAngle:perPointAngle
                                                             index:index
                                                      bigCirRadius:cirecleRadius
                                                      bigCirCenter:center];
        [self addSubview:onePoint];
        [_aroundPointsArray addObject:onePoint];
         onePoint.isSelected=NO;
        if([_selectedAroundPointsIndexsArray containsObject:@(index)])
        {
            onePoint.isSelected=YES;
        }
    }
}


#pragma mark- update contol of the pie chart.

-(void)updateTitleText:(NSString *)newTitleText index:(int)partIndex
{
    [KFEPieChartPartModel changeModelsProperty:_pieChartPartModels modelPeoperty:PCMProperty_title value:newTitleText index:partIndex];
    
    for (KFEPieChartShapeView *pieView in _pieChartViewsArray) {
        if(pieView.index==partIndex){
            [pieView.titleView setTitleLabelText:newTitleText];
            break;
        }
    }
}

-(void)updateCompleteNum:(int)completeNum index:(int)partIndex
{
    [KFEPieChartPartModel changeModelsProperty:_pieChartPartModels modelPeoperty:PCMProperty_selectedPointCount value:[NSNumber numberWithInt:completeNum] index:partIndex];
    
    _selectedAroundPointsIndexsArray=[KFEPieChartPartModel updateAroundPointsSelectedToPartWithCount:completeNum
                                                                                               index:partIndex
                                                                              oldSelectedPointsArray:_selectedAroundPointsIndexsArray];
  for(KFEPoint *onePoint in _aroundPointsArray){
      if([_selectedAroundPointsIndexsArray containsObject:@(onePoint.index)]){
          onePoint.isSelected=YES;
      }
      else{
          onePoint.isSelected=NO;
      }
  }
}

-(void)updateCompleteNumText:(NSString *)newCompleteText index:(int)partIndex
{
    [KFEPieChartPartModel changeModelsProperty:_pieChartPartModels modelPeoperty:PCMProperty_completeCountStr value:newCompleteText index:partIndex];
    
    for (KFEPieChartShapeView *pieView in _pieChartViewsArray) {
        if(pieView.index==partIndex){
            [pieView.titleView setCompleteNumLabelText:newCompleteText];
            break;
        }
    }
}

-(void)updateTotalNumText:(NSString *)newTotalText index:(int)partIndex
{
    [KFEPieChartPartModel changeModelsProperty:_pieChartPartModels modelPeoperty:PCMProperty_totalCountStr value:newTotalText index:partIndex];
    
    for (KFEPieChartShapeView *pieView in _pieChartViewsArray) {
        if(pieView.index==partIndex){
            [pieView.titleView setTotalNumLabelText:newTotalText];
            break;
        }
    }
}

- (void)updateColor:(UIColor *)newColor index:(int)partIndex
{
    
    [KFEPieChartPartModel changeModelsProperty:_pieChartPartModels modelPeoperty:PCMProperty_backgroundColor value:newColor index:partIndex];
    for(KFEPieChartShapeView* pieView in _pieChartViewsArray){
        if(pieView.index==partIndex) {
            pieView.chartShapeLayer.fillColor=newColor.CGColor;
            break;
        }
    }
}

- (void)updatePieChartRadius:(CGFloat)newRadius
{
    [self removeAllSubViewsOfPieChartView];
    _picChartRadius=newRadius;
    [self drawAllViews];
    
}

-(void)removeAllSubViewsOfPieChartView
{
    for (UIView *view in _pieChartViewsArray) {
        [view removeFromSuperview];
    }
    [_pieChartViewsArray removeAllObjects];
    
    for(UIView *view in _aroundPointsArray)
    {
        [view removeFromSuperview];
    }
    [_aroundPointsArray removeAllObjects];
    
    for(KFELine *oneLine in _aroundSpreadShortLinesArray)
    {
        [oneLine removeFromSuperlayer];
    }
    [_aroundSpreadShortLinesArray removeAllObjects];
    
    [_maskView removeFromSuperview];
    _maskView=nil;
}

#pragma mark-



@end


@implementation KFEPieChartShapeView

- (instancetype)initWithCenter:(CGPoint)center
                    beginAngle:(double)beginAngle
                      endAngle:(double)endAngle
                  circleRadius:(CGFloat)cirRadius
                     lineWidth:(CGFloat)lineWidth
                         index:(int) index
{
    self = [super init];
    if (self) {
        
        self.frame=CGRectMake(0, 0, 50, 50);
        self.center=center;
        self.index=index;
        self.chartShapeRadius=cirRadius;
        
        //1. draw pie chart.
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(25, 25)];
        [path addArcWithCenter:CGPointMake(25, 25) radius:cirRadius startAngle:beginAngle endAngle:endAngle clockwise:YES];
        [path closePath];
        _chartShapeLayer=[CAShapeLayer layer];
        [_chartShapeLayer setPath:path.CGPath];
        _chartShapeLayer.lineWidth=lineWidth;
        [self.layer addSublayer:_chartShapeLayer];
        
        //2. draw text view.
        _titleView=[[KFETitleView alloc] initWithPerPointAngle:2*M_PI/10.0 index:self.index cirRadius:self.chartShapeRadius/2.00+5 circleCenter:CGPointMake(25, 25)];
        [_titleView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_titleView];
    }
    return self;
}

-(void)selectedAnimationWithIndex:(int)index
{
    static BOOL isAnimating=NO;
    if(isAnimating==YES) return;
    isAnimating=YES;
    CGPoint center=self.center;
    
    double perPointAngle=2*M_PI/10.000;
    double pointAngle=2.00*perPointAngle*(CGFloat)index + perPointAngle;
    CGFloat dX=10 * sin(pointAngle);
    CGFloat dY=10 * cos(pointAngle);
    CGFloat pointX=self.center.x+dX;
    CGFloat pointY=self.center.y-dY;

    [UIView animateWithDuration:0.3 animations:^{
        self.center= CGPointMake(pointX, pointY);
    } completion:^(BOOL finish){
        if(finish==YES)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.center=center;
                isAnimating=NO;
            }];
        }
    } ];
}


@end




@implementation KFEPoint


- (instancetype)initWithPerPointAngle:(double)perPointAngle
                                index:(int)index
                         bigCirRadius:(CGFloat)bigCirRadius
                         bigCirCenter:(CGPoint)bigCirCenter
{
    self = [super init];
    if (self) {
        double pointAngle=perPointAngle*(CGFloat)(index+1);
        CGFloat dX=bigCirRadius * sin(pointAngle);
        CGFloat dY=bigCirRadius * cos(pointAngle);
        CGFloat pointX=bigCirCenter.x+dX;
        CGFloat pointY=bigCirCenter.y-dY;
        _index=index;
        [self drawWithCenter:CGPointMake(pointX, pointY) radius:3];
        
    }
    return self;
}

- (void)drawWithCenter:(CGPoint)center radius:(CGFloat) radius;
{
        CGRect font=CGRectMake(0, 0, 2.0*radius, 2.0*radius);
        self.frame = font;
        self.center=center;
        _radius=radius;
        
        self.layer.cornerRadius=self.radius;
        self.clipsToBounds=YES;
}

-(void)setIsSelected:(BOOL)isSelected
{
    _isSelected=isSelected;
    if(_isSelected==YES)
    {
        [self setBackgroundColor:[UIColor yellowColor]];
    }else{
        [self setBackgroundColor:[UIColor grayColor]];
    }
}

@end


@implementation KFELine

- (instancetype)initWithPerPointAngle:(double)perPointAngle
                                index:(int)index
                         bigCirRadius:(CGFloat)bigCirRadius
                         bigCirCenter:(CGPoint)bigCirCenter
{
    self = [super init];
    if (self) {
        double pointAngle=perPointAngle*(CGFloat)(index+1);
        CGFloat dX=bigCirRadius * sin(pointAngle);
        CGFloat dY=bigCirRadius * cos(pointAngle);
        CGFloat pointX=bigCirCenter.x+dX;
        CGFloat pointY=bigCirCenter.y-dY;
        [self drawWithCenter:CGPointMake(pointX, pointY) lineLength:10 lineWidth:1.5 indexAngle:pointAngle];
        
    }
    return self;
}

- (void)drawWithCenter:(CGPoint)center lineLength:(CGFloat)length lineWidth:(CGFloat)lineWidth indexAngle:(double)indexAngle
{
    CGFloat dX=length/2.00*sin(indexAngle);
    CGFloat dY=length/2.00*cos(indexAngle);
    CGPoint point1=CGPointMake(center.x-dX, center.y+dY);
    CGPoint point2=CGPointMake(center.x+dX, center.y-dY);
    //画一个直线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addLineToPoint:point2];
    [path closePath];

    self.path=path.CGPath;
    self.lineWidth=lineWidth;
    self.fillColor=[UIColor grayColor].CGColor;
    self.strokeColor=[UIColor grayColor].CGColor;//use
}

@end

@implementation KFEMaskView

- (instancetype)initWithCenter:(CGPoint)center radius:(CGFloat)radius
{
    self = [super init];
    if (self) {
        self.maskRadius=radius;
        self.frame=CGRectMake(center.x, center.y, radius*2.00, radius*2.00);
        self.center=center;
        self.layer.cornerRadius=radius;
        [self setBackgroundColor:[UIColor clearColor]];
        self.clipsToBounds=YES;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch =[touches anyObject];
    CGPoint point = [touch locationInView:self];
    //first space
    double dX=point.x- self.bounds.size.width/2;
    double dY=point.y- self.bounds.size.height/2;
    if(dX<0) dX=-dX;
    if(dY<0) dY=-dY;
    double sX=dX*dX;
    double sY=dY*dY;
    BOOL isInCircle=sX+sY<=(_maskRadius*_maskRadius);
    double perPartAngle=2*M_PI/5.000;
    
    if(isInCircle && point.x>_maskRadius && point.y<_maskRadius && (dY/dX)>tan(M_PI_2-perPartAngle))//first one
    {
        if(_picChartViewsArray.count>=1)
        {
            KFEPieChartShapeView *picChartView3=[_picChartViewsArray objectAtIndex:0];
            [picChartView3 selectedAnimationWithIndex:0];
        }
        if(_didSlectedResponeBlock){
            _didSlectedResponeBlock(0);
        }
        NSLog(@"the first one...............%f----%f",point.x,point.y);
    }
    else if(isInCircle && point.x>_maskRadius && ((dY/dX<tan(M_PI_2-perPartAngle)&&point.y<_maskRadius) || (dY/dX<tan(perPartAngle-(M_PI_2-perPartAngle))&&point.y>=_maskRadius)))
    {
        if(_picChartViewsArray.count>=2)
        {
            KFEPieChartShapeView *picChartView3=[_picChartViewsArray objectAtIndex:1];
            [picChartView3 selectedAnimationWithIndex:1];
        }
        if(_didSlectedResponeBlock){
            _didSlectedResponeBlock(1);
        }
        NSLog(@"the Second one...............%f----%f",point.x,point.y);
    }
    else if(isInCircle && point.y>_maskRadius &&(dX/dY<tan(M_PI-2*perPartAngle)))
    {
        if(_picChartViewsArray.count>=3)
        {
             KFEPieChartShapeView *picChartView3=[_picChartViewsArray objectAtIndex:2];
            [picChartView3 selectedAnimationWithIndex:2];
        }
        if(_didSlectedResponeBlock){
            _didSlectedResponeBlock(2);
        }
        NSLog(@"the third one...............%f----%f",point.x,point.y);
    }
    else if(isInCircle && point.x<_maskRadius && ((dY/dX<tan(M_PI_2-perPartAngle)&&point.y<_maskRadius) || (dY/dX<tan(perPartAngle-(M_PI_2-perPartAngle))&&point.y>=_maskRadius)))
    {
        if(_picChartViewsArray.count>=4)
        {
            KFEPieChartShapeView *picChartView3=[_picChartViewsArray objectAtIndex:3];
            [picChartView3 selectedAnimationWithIndex:3];
        }
        if(_didSlectedResponeBlock){
            _didSlectedResponeBlock(3);
        }
        NSLog(@"the fourth one...............%f----%f",point.x,point.y);
    }
    else if(isInCircle && point.x<_maskRadius && point.y<_maskRadius && (dY/dX)>tan(M_PI_2-perPartAngle))//first one
    {
        if(_picChartViewsArray.count>=5)
        {
            KFEPieChartShapeView *picChartView3=[_picChartViewsArray objectAtIndex:4];
            [picChartView3 selectedAnimationWithIndex:4];
        }
        if(_didSlectedResponeBlock){
            _didSlectedResponeBlock(4);
        }
        NSLog(@"the fifth one...............%f----%f",point.x,point.y);
    }
}
@end


@implementation KFETitleView

- (instancetype)initWithPerPointAngle:(double)perPointAngle
                                index:(int)index
                            cirRadius:(CGFloat)cirRadius
                         circleCenter:(CGPoint)circleCenter
{
    self = [super init];
    if (self) {
        
        _titleLabel=[[UILabel alloc] init];
        _totalNumLabel=[[UILabel alloc] init];
        _completeNumLabel=[[UILabel alloc] init];
        
        double pointAngle=2.00*perPointAngle*(CGFloat)index + perPointAngle;
        CGFloat dX=cirRadius * sin(pointAngle);
        CGFloat dY=cirRadius * cos(pointAngle);
        CGFloat pointX=circleCenter.x+dX;
        CGFloat pointY=circleCenter.y-dY;
        
        self.frame=CGRectMake(0, 0, 100, 50);
        self.center=CGPointMake(pointX, pointY);
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
//    _titleLabel.text=@"VISUALISE";
    _titleLabel.textAlignment=NSTextAlignmentCenter;
//    _totalNumLabel.text=@"28";
//    _completeNumLabel.text=@"12";
    _completeNumLabel.textAlignment=NSTextAlignmentRight;
    _titleLabel.frame=CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/2.00);
    
    _completeNumLabel.frame=CGRectMake(0, self.bounds.size.height/2.00, self.bounds.size.width/2.00-5, self.bounds.size.height/2.00);
    UILabel *handrailLabel=[[UILabel alloc] init];
    handrailLabel.frame=CGRectMake(self.bounds.size.width/2.00-5, self.bounds.size.height/2.00, 10, self.bounds.size.height/2.00);
    handrailLabel.text=@"/";
    _totalNumLabel.frame=CGRectMake(self.bounds.size.width/2.00+5, self.bounds.size.height/2.00, self.bounds.size.width/2.00-5, self.bounds.size.height/2.00);
    
    [self addSubview:_titleLabel];
    [self addSubview:_completeNumLabel];
    [self addSubview:handrailLabel];
    [self addSubview:_totalNumLabel];
    
    _titleLabel.textColor=[UIColor whiteColor];
    _titleLabel.font=[UIFont boldSystemFontOfSize:16];
    
    _completeNumLabel.textColor=[UIColor whiteColor];
    _completeNumLabel.font=[UIFont boldSystemFontOfSize:15];
    
    handrailLabel.textColor=[UIColor whiteColor];
    _totalNumLabel.textColor=[UIColor whiteColor];
    _totalNumLabel.font=[UIFont systemFontOfSize:15];
}

-(void)setTitleLabelText:(NSString *)text
{
    _titleLabel.text=text;
}


-(void)setTotalNumLabelText:(NSString *)text
{
    _totalNumLabel.text=text;
}

-(void)setCompleteNumLabelText:(NSString *)text
{
    _completeNumLabel.text=text;
}

@end



@implementation KFEPieChartPartModel

+(NSMutableArray *)caculateTheAroundPointsSelectedIndexsFromModels:(NSArray *)models
{
    NSMutableArray *indexs=[NSMutableArray array];
    for(KFEPieChartPartModel *model in models)
    {
        if(model.selectedPointCount>0)
        {
            for(int pointIndex=0; pointIndex<model.selectedPointCount; pointIndex++)
            {
                [indexs addObject:@(13*model.index+pointIndex)];
                
            }
        }
    }
    return [indexs mutableCopy];
}



+(NSMutableArray *)updateAroundPointsSelectedToPartWithCount:(int)count
                                                       index:(int)whichPart
                                      oldSelectedPointsArray:(NSArray *)oldSelectedPointsArray
{
    
    NSMutableArray *oldSelectedPointsIndex=[oldSelectedPointsArray mutableCopy];
    
    for(int pointIndex=0; pointIndex<13; pointIndex++)
    {
        if([oldSelectedPointsIndex containsObject:@(13*whichPart+pointIndex)])
        {
//            NSLog(@"remove===================New point: %@",@(13*whichPart+pointIndex));
            [oldSelectedPointsIndex removeObject:@(13*whichPart+pointIndex)];
        }
    }
    
    for(int pointIndex=0; pointIndex<count; pointIndex++)
    {
        if(pointIndex<count && ![oldSelectedPointsIndex containsObject:@(13*whichPart+pointIndex)])
        {
//            NSLog(@"ADD===================New point: %@",@(13*whichPart+pointIndex));
            [oldSelectedPointsIndex addObject:@(13*whichPart+pointIndex)];
        }
    }
    return oldSelectedPointsIndex;
}

+(void)changeModelsProperty:(NSArray *)models modelPeoperty:(PieChartModelProperty)property value:(id)value index:(int)index
{
    
    KFEPieChartPartModel *targetModel;
    for(KFEPieChartPartModel *model in  models){
        if(model.index== index){
            targetModel=model;
            break;
        }
    }
    switch (property) {
        case PCMProperty_backgroundColor:
            targetModel.backgroundColor=(UIColor *)value;
            break;
        case PCMProperty_title:
            targetModel.title=(NSString *)value;
            break;
        case PCMProperty_completeCountStr:
            targetModel.completeCountStr=(NSString *)value;
            break;
        case PCMProperty_totalCountStr:
            targetModel.totalCountStr=(NSString *)value;
            break;
        case PCMProperty_selectedPointCount:
            targetModel.selectedPointCount=[value intValue];
            break;
        default:
            break;
    }
}






@end


