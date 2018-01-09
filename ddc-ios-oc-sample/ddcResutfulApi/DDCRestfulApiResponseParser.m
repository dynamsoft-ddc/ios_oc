//
//  DDCRestfulApiResponseParser.m
//  ddc_oc_sample
//
//  Created by Shifeng Wang on 14/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import "DDCRestfulApiResponseParser.h"
#import <objc/runtime.h>


@implementation DDCRestfulApiBasicResponse
@end

@implementation DDCRestfulApiUploadResponse
@end

@implementation DDCRestfulApiRecognizationResponse
@end

@implementation DDCRestfulApiRecognizationSingleItemResponse
@end

@implementation DDCRestfulApiDownloadResponse
@end

@implementation DDCRestfulApiResponseParser
+(DDCRestfulApiBasicResponse*)Parse:(DDCHttpOriResponse*)response :(DDCEnumOcrFileMethod)enumOcrFileMethod{
    if(nil == response){
        @throw [NSException exceptionWithName:@"NullPointException" reason:@"Parameter response is nil." userInfo:nil];
    }
    NSDictionary<NSString*, id>* dic;
    if(NSNotFound != [[[response->mimetype stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString] rangeOfString:@"application/json"].location){
        dic = [NSJSONSerialization JSONObjectWithData:response->data options:kNilOptions error:nil];
    }
    switch (enumOcrFileMethod) {
        case DDCEnumOcrFileMethod_Upload:{
            DDCRestfulApiUploadResponse* updResponse = [DDCRestfulApiUploadResponse new];
            [updResponse setValuesForKeysWithDictionary:dic];
            return updResponse;
        }
        case DDCEnumOcrFileMethod_Recognize:{
            DDCRestfulApiRecognizationResponse* recResponse = [DDCRestfulApiRecognizationResponse new];
            [recResponse setValuesForKeysWithDictionary:dic];
            DDCRestfulApiRecognizationSingleItemResponse* item = [DDCRestfulApiRecognizationSingleItemResponse new];
            [item setValuesForKeysWithDictionary:[[dic objectForKey:@"outputs"]objectAtIndex:0]];
            recResponse->outputs = [[NSMutableArray<DDCRestfulApiRecognizationSingleItemResponse*> alloc]initWithObjects:item, nil];
            return recResponse;
        }
        case DDCEnumOcrFileMethod_Download:{
            DDCRestfulApiDownloadResponse* dldResponse = [DDCRestfulApiDownloadResponse new];
            if(nil != dic){
                [dldResponse setValuesForKeysWithDictionary:dic];
                return dldResponse;
            }else{
                dldResponse->buffer = response->data;
                return dldResponse;
            }
        }
        default:
            @throw [NSException exceptionWithName:@"UnsupportOcrMethodException" reason:@"Unsupported ocr method." userInfo:nil];
    }
}
@end
