//
//  VENDORViewController.m
//  mapDemo
//
//  Created by xingzhi on 16/5/20.
//  Copyright © 2016年 xingzhi. All rights reserved.
//

#import "VENDORViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "FortjViewController.h"
#import "GeocodeAnnotation.h"
#import "CommonUtility.h"
#import "ReGeocodeAnnotation.h"
@interface VENDORViewController ()<MAMapViewDelegate, AMapSearchDelegate,UIGestureRecognizerDelegate, MAOverlay>
{
    MAMapView * _mapview;
    AMapSearchAPI *_search;
    int a;
}
@property (nonatomic, strong) UIButton *geocode;
@property (nonatomic, strong) UIButton *pu;
@property (nonatomic, strong) UIButton *poi;
@property (nonatomic, strong) UIButton *road;
@property (nonatomic,retain) MAUserLocation *currentLocation;
@property (nonatomic,retain) AMapPOI *currentPOI;
@property (nonatomic,retain) MAPointAnnotation *destinationPoint;//目标点
@property (nonatomic,retain) NSString *currentCity;
@property (nonatomic,retain) UILongPressGestureRecognizer *longPressGesture;//长按手势
@property (nonatomic, assign) BOOL isLocation;//是否定位到某个地点
@property (nonatomic, strong) NSArray *pathPolylines;
@end

