//
//  DDCComm.h
//  ddc_oc_sample
//
//  Created by Shifeng Wang on 14/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _DDCEnumOctFileMethod {
    DDCEnumOcrFileMethod_Upload = 0,
    DDCEnumOcrFileMethod_Recognize,
    DDCEnumOcrFileMethod_Download
} DDCEnumOcrFileMethod;


@interface DDCComm : NSObject

+(NSObject*)GetFileData :(NSString*)strFileName;
+(NSString*)GetExampleImageBase64Data;
+(NSData*)ReadStreamToBytes :(NSStream*)stream;

@end
