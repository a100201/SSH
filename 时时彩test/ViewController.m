//
//  ViewController.m
//  时时彩test
//
//  Created by fly on 2018/4/9.
//  Copyright © 2018年 fly111. All rights reserved.
//

// 数据资源 https://cqssc.17500.cn/
/**
 倍数按照：1、1、2、4、8、16、32、64、128、256、512、1024
 
 120期的本金为￥64000
 110期的本金为￥32000
 100期的本金为￥16000
 90期的本金为 ￥8000
 80期的本金为 ￥4000
 70  ￥2000
 60  ￥1000
 50  ￥500
 40  ￥250
 30  ￥125
 20  ￥62.5
 10  ￥31.25
 
 一天分12个轮次(减去的成本按本轮最大成本算):
 第12轮的奖金为 97.8*1024 = 100147.2  减去成本64000  =  ￥36147.2
 第11轮的奖金为 97.8*512 = 50073.6  减去成本32000  =    ￥18073.6
 10  ￥9036.8                                        ￥9036.8
 9   ￥4518.4                                        ￥4518.4
 8   ￥2259.2                                        ￥2259.2
 7   ￥1129.6                                        ￥1129.6
 6   ￥564.8                                         ￥564.8
 5   ￥282.4                                         ￥282.4
 4   ￥141.2                                         ￥141.2
 3   ￥70.6                                          ￥70.6
 2   ￥35.3                                          ￥35.3
 1   ￥60.3                                          ￥66.55
 
 */


#import "ViewController.h"
#import <math.h>

typedef NS_ENUM(NSUInteger, BingoStyle) { // 中奖方式
    bingoStyleBig,         // 大
    bingoStyleSmall,      // 小
    bingoStyleMaxReturnFive,  // 获取利润最大的5个数组合
    bingoStyleSingle,     // 单
    bingoStyleDouble,     // 双
    BingoStyleStaticFive, // 验证固定的5个数
};

typedef NS_ENUM(NSUInteger, TestMode) { // 测试模式
    testReturnMode = 0, // 测试利润回报模式
    testRepeatMode,    // 测试出现次数模式
};

@interface ViewController (){
    double _benjing ;
    double _jiangjing;
    NSInteger _stopCount;  // 中奖的期数
    
    
    int _boomNum;  // 没有中奖的天数
    
    int _beishu; // 倍数
    
    
    NSMutableArray * _numArr_0;
    NSMutableArray * _numArr_1;
    NSMutableArray * _numArr_2;
    NSMutableArray * _numArr_3;
    NSMutableArray * _numArr_4;
    NSMutableArray * _numsArr;  // 期数数组
    
    NSInteger allNum;  // 总期数
    NSMutableArray * _boomArr;
    NSInteger _day; // 第几天
    
    // 数据校正
    NSInteger  _insertNum; // 插入空数据的条数
    
    
    
    // 获得利润最高的组合
    NSInteger _combineNum; // 组合的种类数目
    NSMutableArray * _combineArr; //组合的种类
    NSMutableArray * _currentCombine; // 当前的组合
    
    NSMutableArray * _returnArr; // 利润数组
    NSMutableArray * _returnDataArr; // 每种组合的营收数据数组
    
    
    BingoStyle _bingoStype;
    NSArray * _staticFiveArr;  // 要检测的5个数字组合
    NSInteger _dataDays; // 数据的天数（包含插入数据）
    
    
    NSInteger _periods; // 预购几轮
    NSInteger _startPeriod; //  0~11 ,表示从第几轮(1-12轮)开始投
    
    
    
    NSMutableArray * _noBoomArr; // 没有boom
    NSMutableArray * _winArr;    // 有盈利
    
    
    NSMutableArray * _repeatNumArr; // 每天出现的次数数组
    NSMutableArray * _repeatRateArr; // 平均每天出现的几率数组
    NSMutableArray * _onceArr;   // 出现过一次的数组（0<0<1）
    
    
    TestMode _testMode; // 测试模式
    
    
    // 周期的划分、投资的方法;
    NSMutableArray * _combineShowCountArr; // 252中组合出现的次数数组
    
    NSMutableArray * _showCountInPhaseArr; // 所有组合出现的次数前3的阶段合集
    
    NSInteger _topScaleNum; // 3，占比前3
    NSMutableArray * _showPhaseScaleArr; // 占比前topScaleNum的比例的和数组
    
    NSMutableDictionary * _combineShowCountInPhaseDataDic; // key为组合，value为12期的出现占比数组
    
    
    
    NSInteger _fromPeriod;  // 从多少期开始循环
    NSInteger _cyclePeriods; // 以多少期为周期
    NSInteger _cycleNum;    // 第几个周期
    NSInteger _PhaseNum;     // 多少轮
    NSInteger _periodInPhase; // 每轮多少期（=_cyclePeriods/_PhaseNum）
    NSMutableDictionary * _returnKeyDic; // 以利润为key的数据字典
    NSMutableArray * _returnEverythingArr;  // 所有的可能的利润数组
    
    NSMutableDictionary * _returnRateDic; // 以利润收益比为key的数据字典
    NSMutableArray * _returnRateEverythingArr;  // 所有的可能的利润数组
    
    
    NSMutableArray * _firstShowInPhaseRateArr;  // 第一次出现在哪个阶段的概率数组
    float _firstShowMaxNumInStaticPeriod;      // 第一次出现的次数在几个特定阶段内
    NSString *_staticPeriodStr;                  // 特定连续阶段 1~2~3
    float _firstShowAllNum;                   // 第一次出现总次数（只记周期内的第一次出现）
    
    NSMutableDictionary * _firstShowNumMaxDic;   // 以组合阶段出现最多次数为key的字典
    NSMutableArray * _firstShowNumMaxArr;        // 组合阶段出现最多次数数组
    
    
    
}




@end