@implementation VENDORViewController
//- (void)viewDidAppear:(BOOL)animated {
//    [MAMapServices sharedServices].apiKey = @"75ab20b443de367fc2c34a0b059f59e9";
//    _mapview = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
//    _mapview.delegate = self;
//    
//    [self.view addSubview:_mapview];
- (UIButton *)pu {
    if (!_pu) {
        self.pu = [[UIButton alloc] initWithFrame:CGRectMake(50, 70, 50, 50)];
        _pu.backgroundColor = [UIColor redColor];
        [_pu setTitle:@"普通收索" forState:UIControlStateNormal];
        [_pu addTarget:self action:@selector(handlepu:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _pu;
}

- (UIButton *)poi {
    if (!_poi) {
        self.poi = [[UIButton alloc] initWithFrame:CGRectMake(120, 70, 50, 50)];
        _poi.backgroundColor = [UIColor redColor];
        [_poi setTitle:@"POI" forState:UIControlStateNormal];
        [_poi addTarget:self action:@selector(handlePOI:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _poi;
}


- (UIButton *)geocode {
    if (!_geocode) {
        self.geocode = [[UIButton alloc] initWithFrame:CGRectMake(180, 70, 50, 50)];
        _geocode.backgroundColor = [UIColor redColor];
        [_geocode setTitle:@"geoCoder" forState:UIControlStateNormal];
        [_geocode addTarget:self action:@selector(handlepgeocoder:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _geocode;
}

- (UIButton *)road {
    if (!_road) {
        self.road = [[UIButton alloc] initWithFrame:CGRectMake(250, 70, 50, 50)];
        _road.backgroundColor = [UIColor redColor];
        [_road setTitle:@"画路线" forState:UIControlStateNormal];
        [_road addTarget:self action:@selector(handleroad:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _road;
}

- (void)handlePOI:(UIButton *)sender {
    FortjViewController *forth = [[FortjViewController alloc]init];
    forth.isSelected = @"2";
    forth.currentCity = self.currentCity;
    forth.currentLocation = self.currentLocation;
    a = 2;
    forth.moveBlock = ^(AMapPOI *poi)
    {
        [_mapview setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude) animated:YES];
        self.currentPOI = poi;
        //添加大头针
        [self addAnnotation];
    };
    [self.navigationController pushViewController:forth animated:YES];
}


- (void)handlepu:(UIButton *)sender {
    FortjViewController *forth = [[FortjViewController alloc]init];
    forth.isSelected = @"1";
    forth.currentCity = self.currentCity;
    forth.currentLocation = self.currentLocation;
    a = 1;
    forth.moveBlock = ^(AMapPOI *poi)
    {
        [_mapview setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude) animated:YES];
        self.currentPOI = poi;
        //添加大头针
        [self addAnnotation];
    };
    [self.navigationController pushViewController:forth animated:YES];

    
    
}


- (void)handlepgeocoder:(UIButton *)sender {
    FortjViewController *forth = [[FortjViewController alloc]init];
    forth.isSelected = @"1";
    forth.isName = @"5";
    forth.currentCity = self.currentCity;
    forth.currentLocation = self.currentLocation;
    a = 1;
    forth.geocodeSearch = ^(NSString *name)
    {
        [self searchGeocodeWithKey:name];
    };
    [self.navigationController pushViewController:forth animated:YES];
    
    
    
}


- (void)handleroad:(UIButton *)sender {
    //构造AMapDrivingRouteSearchRequest对象，设置驾车路径规划请求参数
    AMapWalkingRouteSearchRequest *request = [[AMapWalkingRouteSearchRequest alloc] init];
    //设置起点，我选择了当前位置，mapView有这个属性
    request.origin = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
    //设置终点，可以选择手点
    request.destination = [AMapGeoPoint locationWithLatitude:_destinationPoint.coordinate.latitude longitude:_destinationPoint.coordinate.longitude];
    
    //    request.strategy = 2;//距离优先
    //    request.requireExtension = YES;
    
    //发起路径搜索，发起后会执行代理方法
    //这里使用的是步行路径
    [_search AMapWalkingRouteSearch: request];
 
    
}




/* 地理编码 搜索. */
- (void)searchGeocodeWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = key;
    [_search AMapGeocodeSearch:geo];
}




//添加大头针
- (void)addAnnotation
{
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = _currentLocation.coordinate;
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(_currentPOI.location.latitude, _currentPOI.location.longitude);
    pointAnnotation.title = _currentPOI.name;
    //a=2POI
    if (a == 1) {
        pointAnnotation.subtitle = _currentPOI.district;

    } else if (a  == 2) {
        pointAnnotation.subtitle = _currentPOI.address;
  
    }
    
    
    [_mapview addAnnotation:pointAnnotation];
    [_mapview selectAnnotation:pointAnnotation animated:YES];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
   // [self drawPolyLine];
    [self.view addSubview:self.poi];
    [self.view addSubview:self.pu];
    [self.view addSubview:self.geocode];
        [self.view addSubview:self.road];
    [MAMapServices sharedServices].apiKey = @"75ab20b443de367fc2c34a0b059f59e9";
    _mapview = [[MAMapView alloc] initWithFrame:CGRectMake(0, 150, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)- 150)];
    //这一句话必须写在这个地方
    _mapview.centerCoordinate = _mapview.userLocation.location.coordinate;
    _mapview.delegate = self;
    _mapview.userInteractionEnabled = YES;
//    _mapview.language = MAMapLanguageEn;
//2d地图定位
// _mapview.showsUserLocation = YES; //YES 为打开定位，NO为关闭定位
//  [_mapview setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
    [_mapview setZoomLevel:16 animated:YES];
    //后台定位
//    _mapview.pausesLocationUpdatesAutomatically = NO;
//    _mapview.userTrackingMode = MAUserTrackingModeFollow;
//    _mapview.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    _mapview.userTrackingMode  = 1,
    _mapview.showsUserLocation = YES;

    [self.view addSubview:_mapview];
    
    //添加大头针
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(39.989631, 116.481018);
    pointAnnotation.title = @"方恒国际";
    pointAnnotation.subtitle = @"阜通东大街6号";
    
    [_mapview addAnnotation:pointAnnotation];
    //57ffc919bce99fd2d617d2180295451a  com.cntaiping.life.TPLAppReEinsuIPad
    
    //75ab20b443de367fc2c34a0b059f59e9    dyr.mapDemo
    
    //配置用户Key
   [AMapSearchServices sharedServices].apiKey = @"75ab20b443de367fc2c34a0b059f59e9";
    
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
//    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
//    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
//    request.location = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476];
//    request.keywords = @"方恒";
//    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
//    // POI的类型共分为20种大类别，分别为：
//    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
//    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
//    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
//    request.types = @"餐饮服务|生活服务";
//    request.sortrule = 0;
//    request.requireExtension = YES;
//    
//    //发起周边搜索
//    [_search AMapPOIAroundSearch: request];
//    
//
    
    _mapview.customizeUserLocationAccuracyCircleRepresentation = YES;

    self.pathPolylines = [[NSArray alloc] init];
    [self addGesture];

   

}






//大头针
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]] ||[annotation isKindOfClass:[GeocodeAnnotation class]] || [annotation isKindOfClass:[ReGeocodeAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}
////2d地图定位
//- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    MAAnnotationView *view = views[0];
//    
//    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
//    if ([view.annotation isKindOfClass:[MAUserLocation class]])
//    {
//        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
//        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
//        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
//        pre.image = [UIImage imageNamed:@"location.png"];
//        pre.lineWidth = 3;
//        pre.lineDashPattern = @[@6, @3];
//        
//        [_mapview updateUserLocationRepresentation:pre];
//        
//        view.calloutOffset = CGPointMake(0, 0);
//    } 
//}

//当位置更新时，会进定位回调，通过回调函数，能获取到定位点的经纬度坐标，示例代码如下：
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if (self.isLocation) {
        return;
    }
    
    
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        self.currentLocation = userLocation;
        
        [_mapview setRegion:MACoordinateRegionMake(self.currentLocation.coordinate, MACoordinateSpanMake(0.005,0.005)) animated:YES];
    //定位某个地点
    [self addAnimationByLoaction];
    self.isLocation = YES;
    

    
}

/* 清除annotation. */
- (void)clear
{
    [_mapview removeAnnotations:_mapview.annotations];
}
- (void)addAnimationByLoaction{
    if (self.currentLocation) {
        //先清除原来地图中的大头针
        [self clear];
    //构造AMapReGeocodeSearchRequest对象
        AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc] init];
        //        request.searchType = AMapSearchType_ReGeocode;
        request.requireExtension = YES;
        AMapGeoPoint * point = [AMapGeoPoint locationWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
        request.location = point;
        [_search AMapReGoecodeSearch:request];
    
    request.radius = 10000;
    request.requireExtension = YES;
    
    //发起逆地理编码
    [_search  AMapReGoecodeSearch: request];
    }
}

//=================================定位显示信息回调================================
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    
}



////实现逆地理编码的回调函数
//- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
//{
//    
//    if(response.regeocode != nil)
//    {
//        //通过AMapReGeocodeSearchResponse对象处理搜索结果
//        NSString *result = [NSString stringWithFormat:@"ReGeocode: %@", response.regeocode];
//        NSLog(@"ReGeo: %@", result);
////        _currentCity = response.regeocode.addressComponent.province;
//        _currentCity = response.regeocode.formattedAddress;
//
//        
//        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
////        pointAnnotation.coordinate = CLLocationCoordinate2DMake(39.989631, 116.481018);
//        pointAnnotation.title = response.regeocode.formattedAddress;
//        pointAnnotation.subtitle = response.regeocode.addressComponent.township;
//        
//        [_mapview addAnnotation:pointAnnotation];
//        
//        
//        NSLog(@"city  %@",_currentCity);
//    }
//}



- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    if (response.regeocode != nil)
    {
        
               _currentCity = response.regeocode.addressComponent.province;
                _currentCity = response.regeocode.formattedAddress;

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate
                                                                                         reGeocode:response.regeocode];
        [_mapview setCenterCoordinate:coordinate];
        [_mapview addAnnotation:reGeocodeAnnotation];
        [_mapview selectAnnotation:reGeocodeAnnotation animated:YES];
    }
    
}



#pragma mark----------------------拖动大头针更新位置信息------------------
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState
{
    AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
    request.requireExtension = YES;
    //        request.searchType = AMapSearchType_ReGeocode;
    request.location = [AMapGeoPoint locationWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
    [_search AMapReGoecodeSearch:request];
    
}





//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %d",response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@", response.suggestion];
    NSString *strPoi = @"";
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
    NSLog(@"Place: %@", result);
}





- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois
{
    if (pois.count!=0) {
    AMapAOI*touchPois=pois[0];
        self.currentLocation = [[CLLocation alloc]initWithLatitude:touchPois.location.latitude  longitude:touchPois.location.longitude];
        [_mapview setRegion:MACoordinateRegionMake(self.currentLocation.coordinate, MACoordinateSpanMake(0.005,0.005)) animated:YES];
        [self addAnimationByLoaction];
        
        
        
//        NSLog(@"%f===%f",touchPois.coordinate.latitude,touchPois.coordinate.longitude);
    }
}










//添加手势
- (void)addGesture
{
    //    _annotations = [NSMutableArray array];
    //    _pois = nil;
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _longPressGesture.delegate = self;
    [_mapview addGestureRecognizer:_longPressGesture];
}

//长按手势相应
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        CGPoint p = [gesture locationInView:_mapview];
        NSLog(@"press on (%f, %f)", p.x, p.y);
    }
    CLLocationCoordinate2D coordinate = [_mapview convertPoint:[gesture locationInView:_mapview] toCoordinateFromView:_mapview];
    
    // 添加标注
    if (_destinationPoint != nil) {
        // 清理
        [_mapview removeAnnotation:_destinationPoint];
        _destinationPoint = nil;
    }
    _destinationPoint = [[MAPointAnnotation alloc] init];
    _destinationPoint.coordinate = coordinate;
    _destinationPoint.title = @"目标点";
    _destinationPoint.subtitle = @"我是目的地";
    [_mapview addAnnotation:_destinationPoint];
    [_mapview selectAnnotation:_destinationPoint animated:YES];

    //添加大头针
}




