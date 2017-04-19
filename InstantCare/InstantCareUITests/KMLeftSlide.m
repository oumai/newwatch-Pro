//
//  KMLeftSlide.m
//  InstantCare
//
//  Created by KM on 2016/12/29.
//  Copyright © 2016年 kangmei. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface KMLeftSlide : XCTestCase

@end

@implementation KMLeftSlide

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [[[app.navigationBars[@"首页"] childrenMatchingType:XCUIElementTypeButton] elementBoundByIndex:0] tap];
    [[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeImage].element tap];
    
    
}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

@end
