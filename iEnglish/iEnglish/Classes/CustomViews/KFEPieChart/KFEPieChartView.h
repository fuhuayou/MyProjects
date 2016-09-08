//
//  FHYPieChartView.h
//  FHY_PieChart
//
//  Created by fuhuayou on 16/8/31.
//  Copyright © 2016年 fuhuayou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KFEPoint;
@class KFELine;
@class KFEPieChartShape;
@class KFEPieChartShapeView;
@class KFEMaskView;
@class KFETitleView;
@class KFEPieChartPartModel;
@protocol KFEPieChartViewDelegate;

typedef NS_ENUM(NSInteger,PieChartModelProperty)
{
    PCMProperty_backgroundColor,
    PCMProperty_title,
    PCMProperty_completeCountStr,
    PCMProperty_totalCountStr,
    PCMProperty_selectedPointCount
};


@interface KFEPieChartView : UIView



+(instancetype)drawPicChartViewWithPieChartPartModels:(NSArray<KFEPieChartPartModel *> *)models
                                      picChartRadius:(CGFloat)radius ;
//pic chart radius.
@property(nonatomic, assign,readonly)CGFloat picChartRadius;

//5 KFEPieChartPartModel models of the pie chart.
@property(nonatomic, strong,readonly)NSArray<KFEPieChartPartModel *> *pieChartPartModels;

@property(nonatomic, weak)id<KFEPieChartViewDelegate> delegate;

-(void)updateTitleText:(NSString *)newTitleText index:(int)partIndex;

- (void)updateCompleteNum:(int)completeNum index:(int)partIndex;

-(void)updateCompleteNumText:(NSString *)newCompleteText index:(int)partIndex;

-(void)updateTotalNumText:(NSString *)newTotalText index:(int)partIndex;

- (void)updateColor:(UIColor *)newColor index:(int)partIndex;

- (void)updatePieChartRadius:(CGFloat)newRadius;

@end


@protocol KFEPieChartViewDelegate <NSObject>

-(void)pieChartView:(KFEPieChartView *)pieChartView didSelectedWithIndex:(int)index;

@end



/*!
 * @abstract KFEPieChartShapeView is the 5 sectors in the big circle.
 */
@interface KFEPieChartShapeView : UIView

//the shape layer.
@property(nonatomic,strong)CAShapeLayer *chartShapeLayer;

@property(nonatomic,assign)CGFloat chartShapeRadius;

@property(nonatomic,assign) int index;// which one.

@property(nonatomic,strong)KFETitleView *titleView;

- (instancetype)initWithCenter:(CGPoint)center
                    beginAngle:(double)beginAngle
                      endAngle:(double)endAngle
                  circleRadius:(CGFloat)cirRadius
                     lineWidth:(CGFloat)lineWidth
                         index:(int)index;

-(void)selectedAnimationWithIndex:(int)index;

@end



/*!
 * @abstract KFEPoint is the 65 litle points of the big circle around.
 */
@interface KFEPoint : UIView

//the radius of the point.
@property(nonatomic,assign, readonly)CGFloat radius;

//which one of the pie Chart.
@property(nonatomic,assign)int index;

/*
    The isSelected property just affect the point's backgroud color.
    1. default selected color: yellow
    
    2. default unselected color is gray.
 */
@property(nonatomic,assign)BOOL isSelected;

- (instancetype)initWithPerPointAngle:(double)perPointAngle
                                index:(int)index
                         bigCirRadius:(CGFloat)bigCirRadius
                         bigCirCenter:(CGPoint)bigCirCenter;

@end



/*!
 * @abstract KFELine is the 5 short line of the big circle around. it mark the spreading
 * of big circle.
 */
@interface KFELine : CAShapeLayer

@property(nonatomic,assign)CGFloat length;//line length.

@property(nonatomic,assign)CGPoint benginPoint;

@property(nonatomic,assign)CGPoint endPoint;

@property(nonatomic,assign)int index; //which one of the pie Chart.

- (instancetype)initWithPerPointAngle:(double)perPointAngle
                                index:(int)index
                         bigCirRadius:(CGFloat)bigCirRadius
                         bigCirCenter:(CGPoint)bigCirCenter;

@end



/*!
 @abstract KFEMaskView is used for the click event.
 
 * KFEMaskView spread the circle to 5 parts. When click differert response for different
 * part's action.
 */
@interface KFEMaskView : UIView

@property(nonatomic,assign)CGFloat maskRadius;

@property(nonatomic,strong)void (^didSlectedResponeBlock)(int index);


@property(nonatomic,strong)NSMutableArray *picChartViewsArray;


- (instancetype)initWithCenter:(CGPoint)center radius:(CGFloat)radius;

@end


/*!
 @abstract KFETitleView is used for the text in each part.

 1. the title of the part
 
 2. the total count and complete count
 */
@interface KFETitleView : UIView

- (instancetype)initWithPerPointAngle:(double)perPointAngle
                                index:(int)index
                            cirRadius:(CGFloat)cirRadius
                         circleCenter:(CGPoint)circleCenter;

@property(nonatomic, strong)UILabel *titleLabel;

@property(nonatomic, strong)UILabel *totalNumLabel;

@property(nonatomic, strong)UILabel *completeNumLabel;


-(void)setTitleLabelText:(NSString *)text;

-(void)setTotalNumLabelText:(NSString *)text;

-(void)setCompleteNumLabelText:(NSString *)text;
@end



/*!
 @abstract KFEPieChartPartModel is model for the Data of the part of the pie chart.
 */
@interface KFEPieChartPartModel : NSObject

@property(nonatomic, assign)int index;//which one

@property(nonatomic, strong)UIColor *backgroundColor;//the one's background color

@property(nonatomic, strong)NSString *title;//the of curent part.

@property(nonatomic, strong)NSString *completeCountStr;// complete cout value.

@property(nonatomic, strong)NSString *totalCountStr;// total count value

@property(nonatomic, assign)int selectedPointCount;// the selected points of current part.


+(NSMutableArray *)caculateTheAroundPointsSelectedIndexsFromModels:(NSArray *)models;


+(NSMutableArray *)updateAroundPointsSelectedToPartWithCount:(int)count
                                                       index:(int)whichPart
                                      oldSelectedPointsArray:(NSArray *)oldSelectedPointsArray;

+(void)changeModelsProperty:(NSArray *)models modelPeoperty:(PieChartModelProperty)property value:(id)value index:(int)index;
@end







