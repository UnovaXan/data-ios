//
//  DataView.h
//  Data
//
//  Created by kevin Budain on 30/04/2015.
//  Copyright (c) 2015 kevin Budain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DataInformationView.h"
#import "DataViewController.h"

@interface DataView : UIView

@property (nonatomic) NSMutableArray *arrayData;
@property (nonatomic) UILabel *hoursLabel;
@property (nonatomic) UIView *contentData;
@property (nonatomic) DataInformationView *informationView;
@property (nonatomic) DataInformationView *allDataView;
@property (nonatomic) UIImageView *captionImageView;

@property (nonatomic) bool informationViewActive;
@property (nonatomic) int nbPhoto;
@property (nonatomic) int nbGeoloc;
@property (nonatomic) float distance;
@property (nonatomic) float delay;

- (void)initView:(UIViewController *)viewController;
- (void)drawData:(int)indexDay;
- (void)removeBorderButton;
- (void)scaleInformationView:(UIView *)view;
- (void)generateDataAfterSynchro:(Day *)currentDay;
- (void)activeCapta;

@end