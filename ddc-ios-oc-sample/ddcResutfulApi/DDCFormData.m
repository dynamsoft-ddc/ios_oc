//
//  DDCFormData.m
//  ddc_oc_sample
//
//  Created by Shifeng Wang on 14/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import "DDCFormData.h"


@implementation _DDCFormDataItem
@end

@implementation DDCFormData{
    NSMutableArray<_DDCFormDataItem *>* _listFormData;
}
-(instancetype)init{
    if(self = [super init]){
        _listFormData = [NSMutableArray<_DDCFormDataItem *> new];
    }
    return self;
}

-(void)Append :(NSString*)strKey :(NSObject*)value{
    [self Append :strKey :value :nil];
}
-(void)Append :(NSString*)strKey :(NSObject*)value :(NSString*)strFileName{
    _DDCFormDataItem* item = [_DDCFormDataItem new];
    item->key = strKey;
    item->value = value;
    item->name = strFileName;
    [_listFormData addObject:item];
}
-(void)Clear{
    [_listFormData removeAllObjects];
}
-(BOOL)IsValid{
    return nil != _listFormData;
}
-(NSMutableArray<_DDCFormDataItem *>*)GetAll{
    return _listFormData;
}
@end