@implementation ViewController
// 以纯随机来测试
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
#pragma mark 数据处理
    _boomArr = [NSMutableArray array];
    _noBoomArr = [NSMutableArray array];
    
    // 导入数据(数据2018-0215~20180221 缺失)
    // 2018-0117 ~ 2018-0424
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];
    NSString *dataFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *dataarr = [dataFile componentsSeparatedByString:@"\n"];
    _numArr_0 = [NSMutableArray array];
    _numArr_1 = [NSMutableArray array];
    _numArr_2 = [NSMutableArray array];
    _numArr_3 = [NSMutableArray array];
    _numArr_4 = [NSMutableArray array];
    _numsArr = [NSMutableArray array];
    
    for (NSString * str in dataarr) {
        NSArray * strArr = [str componentsSeparatedByString:@" "];
        if (strArr.count > 5) {
            [_numArr_0 addObject:strArr[1]];
            [_numArr_1 addObject:strArr[2]];
            [_numArr_2 addObject:strArr[3]];
            [_numArr_3 addObject:strArr[4]];
            [_numArr_4 addObject:strArr[5]];
            [_numsArr addObject:strArr[0]];
        }else{
            NSLog(@"空-%@",str);
        }
        
    }
    NSLog(@"有效数据%ld条",_numsArr.count);
    // 校正数据（缺失期数由空数据补充）
    
    BOOL runloop = YES;
    while (runloop) {
        NSInteger i = 0;
        NSMutableArray * tempArr = [NSMutableArray arrayWithArray:_numsArr];
        NSInteger insertNum = 0; // 每次内层循环的插入数，开始前置0
        for (NSString * valueStr in tempArr) {
            if (i < tempArr.count-1) {
                NSString * nextValueStr = tempArr[i+1];
                NSInteger value = [valueStr integerValue];
                NSInteger nextValue = [nextValueStr integerValue];
                NSInteger trueNext = 0;
                // 人工排查月底到1号的数据没有问题
                if ([valueStr hasSuffix:@"120"]) {
                    if ([valueStr isEqualToString:@"20180131120"] || [valueStr isEqualToString:@"20180228120"] || [valueStr isEqualToString:@"20180331120"] || [valueStr isEqualToString:@"20180430120"] || [valueStr isEqualToString:@"20180531120"]) {
                        i++;
                        continue;
                    }else{
                        trueNext = value/1000*1000+1001;
                    }
                }else{
                    trueNext = value+1;
                }
                
                while (trueNext < nextValue) {
                    insertNum++;
                    _insertNum++;
                    [_numsArr insertObject:[NSString stringWithFormat:@"%ld",trueNext] atIndex:i+insertNum];
                    [_numArr_0 insertObject:@"" atIndex:i+insertNum];
                    [_numArr_1 insertObject:@"" atIndex:i+insertNum];
                    [_numArr_2 insertObject:@"" atIndex:i+insertNum];
                    [_numArr_3 insertObject:@"" atIndex:i+insertNum];
                    [_numArr_4 insertObject:@"" atIndex:i+insertNum];
                    
                    NSString * trueNextStr = [NSString stringWithFormat:@"%ld",trueNext];
                    if ([trueNextStr hasSuffix:@"120"]) {
                        trueNext = trueNext/1000*1000+1001;
                    }else{
                        trueNext++;
                    }
                }
                if(insertNum > 0){ // 没插入一次,就跳出内层循环，重新赋值tempArr遍历
                    break;
                }
            }
            i++;
            if(i == _numsArr.count){ // 知道最后一个数据没有问题，跳出外层循环
                runloop = NO;
            }
        }
    }
    
    NSLog(@"插入数据-%ld条",_insertNum);
    
    // 验证数据
    BOOL rightData = YES;
    for(NSInteger i = 0;i<_numsArr.count-1;i++){
        NSString * numStr = _numsArr[i];
        NSInteger num = [numStr integerValue];
        NSInteger nextNum = [_numsArr[i+1]integerValue];
        if ([numStr isEqualToString:@"20180131120"] || [numStr isEqualToString:@"20180228120"] || [numStr isEqualToString:@"20180331120"] || [numStr isEqualToString:@"20180430120"] || [numStr isEqualToString:@"20180531120"]) {
            
        }else{
            if([numStr hasSuffix:@"120"]){
                if(nextNum != num/1000*1000+1001){
                    rightData = NO;
                }
            }else{
                if(nextNum != num+1){
                    rightData = NO;
                }
            }
        }
    }
    if(rightData){
        NSLog(@"数据校正准确");
    }else{
        NSLog(@"数据校正失败");
        return;
    }
    
    // 1月~5月数据筛选
    //    [self limitDataWithStartStr:@"20180117001" endStr:@"20180201001"];
    //    [self limitDataWithStartStr:@"20180201001" endStr:@"20180301001"];
    //    [self limitDataWithStartStr:@"20180301001" endStr:@"20180401001"];
    //    [self limitDataWithStartStr:@"20180401001" endStr:@"20180501001"];
    //      [self limitDataWithStartStr:@"20180501001" endStr:@"20180529120"];
    
    // 今天的数据
    //          [self limitDataWithStartStr:@"20180522001" endStr:@"20180522023"];
    
    // 验证多少天
    NSInteger daysNum = 0;
    for (NSString * str in _numsArr) {
        if ([str hasSuffix:@"120"]) {
            daysNum++;
        }
    }
    _dataDays = daysNum;
    NSLog(@"%ld天数据(以有第120期为标准，包含插入空数据)",daysNum);
    
    
    
#pragma mark 操作段
    _startPeriod = 0; // 4表示从第5轮开始买，买80期
    [self runEverythingAll];
    // 测试今天是否已中奖
    //    [self playTodayWithStaticFiveArr:@[@7,@5,@4,@2,@1]];
    
    // 测算本金
//    [self playOneDay];
    
    
    // 测试每天的出现平均次数（3.19~4.13）
    _testMode = testRepeatMode;
//    [self playForMaxRepeat];
#warning  获得具体数字组合的平均次数，需先运行playForMaxRepeat方法
//    [self getRepeatRateWithCombine:@[@7,@5,@4,@2,@1]];
    
    // 测试数字组合出现的总次数 （403~520）
    _topScaleNum = 9;
    [self combineShowCount];
//    [self getScaleWithCombine:@"75421" andTop:_topScaleNum];
#warning  获得具体数字组合的总次数，需先运行combineShowCount方法
//    [self getShowCountWithCombine:@[@7,@5,@4,@2,@1]];
    
    // 测试奖金
    _testMode = testReturnMode;
//    [self playFor5];
//    [self lookNoBoomAndWin];
//    [self playBig];
//    [self playSmall];
//    [self playSingle];
//    [self playDouble];
//    [self playStaticFiveWithArr:@[@7,@5,@4,@2,@1]];
    
//        [self playStaticFiveWithArr:@[@8,@7,@4,@3,@2]];

    
    
    //        [self playStaticFiveWithArr:@[@8,@5,@4,@3,@1]];
    //        [self playStaticFiveWithArr:@[@6,@5,@4,@2,@1]];
    //        [self playStaticFiveWithArr:@[@9,@8,@3,@1,@0]];// 3
    //        [self playStaticFiveWithArr:@[@8,@7,@5,@4,@3]];
    //        [self playStaticFiveWithArr:@[@8,@7,@5,@1,@0]];
    //            [self playStaticFiveWithArr:@[@8,@6,@5,@4,@1]];//8
    //            [self playStaticFiveWithArr:@[@9,@6,@4,@3,@2]];
    //            [self playStaticFiveWithArr:@[@9,@8,@5,@1,@0]];
    //            [self playStaticFiveWithArr:@[@7,@4,@3,@2,@1]];// 7
    //            [self playStaticFiveWithArr:@[@7,@3,@2,@1,@0]];
    
    //  75421;83210;98310;97210;85421;87542;74321;86541;97650;87652;
    // 75421;83210;98310;97210;85421;87542;74321;97650;86541;87652
    
