//
//  RootViewController.m
//  mapDemo
//
//  Created by xingzhi on 16/5/16.
//  Copyright © 2016年 xingzhi. All rights reserved.
//

#import "RootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MAMapKit/MAMapKit.h>
@interface RootViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *_locationManeger;
    CLGeocoder *_geocoder;

}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
   [self noVenderMap];
    
    
    
}




- (void)noVenderMap {
    //定位管理器
    _locationManeger = [[CLLocationManager alloc] init];
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开");
        return;
    }
    
    //如果没有授权请求用户授权
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManeger requestAlwaysAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ) {
        
        //设置代理
        _locationManeger.delegate = self;
        //定位精度
        _locationManeger.desiredAccuracy = kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance=10.0;//十米定位一次
        _locationManeger.distanceFilter=distance;
        //启动跟踪定位
        [_locationManeger startUpdatingLocation];
        
    }
    _geocoder=[[CLGeocoder alloc]init];
    [self getCoordinateByAddress:@"北京"];
    [self getAddressByLatitude:39.54 longitude:116.28];

}




#pragma mark 根据地名确定地理坐标
-(void)getCoordinateByAddress:(NSString *)address{
    //地理编码
    [_geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        //取得第一个地标，地标中存储了详细的地址信息，注意：一个地名可能搜索出多个地址
        CLPlacemark *placemark=[placemarks firstObject];
        
        CLLocation *location=placemark.location;//位置
        CLRegion *region=placemark.region;//区域
        NSDictionary *addressDic= placemark.addressDictionary;//详细地址信息字典,包含以下部分信息
        //        NSString *name=placemark.name;//地名
        //        NSString *thoroughfare=placemark.thoroughfare;//街道
        //        NSString *subThoroughfare=placemark.subThoroughfare; //街道相关信息，例如门牌等
        //        NSString *locality=placemark.locality; // 城市
        //        NSString *subLocality=placemark.subLocality; // 城市相关信息，例如标志性建筑
        //        NSString *administrativeArea=placemark.administrativeArea; // 州
        //        NSString *subAdministrativeArea=placemark.subAdministrativeArea; //其他行政区域信息
        //        NSString *postalCode=placemark.postalCode; //邮编
        //        NSString *ISOcountryCode=placemark.ISOcountryCode; //国家编码
        //        NSString *country=placemark.country; //国家
        //        NSString *inlandWater=placemark.inlandWater; //水源、湖泊
        //        NSString *ocean=placemark.ocean; // 海洋
        //        NSArray *areasOfInterest=placemark.areasOfInterest; //关联的或利益相关的地标
        NSLog(@"位置:%@,区域:%@,详细信息:%@",location,region,addressDic);
    }];
}

#pragma mark 根据坐标取得地名
-(void)getAddressByLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude{
    //反地理编码
    CLLocation *location=[[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        NSLog(@"详细信息:%@",placemark.addressDictionary);
    }];
}




//地理编码：根据给定的位置（通常是地名）确定地理坐标(经、纬度)。
//逆地理编码：可以根据地理坐标（经、纬度）确定位置信息（街道、门牌等）

//#pragma mark------------------定位代理方法
////跟踪定位代理方法，每次位置发生变化即会执行（只要定位到相应位置）
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
//    CLLocation *location=[locations firstObject];//取出第一个位置
//    CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
//    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
//    //如果不需要实时定位，使用完即使关闭定位服务
//    [_locationManege
//     zr stopUpdatingLocation];
//}
//

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 
 
 
 
 
 
 
 
 
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
