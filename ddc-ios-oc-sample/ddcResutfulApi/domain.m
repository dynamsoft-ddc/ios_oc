//
//  main.m
//  ddc_oc_sample
//
//  Created by Shifeng Wang on 14/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "domain.h"
#import "DDCComm.h"
#import "DDCFormData.h"
#import "DDCHttpMultiPartRequest.h"
#import "DDCRestfulApiResponseParser.h"

NSString* DDCHandleRestfulApiResponse(DDCRestfulApiBasicResponse* restfulApiResponse, DDCEnumOcrFileMethod enumOcrFileMethod);

void(^doMoreLog)(NSString*);
void myLog(NSString* format){
    NSLog(@"%@", format);
    doMoreLog([format stringByAppendingString:@"\n"]);
}
void myLog1(NSString* format, id para){
    NSLog(format, para);
    doMoreLog([[NSString stringWithFormat:format, para] stringByAppendingString:@"\n"]);
}

int domain(void(^_doMoreLog)(NSString*)) {
    @autoreleasepool {
        doMoreLog = _doMoreLog;
        // setup ocr url and api key
        NSString* strOcrBaseUrl = @"https://cloud.dynamsoft.com/Rest/ocr/v1.1/file";
        NSMutableDictionary* dicHeader = [NSMutableDictionary new];
        [dicHeader setObject:@"YourOwnApiKey" forKey:@"x-api-key"];
        
        // 1. upload file
        myLog(@"-----------------------------------------------------------------------");
        myLog(@"1. Upload file...");
        
        DDCFormData* formData = [DDCFormData new];
        [formData Append:@"method" :@"upload"];//DDCEnumOcrFileMethod_Upload
        [formData Append:@"file" :[DDCComm GetFileData:@"example.jpg"] :@"example.jpg"];
        
        DDCHttpOriResponse* httpWebResponse;
        DDCRestfulApiBasicResponse* restfulApiResponse;
        @try{
            httpWebResponse = [DDCHttpMultiPartRequest Post:strOcrBaseUrl :dicHeader :formData];
            restfulApiResponse = [DDCRestfulApiResponseParser Parse:httpWebResponse :DDCEnumOcrFileMethod_Upload];
        }
        @catch(NSException *ex){
            myLog1(@"%@", ex);
            char c;
            scanf("%c", &c);
            return -1;
        }
        
        NSString* strFileName = DDCHandleRestfulApiResponse(restfulApiResponse, DDCEnumOcrFileMethod_Upload);
        if(nil == strFileName){return -1;}
        
        // 2. recognize the uploaded file
        myLog(@"\n-----------------------------------------------------------------------");
        myLog(@"2. Recognize the uploaded file...");
        
        [formData Clear];
        [formData Append:@"method" :@"recognize"];//DDCEnumOcrFileMethod_Recognize
        [formData Append:@"file_name" :strFileName];
        [formData Append:@"language" :@"eng"];
        [formData Append:@"output_format" :@"UFormattedTxt"];
        [formData Append:@"page_range" :@"1-10"];
        
        @try{
            httpWebResponse = [DDCHttpMultiPartRequest Post:strOcrBaseUrl :dicHeader :formData];
            restfulApiResponse = [DDCRestfulApiResponseParser Parse:httpWebResponse :DDCEnumOcrFileMethod_Recognize];
        }@catch(NSException *ex){
            myLog1(@"%@", ex);
            char c;
            scanf("%c", &c);
            return -1;
        }
        
        strFileName = DDCHandleRestfulApiResponse(restfulApiResponse, DDCEnumOcrFileMethod_Recognize);
        if(nil == strFileName){return -1;}
        
        // 3. download the recognized file
        myLog(@"\n-----------------------------------------------------------------------");
        myLog(@"2. Download the recognized file...");
        
        [formData Clear];
        [formData Append:@"method" :@"download"];//DDCEnumOcrFileMethod_Download
        [formData Append:@"file_name" :strFileName];
        
        @try{
            httpWebResponse = [DDCHttpMultiPartRequest Post:strOcrBaseUrl :dicHeader :formData];
            restfulApiResponse = [DDCRestfulApiResponseParser Parse:httpWebResponse :DDCEnumOcrFileMethod_Download];
        }@catch(NSException *ex){
            myLog1(@"%@", ex);
            char c;
            scanf("%c", &c);
            return -1;
        }
        strFileName = DDCHandleRestfulApiResponse(restfulApiResponse, DDCEnumOcrFileMethod_Download);
        if(nil == strFileName){return -1;}
        
        char c;
        scanf("%c", &c);
    }
    return 0;
}