#pragma mark 数据总结
    /*
     利润前10数组、没有💥的组合个数、盈利的组合个数、前10的利润
     
     5: 87521;86530;87653;94321;85421;76542;95431;95432;87641;96530;    126     147
     ￥17380.6;￥17246.7;￥15965.3;￥14974.0;￥14235.7;￥13691.2;￥13007.7;￥12981.0;￥12686.3;￥11496.1;
     
     4: 74321;85431;98310;86521;87543;87510;86541;96432;84321;73210;     126     151
     ￥19589.3;￥17484.4;￥15963.1;￥15605.3;￥14841.3;￥14262.8;￥13536.0;￥13075.2;￥11526.3;￥11129.9;
     
     3: 83210;75421;97210;85421;97642;96543;97640;97542;98310;86530;    126     147
     ￥21387.6;￥18438.4;￥15769.1;￥15255.2;￥14103.7;￥13989.3;￥13342.5;￥12357.9;￥12324.3;￥11739.8;
     
     2: 87652;95321;84310;98321;76410;87654;96530;97630;87542;65421;    172     182
     ￥13232.2;￥12876.6;￥10999.1;￥10942.4;￥10908.7;￥9990.0;￥9608.1;￥9536.6;￥9404.9;￥9257.1;
     
     1: 65310;96210;97540;98753;97210;87642;95430;87652;64321;86321;    176     180
     ￥18494.5;￥12381.3;￥11715.0;￥10267.2;￥9996.1;￥9636.4;￥9524.6;￥9299.4;￥9234.0;￥9176.1;
     
     总：75421;83210;85421;97210;87542;98310;86541;85431;65421;98542;     16   133
     ￥45117.6;￥41388.8;￥38028.8;￥33456.9;￥32274.7;￥31306.0;￥30201.1;￥29140.8;￥24483.0;￥24174.9;
     */
    
    // 测算重合度
    NSString *combineStr = @"87521;86530;87653;94321;85421;76542;95431;95432;87641;96530;74321;85431;98310;86521;87543;87510;86541;96432;84321;73210;83210;75421;97210;85421;97642;96543;97640;97542;98310;86530;87652;95321;84310;98321;76410;87654;96530;97630;87542;65421;65310;96210;97540;98753;97210;87642;95430;87652;64321;86321;75421;83210;85421;97210;87542;98310;86541;85431;65421;98542;";
    NSArray * arr = [combineStr componentsSeparatedByString:@";"];
    NSMutableArray * numArr = [NSMutableArray array];
    NSMutableArray * countArr = [NSMutableArray array];
    for (NSString *combine in arr) {
        NSInteger count = 0;
        for (NSString * combine2 in arr) {
            if ([combine isEqualToString:combine2]) {
                count++;
            }
        }
        if (count > 1) {
            [numArr addObject:combine];
            [countArr addObject:@(count)];
        }
    }
    
    // 周期的划分、投资的方法;
    // 参数：起始倍数、
    
    
}

// 数据截取
- (void)limitDataWithStartStr:(NSString *)startStr endStr:(NSString *)endStr{
    NSInteger start = [_numsArr indexOfObject:startStr];
    NSInteger end = [_numsArr indexOfObject:endStr];
    if (end == _numsArr.count-1) {
        end++;
    }
    _numsArr = (NSMutableArray *)[_numsArr subarrayWithRange:NSMakeRange(start, end-start)];
    _numArr_0 = (NSMutableArray *)[_numArr_0 subarrayWithRange:NSMakeRange(start, end-start)];
    _numArr_1 = (NSMutableArray *)[_numArr_1 subarrayWithRange:NSMakeRange(start, end-start)];
    _numArr_2 = (NSMutableArray *)[_numArr_2 subarrayWithRange:NSMakeRange(start, end-start)];
    _numArr_3 = (NSMutableArray *)[_numArr_3 subarrayWithRange:NSMakeRange(start, end-start)];
    _numArr_4 = (NSMutableArray *)[_numArr_4 subarrayWithRange:NSMakeRange(start, end-start)];
    
    NSLog(@"%@-%@",_numsArr.firstObject,_numsArr.lastObject);
}


// 全局数据还原
-(void)initData{
    // 还原
    _jiangjing = 0;
    _benjing = 0;
    allNum = 0;
    _boomArr = [NSMutableArray array];
    _day = 0;
    _cycleNum = 0;
    _stopCount = 0;
    _boomNum = 0;
    _repeatNumArr = [NSMutableArray array];
    
    _firstShowInPhaseRateArr = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0]];

    _firstShowMaxNumInStaticPeriod = 0;
    _firstShowAllNum = 0;
}

