//
//  DDCRestfulApiResponseParser.h
//  ddc_oc_sample
//
//  Created by Shifeng Wang on 14/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCComm.h"
#import "DDCHttpMultiPartRequest.h"

@class DDCRestfulApiRecognizationSingleItemResponse;

@interface DDCRestfulApiBasicResponse : NSObject{
@public NSInteger error_code;
@public NSString* error_msg;
@public NSString* request_id;
}
@end

@interface DDCRestfulApiUploadResponse : DDCRestfulApiBasicResponse{
@public NSString* name;
@public NSInteger size;
@public NSString* ctime;
@public NSString* mtime;
@public NSString* md5;
@public NSInteger page_number;
}
@end

@interface DDCRestfulApiRecognizationResponse : DDCRestfulApiBasicResponse{
@public NSMutableArray<DDCRestfulApiRecognizationSingleItemResponse*>* outputs;
}
@end

@interface DDCRestfulApiRecognizationSingleItemResponse : NSObject{
@public NSString* output;
@public NSInteger size;
@public NSString* ctime;
@public NSString* mtime;
@public NSString* md5;
@public NSInteger error_code;
@public NSString* error_msg;
@public NSMutableArray<NSString*>* input;
}
@end

@interface DDCRestfulApiDownloadResponse : DDCRestfulApiBasicResponse{
@public NSData* buffer;
}
@end

@interface DDCRestfulApiResponseParser : NSObject
+(DDCRestfulApiBasicResponse*)Parse:(DDCHttpOriResponse*)response :(DDCEnumOcrFileMethod)enumOcrFileMethod;
@end
