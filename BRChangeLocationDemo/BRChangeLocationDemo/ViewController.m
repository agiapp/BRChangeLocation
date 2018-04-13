//
//  ViewController.m
//  BRChangeLocationDemo
//
//  Created by 任波 on 2018/4/12.
//  Copyright © 2018年 91renb. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "BRChangeLocation.h"

@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) UILabel *loacLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    // 如果要想知道任意位置的坐标，去高德地图 http://lbs.amap.com/console/show/picker，选中自己要定位的坐标
    // 通过高德地图得到的是高德的坐标系，然后再通过代码转换成WGS坐标系，最后去MyLocation.gpx文件里修改经纬度即可
    // 打卡坐标（高德坐标系值）：（创业软件：120.186108, 30.188364）（宝龙城：120.167714, 30.188638）
    // 打卡坐标（WGS坐标系值）：120.181512, 30.190756
//    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(30.188638, 120.167714);
//    CLLocationCoordinate2D WGSlocation2D = [BRChangeLocation gcj02ToWgs84:location2D];
//    NSLog(@"打卡坐标（WGS坐标系值）: (%f, %f)",WGSlocation2D.latitude , WGSlocation2D.longitude);
    
    [self.manager startUpdatingLocation];
}

- (CLLocationManager *)manager {
    if (!_manager) {
        _manager = [[CLLocationManager alloc]init];
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        _manager.distanceFilter = 10;
        _manager.delegate = self;
        [_manager requestWhenInUseAuthorization];
    }
    return _manager;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    // 当前的经纬度
    NSLog(@"当前的经纬度 %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    CLLocationCoordinate2D WGSlocation2D = [BRChangeLocation wgs84ToGcj02:currentLocation.coordinate];
    currentLocation = [[CLLocation alloc]initWithLatitude:WGSlocation2D.latitude longitude:WGSlocation2D.longitude];
    //地理反编码 可以根据坐标(经纬度)确定位置信息(街道 门牌等)
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count >0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *currentCity = placeMark.locality;
            if (!currentCity) {
                currentCity = @"无法定位当前城市";
            }
            //看需求定义一个全局变量来接收赋值
            NSLog(@"定位地址：%@,%@,%@,%@", currentCity, placeMark.subLocality, placeMark.thoroughfare, placeMark.name);
            
            NSString *address = [NSString stringWithFormat:@"定位地址：%@%@%@ \n\n%@", currentCity, placeMark.subLocality, placeMark.thoroughfare, placeMark.name];
            self.loacLabel.text = address;
        }
    }];
}

- (UILabel *)loacLabel {
    if (!_loacLabel) {
        _loacLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, self.view.bounds.size.width - 40, self.view.bounds.size.height - 100)];
        _loacLabel.backgroundColor = [UIColor clearColor];
        _loacLabel.textAlignment = NSTextAlignmentCenter;
        _loacLabel.numberOfLines = 0;
        _loacLabel.font = [UIFont systemFontOfSize:30.0f];
        _loacLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_loacLabel];
    }
    return _loacLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
