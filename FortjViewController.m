//
//  FortjViewController.m
//  mapDemo
//
//  Created by CMH-mac on 16/6/4.
//  Copyright © 2016年 xingzhi. All rights reserved.
//

#import "FortjViewController.h"

@interface FortjViewController ()<UISearchBarDelegate,UISearchResultsUpdating,UITableViewDataSource,UITableViewDelegate,AMapSearchDelegate,UITextFieldDelegate, UISearchControllerDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic,retain) NSMutableArray *dataList;
@property (strong,nonatomic) NSMutableArray  *searchList;

@property (nonatomic,retain) AMapSearchAPI *search;

@end

@implementation FortjViewController



- (UITableView *)tableView {
    if (!_tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
    }
    return _tableView;
}

- (NSMutableArray *)searchList
{
    if (!_searchList) {
        _searchList = [NSMutableArray array];
    }
    return _searchList;
}
- (NSMutableArray *)dataList
{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    _searchController.delegate = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    [_searchController.searchBar becomeFirstResponder];
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.searchBar.frame = CGRectMake(20, 60, 270, 44.0);
//    [self.view addSubview:self.searchController.searchBar];
    self.navigationItem.titleView = self.searchController.searchBar;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
    [AMapSearchServices sharedServices].apiKey = @"75ab20b443de367fc2c34a0b059f59e9";
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    //添加到顶部
    
    
    //57ffc919bce99fd2d617d2180295451a  com.cntaiping.life.TPLAppReEinsuIPad
    
    //75ab20b443de367fc2c34a0b059f59e9    dyr.mapDemo

}






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //设置区域的行数(重点),这个就是使用委托之后需要需要判断是一下是否是需要使用Search之后的视图:
    if ([self.isSelected isEqualToString:@"1"]) {
        return [self.searchList count];
    }else{
        return [self.dataList count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *flag=@"CELL";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:flag];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:flag];
    }
    //如果搜索框激活
    if ([self.isSelected isEqualToString:@"1"]) {
        AMapPOI *poi = _searchList[indexPath.row];
        [cell.textLabel setText:poi.name];
    }
    else{
        AMapPOI *poi = _dataList[indexPath.row];
        [cell.textLabel setText:poi.name];
    }
    return cell;
}


//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [self.searchController.searchBar resignFirstResponder];
    
    
    AMapPOI *poi = [[AMapPOI alloc]init];
    //如果搜索框激活
    if ([self.isSelected isEqualToString:@"1"]) {
        poi = _searchList[indexPath.row];
        if ([self.isName isEqualToString:@"5"]) {
            self.geocodeSearch(poi.name);

        } else {
            self.moveBlock(poi);

        }
        
    }
    else if ([self.isSelected isEqualToString:@"2"]){
        poi = _dataList[indexPath.row];
        self.moveBlock(poi);
    }
    
    NSLog(@"%@,%f,%f",poi.name,poi.location.latitude,poi.location.longitude);
    
    
//    self.moveBlock(poi);
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


#pragma mark -- 代理方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    NSLog(@"搜索Begin");
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    NSLog(@"搜索End");
    return YES;
}

//搜索框激活时，使用提示搜索
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if ([self.isSelected isEqualToString:@"1"]) {
        //发起输入提示搜索
        AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
        tipsRequest.keywords = _searchController.searchBar.text;
        tipsRequest.city = _currentCity;
        
        NSLog(@"^^^^^^^^^%@", _currentCity);
        [_search AMapInputTipsSearch: tipsRequest];
    } else {
        AMapPOIAroundSearchRequest *tip = [[AMapPOIAroundSearchRequest alloc] init];
        tip.location = [AMapGeoPoint locationWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];

        tip.keywords = _searchController.searchBar.text;
        tip.radius = 5000;
        [_search AMapPOIAroundSearch:tip];
    }
 
    
}




//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response.pois.count == 0)
    {
        return;
    }
    
    //通过 AMapPOISearchResponse 对象处理搜索结果
    
    [self.dataList removeAllObjects];
    for (AMapPOI *p in response.pois) {
        NSLog(@"%@",[NSString stringWithFormat:@"%@\nPOI: $$$$$$$%@,^^^^^^^^^%@", p.description,p.name,p.address]);
        
        //搜索结果存在数组
        [self.dataList addObject:p];
    }
    
    _isSelected = @"2";
    [self.tableView reloadData];
    
}

//实现输入提示的回调函数
-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response
{
    if(response.tips.count == 0)
    {
        return;
    }
    
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    
    
    //先清空数组
    [self.searchList removeAllObjects];
    for (AMapTip *p in response.tips) {
        NSLog(@"^6666666%@**8888%@", p.name, p.district);
        
        //把搜索结果存在数组
        
        [self.searchList addObject:p];
    }
    
    _isSelected = @"1";
    //刷新表格
    [self.tableView reloadData];
}




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