//实现路径搜索的回调函数
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if(response.route == nil)
    {
        return;
    }
    
    //通过AMapNavigationSearchResponse对象处理搜索结果
    NSString *route = [NSString stringWithFormat:@"Navi: %@", response.route];
    
    AMapPath *path = response.route.paths[0]; //选择一条路径
    AMapStep *step = path.steps[0]; //这个路径上的导航路段数组
    NSLog(@"%@",step.polyline);   //此路段坐标点字符串
    
    if (response.count > 0)
    {
        //移除地图原本的遮盖
        [_mapview removeOverlays:self.pathPolylines];
        self.pathPolylines = nil;
        
        // 只显⽰示第⼀条 规划的路径
        self.pathPolylines = [CommonUtility polylinesForPath:response.route.paths[0]];
        NSLog(@"%@",response.route.paths[0]);
        //添加新的遮盖，然后会触发代理方法进行绘制
        [_mapview addOverlays:self.pathPolylines];
    }
}

//
//////绘制遮盖时执行的代理方法
//- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
//{
//    /* 自定义定位精度对应的MACircleView. */
//    
//    //画路线
//    if ([overlay isKindOfClass:[MAPolyline class]])
//    {
//        //初始化一个路线类型的view
//        MAPolylineRenderer *polygonView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
//        //设置线宽颜色等
//        polygonView.lineWidth = 8.f;
//        polygonView.strokeColor = [UIColor colorWithRed:0.015 green:0.658 blue:0.986 alpha:1.000];
//        polygonView.fillColor = [UIColor colorWithRed:0.940 green:0.771 blue:0.143 alpha:0.800];
//        polygonView.lineJoinType = kMALineJoinRound;//连接类型
//        //返回view，就进行了添加
//        return polygonView;
//    }
//    return nil;
//    
//}





- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)drawPolyLine

{
    
    //初始化点
    
    NSArray *latitudePoints =[NSArray arrayWithObjects:
                              
                              @"23.172223",
                              
                              @"23.163385",
                              
                              @"23.155411",
                              
                              @"23.148765",
                              
                              @"23.136935", nil];
    
    NSArray *longitudePoints = [NSArray arrayWithObjects:
                                @"113.348665",
                                
                                @"113.366056",
                                
                                @"113.366128",
                                
                                @"113.362391",
                                
                                @"113.356785", nil];
    
    
    
    // 创建数组
    
    CLLocationCoordinate2D polyLineCoords[5];
    
    
    
    for (int i=0; i<5; i++) {
        
        polyLineCoords[i].latitude = [latitudePoints[i] floatValue];
        
        polyLineCoords[i].longitude = [longitudePoints[i] floatValue];

        
    }
    
    // 创建折线对象
    
    MAPolyline *polyLine = [MAPolyline polylineWithCoordinates:polyLineCoords count:5];
    
    
    
    // 在地图上显示折线
    
    [_mapview addOverlay:polyLine];
    
}



-(MAOverlayView * )mapView:(MAMapView *)mapView viewForOverlay:(id)overlay

{
    
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        
        
        
        MAPolylineView *polyLineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polyLineView.lineWidth = 2; //折线宽度
        
        polyLineView.strokeColor = [UIColor blueColor]; //折线颜色
        
        polyLineView.lineJoin = kCALineJoinRound; //折线连接类型

        return polyLineView;
        
    }
    
    return nil;
    
}



#pragma mark - AMapSearchDelegate

/* 反地理编码回调.*/
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if (response.geocodes.count == 0)
    {
        return;
    }
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        GeocodeAnnotation *geocodeAnnotation = [[GeocodeAnnotation alloc] initWithGeocode:obj];
        
        [annotations addObject:geocodeAnnotation];
    }];
    
    if (annotations.count == 1)
    {
        [_mapview setCenterCoordinate:[annotations[0] coordinate] animated:YES];
    }
    else
    {
        [_mapview setVisibleMapRect:[CommonUtility minMapRectForAnnotations:annotations]
                               animated:YES];
    }
    
    [_mapview addAnnotations:annotations];
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
