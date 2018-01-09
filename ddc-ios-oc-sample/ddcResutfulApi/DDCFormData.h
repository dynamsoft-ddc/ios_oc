//
//  DDCFormData.h
//  ddc_oc_sample
//
//  Created by Shifeng Wang on 14/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _DDCFormDataItem : NSObject {
@public NSString* key;
@public NSObject* value;
@public NSString* name;
}
@end

@interface DDCFormData : NSObject

-(instancetype)init;
-(void)Append :(NSString*)strKey :(NSObject*)value;
-(void)Append :(NSString*)strKey :(NSObject*)value :(NSString*)strFileName;
-(void)Clear;
-(BOOL)IsValid;
-(NSMutableArray<_DDCFormDataItem *>*)GetAll;

@end