// handle restful api response to control ocr step and print message
NSString* DDCHandleRestfulApiResponse(DDCRestfulApiBasicResponse* restfulApiResponse, DDCEnumOcrFileMethod enumOcrFileMethod){
    @autoreleasepool {
        switch (enumOcrFileMethod) {
            case DDCEnumOcrFileMethod_Upload:{
                DDCRestfulApiUploadResponse* uploadResponse = (DDCRestfulApiUploadResponse*)restfulApiResponse;
                if(nil == uploadResponse || 0 != uploadResponse->error_code){
                    if(nil == uploadResponse){
                        myLog(@"Upload Failed.");
                    }else{
                        myLog1(@"Upload Failed: %@.", uploadResponse->error_msg);
                    }
                    char c;
                    scanf("%c", &c);
                    return nil;
                }
                
                NSString* strFileName = uploadResponse->name;
                myLog1(@"Upload success: %@.", strFileName);
                return strFileName;
            }
            case DDCEnumOcrFileMethod_Recognize:{
                DDCRestfulApiRecognizationResponse* recognizationResponse = (DDCRestfulApiRecognizationResponse*)restfulApiResponse;
                DDCRestfulApiRecognizationSingleItemResponse* rr = [recognizationResponse->outputs objectAtIndex:0];
                myLog1(@"%@",rr->mtime);
                if(nil == recognizationResponse){
                    myLog(@"Recognization failed.");
                }else if(nil == recognizationResponse->outputs || 0 == [recognizationResponse->outputs count] || nil == [recognizationResponse->outputs firstObject]){
                    if(0 != recognizationResponse->error_code){
                        myLog1(@"Recognization failed: %@.", recognizationResponse->error_msg);
                    }else{
                        myLog(@"Recognization failed.");
                    }
                }else if(0 != [recognizationResponse->outputs firstObject]->error_code){
                    myLog1(@"Recognization failed: %@.", [recognizationResponse->outputs objectAtIndex:0]->error_msg);
                }else{
                    // success
                    NSString* strFileName = [recognizationResponse->outputs objectAtIndex:0]->output;
                    myLog1(@"Recognization success: %@.", strFileName);
                    return strFileName;
                }
                // fail
                char c;
                scanf("%c", &c);
                return nil;
                
            }
            case DDCEnumOcrFileMethod_Download:{
                DDCRestfulApiDownloadResponse* downloadResponse = (DDCRestfulApiDownloadResponse*)restfulApiResponse;
                if(nil == downloadResponse || 0 != downloadResponse->error_code){
                    if(nil == downloadResponse){
                        myLog(@"Download Failed.");
                    }else{
                        myLog1(@"Download Failed: %@.", downloadResponse->error_msg);
                    }
                    char c;
                    scanf("%c", &c);
                    return nil;
                }
                
                myLog1(@"Result: %@.", [[NSString alloc]initWithData:downloadResponse->buffer encoding:NSUTF16StringEncoding]);
                // no default file name
                return @"";
            }
            default:{
                myLog(@"Unsupported ocr method.");
                char c;
                scanf("%c", &c);
                return nil;
            }
        }
    }
}