// 9 8 7 6 5 484 4,3,4
// 98760
// 组合出现的次数
-(void)combineShowCount{
    _combineShowCountArr = [NSMutableArray array];
    _showCountInPhaseArr = [NSMutableArray array];
    _showPhaseScaleArr = [NSMutableArray array];
    _combineShowCountInPhaseDataDic = [NSMutableDictionary dictionary];
    [self initCombineArr];

    _firstShowNumMaxDic = [NSMutableDictionary dictionary];
    _firstShowNumMaxArr = [NSMutableArray array];
    _cyclePeriods = 120;
    _PhaseNum = 12;
    
    for (NSMutableArray *arr in _combineArr) {
        NSInteger showCount = 0;
        NSInteger showCountPhase_1 = 0;
        NSInteger showCountPhase_2 = 0;
        NSInteger showCountPhase_3 = 0;
        NSInteger showCountPhase_4 = 0;
        NSInteger showCountPhase_5 = 0;
        NSInteger showCountPhase_6 = 0;
        NSInteger showCountPhase_7 = 0;
        NSInteger showCountPhase_8 = 0;
        NSInteger showCountPhase_9 = 0;
        NSInteger showCountPhase_10 = 0;
        NSInteger showCountPhase_11 = 0;
        NSInteger showCountPhase_12 = 0;

        // 还原
        _currentCombine = arr;
        

        _firstShowMaxNumInStaticPeriod = 0;
        _firstShowAllNum = 0;
        
        for (int i = 0; i<_numsArr.count; i++) {
            // 去除空数据影响
            if ([_numArr_0[i] isEqualToString:@""]) {
                continue;
            }
            int num_0 = [_numArr_0[i]intValue];
            int num_1 = [_numArr_1[i]intValue];
            int num_2 = [_numArr_2[i]intValue];
            int num_3 = [_numArr_3[i]intValue];
            int num_4 = [_numArr_4[i]intValue];
            
            if ([_currentCombine containsObject:@(num_0)] && [_currentCombine containsObject:@(num_1)] && [_currentCombine containsObject:@(num_2)] && [_currentCombine containsObject:@(num_3)] && [_currentCombine containsObject:@(num_4)] ) {
                showCount++;
//                NSLog(@"第%d期，%d%d%d%d%d",i,num_0,num_1,num_2,num_3,num_4);
                NSInteger period = (i+1) % 120;
                if (period < 11) {
                    showCountPhase_1++;
                }else if (period < 21){
                    showCountPhase_2++;
                }else if (period < 31){
                    showCountPhase_3++;
                }else if (period < 41){
                    showCountPhase_4++;
                }else if (period < 51){
                    showCountPhase_5++;
                }else if (period < 61){
                    showCountPhase_6++;
                }else if (period < 71){
                    showCountPhase_7++;
                }else if (period < 81){
                    showCountPhase_8++;
                }else if (period < 91){
                    showCountPhase_9++;
                }else if (period < 101){
                    showCountPhase_10++;
                }else if (period < 111){
                    showCountPhase_11++;
                }else {
                    showCountPhase_12++;
                }
            }
        }
        [_combineShowCountArr addObject:@(showCount)];
        NSMutableArray * phaseArr = [NSMutableArray arrayWithObjects:@(showCountPhase_1),@(showCountPhase_2),@(showCountPhase_3),@(showCountPhase_4),@(showCountPhase_5),@(showCountPhase_6),@(showCountPhase_7),@(showCountPhase_8),@(showCountPhase_9),@(showCountPhase_10),@(showCountPhase_11),@(showCountPhase_12), nil];
        NSMutableArray * showcountScaleArr = [NSMutableArray array];
        for (NSNumber * showCountInPhase in phaseArr) {
            [showcountScaleArr addObject:@(showCountInPhase.floatValue/showCount)];
        }
        [_combineShowCountInPhaseDataDic setValue:showcountScaleArr forKey:[self getStrWithCombine:_currentCombine]];
        
        NSArray * orderPhaseArr = [self getOrderArr:phaseArr];
        float topShow = 0;
        //前topShow轮的出现占比
        for (int i = 0; i<_topScaleNum; i++) {
            NSNumber * showCountInPhase = orderPhaseArr[i];
            NSInteger  phase = [phaseArr indexOfObject:showCountInPhase];
            // 组合-第几阶段-总出现数-阶段占比-阶段出现数
            NSString * key = [NSString stringWithFormat:@"%@-阶段%ld-总出现数%ld-占比%.2f-%@",[self getStrWithCombine:_currentCombine],phase,showCount,showCountInPhase.floatValue/showCount,showCountInPhase];
            [_showCountInPhaseArr addObject:key];
            topShow +=showCountInPhase.floatValue;
        }
        [_showPhaseScaleArr addObject:@(topShow/(float)showCount)];
        
        //
        NSString * combineStr = [self getStrWithCombine:_currentCombine];
        _firstShowInPhaseRateArr = [NSMutableArray arrayWithArray:showcountScaleArr];
        [self getMaxContinueNum:3 inArr:_firstShowInPhaseRateArr];
        NSString * showMaxNumKey = [NSString stringWithFormat:@"%.3f-%@-%ld",_firstShowMaxNumInStaticPeriod,combineStr,_fromPeriod];
        [_firstShowNumMaxArr addObject:showMaxNumKey];
        _firstShowNumMaxDic[showMaxNumKey] = [NSString stringWithFormat:@"%@-%.1f-%@-%ld-%ld",showMaxNumKey,(float)_firstShowAllNum,_staticPeriodStr,_cyclePeriods,_PhaseNum];
    }
    
    _firstShowNumMaxArr = [self getOrderArr:_firstShowNumMaxArr];
    for (int i = 0 ; i<50; i++) {
        NSLog(@"%@",_firstShowNumMaxDic[_firstShowNumMaxArr[i]]);
    }
    
    
    // 排序出现次数数组
    NSMutableArray * combineOrderByShowCountArr = [NSMutableArray arrayWithArray:_combineArr];
    for(int i = 0;i < _combineShowCountArr.count-1;i++){
        for (int j = i+1; j<_combineShowCountArr.count; j++) {
            if ([_combineShowCountArr[j]integerValue] > [_combineShowCountArr[i]integerValue]) {
                NSNumber * temep = _combineShowCountArr[j];
                _combineShowCountArr[j] = _combineShowCountArr[i];
                _combineShowCountArr[i] = temep;
                [combineOrderByShowCountArr exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    // 排序分阶段出现次数数组
    NSMutableArray * combineOrderByShowCountInPhaseArr = [NSMutableArray arrayWithArray:_combineArr];
    for(int i = 0;i < _showCountInPhaseArr.count-1;i++){
        for (int j = i+1; j<_showCountInPhaseArr.count; j++) {
            NSString * numA = [_showCountInPhaseArr[i]componentsSeparatedByString:@"-"].lastObject;
            NSString * numB = [_showCountInPhaseArr[j]componentsSeparatedByString:@"-"].lastObject;

            if ([numB integerValue] > [numA integerValue]) {
                NSString * temep = _showCountInPhaseArr[j];
                _showCountInPhaseArr[j] = _showCountInPhaseArr[i];
                _showCountInPhaseArr[i] = temep;
//                [combineOrderByShowCountInPhaseArr exchangeObjectAtIndex:i withObjectAtIndex:j];

            }
        }
    }
    
    // 占比数组排序
//    NSMutableArray * combineOrderByScaleInPhaseArr = [NSMutableArray arrayWithArray:_combineArr];
    _showPhaseScaleArr = [self getOrderArr:_showPhaseScaleArr];
//    for(int i = 0;i < _showPhaseScaleArr.count-1;i++){
//        for (int j = i+1; j<_showPhaseScaleArr.count; j++) {
//            if ([_showPhaseScaleArr[j]integerValue] > [_showPhaseScaleArr[i]integerValue]) {
//                NSNumber * temep = _showPhaseScaleArr[j];
//                _showPhaseScaleArr[j] = _showPhaseScaleArr[i];
//                _showPhaseScaleArr[i] = temep;
//            }
//        }
//    }
    
}

// 获得组合的前几轮的出现占比
-(void)getScaleWithCombine:(NSString *)combine andTop:(NSInteger)top{
    NSMutableArray * scaleArr = _combineShowCountInPhaseDataDic[combine];
    float totalScale = 0.0;
    for (int i = 0; i < top; i++) {
        float scale = [scaleArr[i]floatValue];
        totalScale += scale;
    }

    NSLog(@"组合%@前%ld轮的出现占比为%f",combine,top,totalScale);
}

// 数字组合的总出现次数
-(void)getShowCountWithCombine:(NSArray *)combine{
    NSInteger count = [_combineArr indexOfObject:combine];
    NSLog(@"组合%@总共出现次数为%ld",combine,[_combineShowCountArr[count]integerValue]);
}
// 模拟一天，测算本金
-(void)playOneDay{
    _bingoStype = BingoStyleStaticFive;
    _staticFiveArr = @[@11,@1,@3,@4,@5];
    [self run];
    NSLog(@"12轮的本金为-%lf",_benjing);
}

// 验证今天的部分数据是否已出奖
- (void)playTodayWithStaticFiveArr:(NSArray *)arr{
    _bingoStype = BingoStyleStaticFive;
    _staticFiveArr = arr;
    [self initData];
    [self run];
}

// 没有爆炸、盈利的组合
- (void)lookNoBoomAndWin{
    _winArr = [NSMutableArray array];
    for (NSNumber * returnNum in _returnArr) {
        if (returnNum.integerValue > 0) {
            [_winArr addObject:returnNum];
        }
    }
    NSLog(@"没有爆炸过的数组数量-%ld",_noBoomArr.count);
    NSLog(@"盈利的数组数量-%ld",_winArr.count);
}

// 初始化组合数组
-(void)initCombineArr{
    
    _bingoStype = bingoStyleMaxReturnFive;
    NSMutableArray *a = [NSMutableArray arrayWithObjects:@0,@1,@2,@3,@4,@5,@6,@7,@8,@9, nil];
    NSMutableArray *b = [NSMutableArray arrayWithObjects:@0,@0,@0,@0,@0, nil];
    
    _combineArr = [NSMutableArray array];
    _returnArr = [NSMutableArray array];
    _returnDataArr = [NSMutableArray array];
    
    _repeatRateArr = [NSMutableArray array];
    _onceArr = [NSMutableArray array];
    _combineNum = 0;
    [self OC_combineN:10 M:5 arrA:a arrB:b M:5];
    NSLog(@"总共有%ld种组合",_combineNum);
}


// 10个数中取5个数，找到中奖最高的5个数组合
-(void)playFor5{
    NSLog(@"******************************* %ld天利润最大的10个数 组合 *******************************************",_dataDays);
    [self initCombineArr];
    
    for (NSMutableArray *arr in _combineArr) {
        // 还原
        _currentCombine = arr;
        [self initData];
        //        _beishu = 0;
        
        for (int i = 0; i<_dataDays; i++) {
            [self run];
        }
        
        NSMutableArray *returnData = [NSMutableArray arrayWithObjects:@(_jiangjing),@(_benjing),@(_jiangjing-_benjing),@(_boomNum),_boomArr, nil];
        [_returnDataArr addObject:returnData];
        [_returnArr addObject:@(_jiangjing-_benjing)];
        
#warning 注：2月份停7天
        if (_boomNum < 8) { // 注：2月份停7天
            [_noBoomArr addObject:_currentCombine];
        }
        
    }
    NSInteger maxReturn = 0;
    NSInteger maxReturnCount = 0;
    for (NSNumber * number in _returnArr) {
        if (number.integerValue > maxReturn) {
            maxReturn = number.integerValue;
            maxReturnCount = [_returnArr indexOfObject:number];
        }
    }
    NSArray * maxaDatArr = _returnDataArr[maxReturnCount];
    NSLog(@"组合为%@ \n获得的利润为%ld",_combineArr[maxReturnCount],maxReturn);
    NSLog(@"\n 总奖金为%.1f , \n 总本金为%.1f,",[maxaDatArr[0]floatValue],[maxaDatArr[1]floatValue]);
    //                NSLog(@"盈利：￥%lf",_jiangjing-_benjing);
    NSLog(@"boom: %ld",[maxaDatArr[3]integerValue]);
    NSLog(@"爆炸的期数-%@",maxaDatArr[4]);
    
    for(int i = 0;i < _returnArr.count-1;i++){
        for (int j = i+1; j<_returnArr.count; j++) {
            if ([_returnArr[j]floatValue] > [_returnArr[i]floatValue]) {
                NSNumber * temep = _returnArr[j];
                _returnArr[j] = _returnArr[i];
                _returnArr[i] = temep;
                [_combineArr exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
    
    NSLog(@"******************************* 排名前10的组合 ******************************************");
    
    NSString * periodStr = @"";
    NSString * moneyStr = @"";
    for (int i =0; i<10; i++) {
        NSString * str =@"";
        for (NSNumber* num in _combineArr[i]) {
            str = [NSString stringWithFormat:@"%@%@",str,num];
        }
        periodStr = [NSString stringWithFormat:@"%@%@;",periodStr,str];
        moneyStr = [NSString stringWithFormat:@"%@￥%.1f;",moneyStr,[_returnArr[i]floatValue]];
    }
    NSLog(@"期数:%@",periodStr);
    NSLog(@"利润:%@",moneyStr);
    
}

// 10个数中取5个数，找到每天出现次数最多的组合
-(void)playForMaxRepeat{
    NSLog(@"******************************* %ld天平均出现最多的10个数 组合 *******************************************",_dataDays);
    
    [self initCombineArr];
    
    for (NSMutableArray *arr in _combineArr) {
        // 还原
        _currentCombine = arr;
        
        [self initData];
        for (int i = 0; i<_dataDays; i++) {
            [self runContinue];
            
        }
        float repeatAllNum = 0;
        NSInteger oneceNum = 0;
        for (NSNumber * repeatNumber in _repeatNumArr) {
            repeatAllNum += repeatNumber.floatValue;
            if (repeatNumber.integerValue == 1) {
                oneceNum++;
            }
        }
        [_repeatRateArr addObject:@(repeatAllNum/_repeatNumArr.count)];
        [_onceArr addObject:@(oneceNum)];
        
    }
    float maxRepeatRate = 0.0;
    NSInteger maxRepeatCount = 0;
    for (NSNumber * rate in _repeatRateArr) {
        if (rate.floatValue > maxRepeatRate) {
            maxRepeatRate = rate.floatValue;
            maxRepeatCount = [_repeatRateArr indexOfObject:rate];
        }
    }
    NSLog(@"组合为%@ 的每天平均出现次数为%.2lf,出现1次的天数为%ld",_combineArr[maxRepeatCount],maxRepeatRate,[_onceArr[maxRepeatCount]integerValue]);
    
    for(int i = 0;i < _repeatRateArr.count-1;i++){
        for (int j = i+1; j<_repeatRateArr.count; j++) {
            if ([_repeatRateArr[j]floatValue] > [_repeatRateArr[i]floatValue]) {
                NSNumber * temep = _repeatRateArr[j];
                _repeatRateArr[j] = _repeatRateArr[i];
                _repeatRateArr[i] = temep;
                [_combineArr exchangeObjectAtIndex:i withObjectAtIndex:j];
                [_onceArr exchangeObjectAtIndex:i withObjectAtIndex:j];
                
            }
        }
    }
    NSInteger minOneceNum = 100;
    NSInteger minOneceCount = 0;
    NSInteger maxOneceNum = 0;
    NSInteger maxOneceCount = 0;
    
    for (NSNumber * onceNumber in _onceArr) {
        if (onceNumber.integerValue < minOneceNum) {
            minOneceNum = onceNumber.integerValue;
            minOneceCount = [_onceArr indexOfObject:onceNumber];
        }
        if (onceNumber.integerValue > maxOneceNum) {
            maxOneceNum = onceNumber.integerValue;
            maxOneceCount = [_onceArr indexOfObject:onceNumber];
        }
    }
    NSLog(@"出现一次次数最少的组合为%@，次数为%ld",_combineArr[minOneceCount],minOneceNum);
    NSLog(@"出现一次次数最多的组合为%@，次数为%ld",_combineArr[maxOneceCount],maxOneceNum);
    
    NSLog(@"******************************* 排名前10的组合 ******************************************");
    
    NSString * combineStr = @"";
    NSString * rateStr = @"";
    NSString * onceStr = @"";
    for (int i =0; i<10; i++) {
        NSString * str =@"";
        for (NSNumber* num in _combineArr[i]) {
            str = [NSString stringWithFormat:@"%@%@",str,num];
        }
        combineStr = [NSString stringWithFormat:@"%@%@;",combineStr,str];
        rateStr = [NSString stringWithFormat:@"%@%.2f;",rateStr,[_repeatRateArr[i]floatValue]];
        onceStr = [NSString stringWithFormat:@"%@%@;",onceStr,_onceArr[i]];
    }
    NSLog(@"组合:%@",combineStr);
    NSLog(@"平均出现次数:%@",rateStr);
    NSLog(@"1次的次数:%@",onceStr);
    
}

// 数字组合的出现频率
-(void)getRepeatRateWithCombine:(NSArray *)combine{
    NSInteger count = [_combineArr indexOfObject:combine];
    NSLog(@"组合%@每天的出现频率为%f",combine,[_repeatRateArr[count]floatValue]);
}




-(void)playBig{
    // 博大
    _bingoStype = bingoStyleBig;
    NSLog(@"******************************* 买大 *******************************************");
    [self runAll];
}

-(void)playSmall{
    // 博小
    _bingoStype = bingoStyleSmall;
    
    NSLog(@"\n\n******************************* 买小 *******************************************");
    [self runAll];
}

-(void)playSingle{ // 博单
    _bingoStype = bingoStyleSingle;
    
    NSLog(@"\n\n******************************* 买单 *******************************************");
    [self runAll];
    
}

-(void)playDouble{ // 博双
    _bingoStype = bingoStyleDouble;
    
    NSLog(@"\n\n******************************* 买双 *******************************************");
    
    [self runAll];
}

-(void)playStaticFiveWithArr:(NSArray *)arr{ // 查看5个数组合的数据
    _bingoStype = BingoStyleStaticFive;
    _staticFiveArr = arr;
    
    NSLog(@"\n\n******************************* 买%@ %@ %@ %@ %@ *******************************************",arr[0],arr[1],arr[2],arr[3],arr[4]);
    [self runAll];
}

#pragma mark 模拟所有数据的运行
-(void)runAll{
    [self initData];
    if (_testMode == testReturnMode) {
        for (int i = 0; i<_dataDays; i++) {
            [self run];
        }
        
        // 测算奖金
        [_boomArr removeObjectsInArray:@[@"20180215120",@"20180216120",@"20180217120",@"20180218120",@"20180219120",@"20180220120",@"20180221120"]];
        NSLog(@"\n 总奖金为%.1f , \n 总本金为%.1f,",_jiangjing,_benjing);
        NSLog(@"盈利：￥%.1f",_jiangjing-_benjing);
        NSLog(@"boom: %ld",_boomArr.count);
        NSLog(@"爆炸的期数-%@",_boomArr);
    }else if (_testMode == testRepeatMode){
        for (int i = 0; i<_dataDays; i++) {
            [self runContinue];
        }
        // 测算次数
        NSString * repeatNumStr = [_repeatNumArr componentsJoinedByString:@","];
        NSInteger allRepeatNum = 0;
        NSInteger oneceNum = 0; // 只出现一次的天数
        NSInteger boomNum = 0; // 爆炸的天数
        for (NSNumber * num in _repeatNumArr) {
            allRepeatNum += num.integerValue;
            if (num.integerValue == 0) {
                boomNum++;
            }
            if (num.integerValue == 1) {
                oneceNum++;
            }
            
        }
        NSLog(@"%ld天数据，每天出现的次数为%@",_dataDays,repeatNumStr);
        NSLog(@"\n平均每天出现%lf次,爆炸%ld次,出现一次的次数是%ld",allRepeatNum/(float)_dataDays,boomNum,oneceNum);
        
    }
}
/*
 _startPeriod            // 从第几轮开始投
 NSInteger _fromPeriod;  // 从多少期开始循环
 NSInteger _cyclePeriods; // 以多少期为周期   50~120
 NSInteger _PhaseNum;     // 多少轮         5~10
 NSInteger _periodInPhase; // 每轮多少期（=_cyclePeriods/_PhaseNum）
 */

- (void)runEverythingAll{
    _returnKeyDic = [NSMutableDictionary dictionary];
    _returnEverythingArr = [NSMutableArray array];
    _returnRateDic = [NSMutableDictionary dictionary];
    _returnRateEverythingArr = [NSMutableArray array];
    _firstShowNumMaxDic = [NSMutableDictionary dictionary];
    _firstShowNumMaxArr = [NSMutableArray array];
    [self initCombineArr];
    _cyclePeriods = 120;
    _PhaseNum = 12;
//    for (_cyclePeriods = 50; _cyclePeriods < 120; _cyclePeriods++) {
//        for (_PhaseNum = 5; _PhaseNum < 12; _PhaseNum++) {
//            for (_startPeriod = 0; _startPeriod < 10; _startPeriod++) {
    for (_fromPeriod = 0; _fromPeriod < 10; _fromPeriod++) {
                _periodInPhase = _cyclePeriods/_PhaseNum;
                for (NSMutableArray *arr in _combineArr) {
                    // 还原
//                    _currentCombine = [NSMutableArray arrayWithArray:@[@1,@8,@7,@3,@0]];
    _currentCombine = arr;
                    [self initData];
                    for (int i = 0; i<_numsArr.count/_cyclePeriods; i++) {
                        [self runEverything];
                    }

                    NSString * combineStr = [self getStrWithCombine:_currentCombine];
                    // 收益、收益成本比
//                    NSString * returnStr = [NSString stringWithFormat:@"%.2lf",_jiangjing-_benjing];
//                    [_returnEverythingArr addObject:returnStr];
//                    NSString * returnRateStr = [NSString stringWithFormat:@"%lf",_jiangjing/_benjing];
//                    [_returnRateEverythingArr addObject:returnRateStr];
//
//
//                    [_returnKeyDic setValue:[NSString stringWithFormat:@"%@-%@-%ld-%ld-%ld-%d-%.2lf",returnStr,[self getStrWithCombine:_currentCombine],_cyclePeriods,_PhaseNum,_startPeriod,_boomNum,_jiangjing/_benjing] forKey:returnStr];
//                    [_returnRateDic setValue:[NSString stringWithFormat:@"%@-%@-%ld-%ld-%ld-%d-%.2lf",returnStr,[self getStrWithCombine:_currentCombine],_cyclePeriods,_PhaseNum,_startPeriod,_boomNum,_jiangjing/_benjing] forKey:returnRateStr];
                    
                    // 第一次出现阶段的占比(以)
                    [self getMaxContinueNum:3 inArr:_firstShowInPhaseRateArr];
                    
                    // 最后3轮的占比
//                    [self getLastContinueNum:3 inArr:_firstShowInPhaseRateArr];
                    
                    
                    NSString * showMaxNumKey = [NSString stringWithFormat:@"%f-%@-%ld",_firstShowMaxNumInStaticPeriod,combineStr,_fromPeriod];
                    [_firstShowNumMaxArr addObject:showMaxNumKey];
                    _firstShowNumMaxDic[showMaxNumKey] = [NSString stringWithFormat:@"%@-%f-%f-%@-%ld-%ld",showMaxNumKey,(float)_firstShowMaxNumInStaticPeriod/(_dataDays-7),(float)_firstShowAllNum/(_dataDays-7),_staticPeriodStr,_cyclePeriods,_PhaseNum];
                    
                }
    
//            }
//        }
    }
//    _returnEverythingArr = [self getOrderArr:_returnEverythingArr];
//    for (int i = 0 ; i<50; i++) {
//        NSLog(@"%@",_returnKeyDic[_returnEverythingArr[i]]);
//    }
//    _returnRateEverythingArr = [self getOrderArr:_returnRateEverythingArr];
//    for (int i = 0 ; i<50; i++) {
//        NSLog(@"%@-%@",_returnRateEverythingArr[i],_returnRateDic[_returnRateEverythingArr[i]]);
//    }
    
    _firstShowNumMaxArr = [self getOrderArr:_firstShowNumMaxArr];
    for (int i = 0 ; i<50; i++) {
        NSLog(@"%@",_firstShowNumMaxDic[_firstShowNumMaxArr[i]]);
    }
    
}


-(void)runEverything{
//    [self initCombineArr];
//    _fromPeriod = 0;
//    _cyclePeriods = 120;
//    _PhaseNum = 12;
//    _periodInPhase = 10;
//    _startPeriod = 0;
    allNum = _cycleNum*_cyclePeriods+_fromPeriod;
    for (NSInteger count = 0; count<_PhaseNum; count++) { // 12个阶段
        for (NSInteger i = 0; i<_periodInPhase; i++) {         // 每个阶段10期
            double fee = 3.125;
            _beishu = 1;
            if (count >= 1+_startPeriod) {
                _beishu = pow(2.0, (double)(count-1-_startPeriod));
                fee = 3.125 * _beishu;
            }
            if (allNum > _numsArr.count-1) {
                return;
            }
            // 空数据直接无视（不计成本）
            if ([_numArr_0[allNum] isEqualToString:@""]) {
//                allNum++;
//                continue;
            }else{
            int num_0 = [_numArr_0[allNum]intValue];
            int num_1 = [_numArr_1[allNum]intValue];
            int num_2 = [_numArr_2[allNum]intValue];
            int num_3 = [_numArr_3[allNum]intValue];
            int num_4 = [_numArr_4[allNum]intValue];
#pragma mark 中奖
            
            if ([self bingoForStyle:_bingoStype num_0:num_0 num_1:num_1 num_2:num_2 num_3:num_3 num_4:num_4]) {
                if (count >= _startPeriod) {
                    _jiangjing += 97.8*_beishu;
                    _benjing +=fee;
                }
                _stopCount = count*_periodInPhase+i+1;
                
                NSInteger bingoNumInPhase = [_firstShowInPhaseRateArr[count]integerValue];
                _firstShowInPhaseRateArr[count] = @(bingoNumInPhase+1);
                
                count = _PhaseNum;
                _cycleNum++;
                //                NSLog(@"第%d期中奖",_stopCount);

                break;
            }
            
            if (count >= _startPeriod) {
                _benjing +=fee;
            }
            }
            if (count == _PhaseNum-1 && i ==_periodInPhase-1 ) {
                _boomNum++;
                _cycleNum++;
                [_boomArr addObject:_numsArr[allNum]];
            }
            
            allNum++;
            
        }
        //        NSLog(@"第%d轮的本金为-%lf",count,_benjing);
    }
}

#pragma mark  模拟一天的运行
// 模拟一天的运行       每天120注，12次押注倍数为（1，1，2，4，8，16.。。。）
-(void)run{
    allNum = _day*120;
    for (int count = 0; count<12; count++) { // 12个阶段
        for (int i = 0; i<10; i++) {         // 每个阶段10期
            double fee = 3.125;
            _beishu = 1;
            if (count >= 1+_startPeriod) {
                _beishu = pow(2.0, (double)(count-1-_startPeriod));
                fee = 3.125 * _beishu;
            }
            
            // 导入真实数据
            // 空数据直接无视（不计成本）
            if ([_numArr_0[allNum] isEqualToString:@""]) {
                if ([_numsArr[allNum] hasSuffix:@"120"]) {
                    _boomNum++;
                    _day++;
                    [_boomArr addObject:_numsArr[allNum]];
                    count = 12; //用来跳出最外层
                }
                allNum++;
                continue;
            }
            int num_0 = [_numArr_0[allNum]intValue];
            int num_1 = [_numArr_1[allNum]intValue];
            int num_2 = [_numArr_2[allNum]intValue];
            int num_3 = [_numArr_3[allNum]intValue];
            int num_4 = [_numArr_4[allNum]intValue];
#pragma mark 中奖

            if ([self bingoForStyle:_bingoStype num_0:num_0 num_1:num_1 num_2:num_2 num_3:num_3 num_4:num_4]) {
                
                if (count >= _startPeriod) {
                    _jiangjing += 97.8*_beishu;
                    _benjing +=fee;
                }
                
                _stopCount = count*10+i+1;
                count = 12;
                _day++;
                //                NSLog(@"第%d期中奖",_stopCount);
                

                
                break;
            }
            
            if (count >= _startPeriod) {
                _benjing +=fee;
            }
            if (count == 11 && i ==9 ) {
                // NSLog(@"boom!!!");
                _boomNum++;
                _day++;
                [_boomArr addObject:_numsArr[allNum]];
            }
            
            allNum++;
            
        }
        //        NSLog(@"第%d轮的本金为-%lf",count,_benjing);
        
    }
}

// 模拟一天的运行 测算一天出现数字的次数
-(void)runContinue{
    allNum = _day*120;
    NSInteger repeatNum = 0; // 一天中出现的次数
    for (int count = 0; count<12; count++) { // 12个阶段
        for (int i = 0; i<10; i++) {         // 每个阶段10期
            // 导入真实数据
            // 空数据直接无视（不计成本）
            if ([_numArr_0[allNum] isEqualToString:@""]) {
                if ([_numsArr[allNum] hasSuffix:@"120"]) {
                    _day++;
                    count = 12; //用来跳出最外层
                }
                allNum++;
                continue;
            }
            int num_0 = [_numArr_0[allNum]intValue];
            int num_1 = [_numArr_1[allNum]intValue];
            int num_2 = [_numArr_2[allNum]intValue];
            int num_3 = [_numArr_3[allNum]intValue];
            int num_4 = [_numArr_4[allNum]intValue];
#pragma mark 中奖
            
            if ([self bingoForStyle:_bingoStype num_0:num_0 num_1:num_1 num_2:num_2 num_3:num_3 num_4:num_4]) {
                repeatNum++;
            }
            if (count == 11 && i ==9 ) {
                _day++;
                [_repeatNumArr addObject:@(repeatNum)];
            }
            
            allNum++;
            
        }
    }
}



// 验证是否中奖的方式和数字组合
- (BOOL)bingoForStyle:(BingoStyle)style num_0:(NSInteger)num_0 num_1:(NSInteger)num_1 num_2:(NSInteger)num_2 num_3:(NSInteger)num_3 num_4:(NSInteger)num_4 {
    if (style == bingoStyleBig) {
        if (num_0 >4 && num_1>4 && num_2>4 && num_3>4 && num_4>4) {
            return YES;
        }
    }else if (style == bingoStyleSmall){
        if (num_0 <5 && num_1<5 && num_2 <5 && num_3<5 && num_4<5) {
            return YES;
        }
    }else if(style == bingoStyleMaxReturnFive){
        
        
        if ([_currentCombine containsObject:@(num_0)] && [_currentCombine containsObject:@(num_1)] && [_currentCombine containsObject:@(num_2)] && [_currentCombine containsObject:@(num_3)] && [_currentCombine containsObject:@(num_4)] ) {
            return YES;
        }
    }else if(style == bingoStyleSingle){
        if (num_0%2==1 && num_1%2==1 && num_2%2==1 && num_3%2==1 && num_4%2==1) {
            return YES;
        }
        
    }else if(style == bingoStyleDouble){
        if (num_0%2==0 && num_1%2==0 && num_2%2==0 && num_3%2==0 && num_4%2==0) {
            return YES;
        }
        
    }else if(style == BingoStyleStaticFive){
        
        if ([_staticFiveArr containsObject:@(num_0)] && [_staticFiveArr containsObject:@(num_1)] && [_staticFiveArr containsObject:@(num_2)] && [_staticFiveArr containsObject:@(num_3)] && [_staticFiveArr containsObject:@(num_4)] ) {
            return YES;
        }
    }
    
    return NO;
}

// 获得数组中最大的值已经序号
- (void)getMaxValueAndCountWithArr:(NSArray *)arr{
    NSInteger maxValue = 0;
    NSInteger maxValueCount = 0;
    for (NSNumber * num in arr) {
        if (num.integerValue > maxValue) {
            maxValue = num.integerValue;
            maxValueCount = [arr indexOfObject:num];
        }
    }
    
}

// 获取一个数组中连续的num个数的累加最大的值和这num个数的序号
-(void)getMaxContinueNum:(NSInteger)num inArr:(NSArray *)arr{
    
    for (NSNumber * firstShowNumInPhase in arr) {
        _firstShowAllNum += firstShowNumInPhase.floatValue;
    }
    
    for (NSInteger i = 0; ; i++) {
        float firstShowNum = 0;
        if (i % _PhaseNum== 0 && i !=0 ) {
            return;
        }else{
            for (NSInteger j = 0 ; j < num; j++) {
                firstShowNum += [_firstShowInPhaseRateArr[(i+ j)%_PhaseNum ]floatValue];
            }
        }
        if (firstShowNum > _firstShowMaxNumInStaticPeriod) {
            _firstShowMaxNumInStaticPeriod = firstShowNum;
            _staticPeriodStr = @"";
            for (int j = 0 ; j< num; j++) {
                _staticPeriodStr = [NSString stringWithFormat:@"%@~%ld(%@)",_staticPeriodStr,(i+ j)%_PhaseNum,_firstShowInPhaseRateArr[(i+ j)%_PhaseNum ]];
            }
        }
    }
}
// 最后num轮的第一次出现次数
- (void)getLastContinueNum:(NSInteger )num inArr:(NSArray *)arr{
    for (NSNumber * firstShowNumInPhase in arr) {
        _firstShowAllNum += firstShowNumInPhase.floatValue;
    }
    for (int i = 1 ; i<num+1; i++) {
        NSInteger index = _PhaseNum-i;
        _firstShowMaxNumInStaticPeriod += [_firstShowInPhaseRateArr[index]floatValue];
    }
}


// 组合转为字符串
-(NSString *)getStrWithCombine:(NSArray *)arr{
    NSString * combineStr = @"";
    for (NSNumber * num in arr) {
        combineStr = [NSString stringWithFormat:@"%@%@",combineStr,num];
    }
    return combineStr;
}

// 降序排列
-(NSMutableArray *)getOrderArr:(NSMutableArray *)arr{
    NSMutableArray * tempArr = [NSMutableArray arrayWithArray:arr];
    for(int i = 0;i < tempArr.count-1;i++){
        for (int j = i+1; j<tempArr.count; j++) {
            float iNum;
            float jNum;
            if ([tempArr[j] isKindOfClass:[NSString class]] && [tempArr[j] containsString:@"-"]) {
                // 取其中的数字部分
                jNum = [tempArr[j] componentsSeparatedByString:@"-"].firstObject.floatValue;
                iNum = [tempArr[i] componentsSeparatedByString:@"-"].firstObject.floatValue;
            }else{
                jNum = [tempArr[j]floatValue];
                iNum = [tempArr[i]floatValue];
            }
            if (jNum > iNum) {
                NSString * temp = tempArr[j];
                tempArr[j] = tempArr[i];
                tempArr[i] = temp;
            }
        }
    }
    return tempArr;
}


// 从n个数中选m个数的组合，得到组合数组
-(void)OC_combineN:(NSInteger )n M:(NSInteger)m arrA:(NSMutableArray *)a arrB:(NSMutableArray *)b M:(NSInteger)M{
    for (NSInteger j = n; j>=m; j--) {
        b[m-1] = @(j-1);
        if (m > 1) {
            [self OC_combineN:j-1 M:m-1 arrA:a arrB:b M:M];
        }else{
            NSMutableArray * arr = [NSMutableArray array];
            for(NSInteger i=M-1;i>=0;i--){
                [arr addObject:a[[b[i]integerValue]]];
            }
            [_combineArr addObject:arr];
            _combineNum++;
        }
    }
}



// C语言 组合算法
//void combine(int n,int m,int a[],int b[],const int M)
//
//{
//    for(int j=n;j>=m;j--)
//
//    {
//
//        b[m-1]=j-1;
//
//        if(m>1)combine(j-1,m-1,a,b,M);//用到了递归思想
//
//        else
//
//        {
//            for(int i=M-1;i>=0;i--)printf("%d ",a[b[i]]);
//            printf("\n");
//
//        }
//
//    }
//
//}

// c语言调用

//    int n=10,m=5;
//    scanf("%d%d",&n,&m);
//    int a[n];
//    int b[m];
//
//    for(int i=0;i<4;i++)
//        a[i]=i+1;
//    const int M=m;
//    combine(n,m,a,b,M);




@end
