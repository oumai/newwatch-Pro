//
//  PNChartDelegate.h
//  PNChartDemo
//
//  Created by kevinzhow on 13-12-11.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PNBar;

@class PNLineChart;

@protocol PNChartDelegate <NSObject>
@optional
/**
 * Callback method that gets invoked when the user taps on the chart line.
 */
- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex;

- (void)userClickedOnChart:(PNLineChart *)lineChart
                 lineIndex:(NSInteger)lineIndex
                pointIndex:(NSInteger)pointIndex;

/**
 * Callback method that gets invoked when the user taps on a chart line key point.
 */
- (void)userClickedOnLineKeyPoint:(CGPoint)point
                        lineIndex:(NSInteger)lineIndex
                       pointIndex:(NSInteger)pointIndex;


/**
 * Callback method that gets invoked when the user taps on a chart bar.
 */
- (void)userClickedOnBar:(PNBar *)bar
                   Index:(NSInteger)barIndex;


- (void)userClickedOnPieIndexItem:(NSInteger)pieIndex;
- (void)didUnselectPieItem;
@end
