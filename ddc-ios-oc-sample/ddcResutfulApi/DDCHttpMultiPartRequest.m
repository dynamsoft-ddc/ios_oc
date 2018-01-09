//
//  DDCHttpMultiPartRequest.m
//  ddc_oc_sample
//
//  Created by Shifeng Wang on 14/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import "DDCHttpMultiPartRequest.h"

@implementation DDCHttpOriResponse
@end

static NSInteger DDCHttpMultiPartRequest_Encoding = NSUTF8StringEncoding;
static NSString* DDCHttpMultiPartRequest_StrBoundary;
@implementation DDCHttpMultiPartRequest
+(void)initialize{
    NSString* uuid = [[NSUUID UUID] UUIDString];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    DDCHttpMultiPartRequest_StrBoundary = [@"DdcOrcRestfulApiSample" stringByAppendingString:uuid];
}
+(NSInteger)GetEncoding{
    return DDCHttpMultiPartRequest_Encoding;
}
+(NSString*)GetStrBoundary{
    return DDCHttpMultiPartRequest_StrBoundary;
}
// post multi-part form data
+(DDCHttpOriResponse*)Post :(NSString*)strUrl :(NSDictionary<NSString*, NSString*>*)dicHeader :(DDCFormData*)formData{
    
    NSData* bodyData = [self ConstructRequestBodyData:formData];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:strUrl]];
    
    [request setHTTPMethod:@"POST"];
    NSString* contentType = [@"multipart/form-data; boundary=" stringByAppendingString:DDCHttpMultiPartRequest_StrBoundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    if(nil != dicHeader){
        for(NSString* key in dicHeader){
            NSString* value = [dicHeader objectForKey:key];
            [request setValue:value forHTTPHeaderField:key];
        }
    }
    
    request.HTTPBody = bodyData;
    
    // create a wait semaphore
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    __block DDCHttpOriResponse* ddcResponse = [DDCHttpOriResponse new];
    __block NSException* ex = nil;
    NSURLSession* session = [NSURLSession sharedSession];
    NSURLSessionTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable _response, NSError * _Nullable error) {
        NSHTTPURLResponse* response = (NSHTTPURLResponse*)_response;
        if(error){
            ex = [NSException exceptionWithName:@"RequestFailException" reason:[NSString stringWithFormat:@"%@", error] userInfo:nil];
        }else if(200 != [response statusCode]){
            ex = [NSException
                    exceptionWithName:@"RequestFailException"
                    reason:[NSString stringWithFormat:@"Request failed, status code is: %d.", (int)[response statusCode]]
                    userInfo:nil];
        }else{
            ddcResponse->mimetype = [response MIMEType];
            ddcResponse->data = data;
        }
        // release a wait
        dispatch_semaphore_signal(semaphore);
    }];
    [task resume];
    // wait for async task
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(semaphore);
    
    if(ex){ @throw ex; }
    return ddcResponse;
}
// construct request body data
+(NSData*)ConstructRequestBodyData:(DDCFormData*)formData{
    if(nil == formData || ![formData IsValid]){
        return [NSData init];
    }
    BOOL bHasItemAdded = NO;
    NSString* strNewLine = @"\r\n";
    NSString* strBoundarySeparator = @"--";
    
    NSMutableData* smRequestBodyData = [NSMutableData new];
    
    for(_DDCFormDataItem* formDataItem in [formData GetAll]){
        if(bHasItemAdded){ [smRequestBodyData appendData:[strNewLine dataUsingEncoding:(DDCHttpMultiPartRequest_Encoding)]]; }
        NSString* strKey = formDataItem->key;
        NSObject* value = formDataItem->value;
        NSString* strFileName = formDataItem->name;
        
        // write key value pair
        if(nil == strFileName || 0 == [strFileName length]){
            NSString* strFormDataItem = [[[NSArray<NSString*> alloc]initWithObjects:
                strBoundarySeparator,
                DDCHttpMultiPartRequest_StrBoundary,
                strNewLine,
                @"Content-Disposition: form-data; name=\"",strKey,@"\"",
                strNewLine,
                strNewLine,
                (NSString*)value,
                nil] componentsJoinedByString:@""];
            
            [smRequestBodyData appendData:[strFormDataItem dataUsingEncoding:DDCHttpMultiPartRequest_Encoding]];
        }
        //write file data
        else{
            //write base64 or binary data
            BOOL isNSData = [value isKindOfClass:[NSData class]];
            
            NSString* strHeader = [[[NSArray<NSString*> alloc]initWithObjects:
                                    strBoundarySeparator,
                                    DDCHttpMultiPartRequest_StrBoundary,
                                    strNewLine,
                                    @"Content-Disposition: form-data; name=\"",strKey,
                                    @"\"; filename=\"",strFileName,@"\"",
                                    strNewLine,
                                    @"Content-Type: ",
                                    (!isNSData ? @"text/plain" : @"application/octet-stream"),
                                    strNewLine,
                                    strNewLine,
                                    nil] componentsJoinedByString:@""];
            
            [smRequestBodyData appendData:[strHeader dataUsingEncoding:DDCHttpMultiPartRequest_Encoding]];
            [smRequestBodyData appendData:(isNSData ? (NSData*)value : [(NSString*)value dataUsingEncoding:DDCHttpMultiPartRequest_Encoding])];
        }
        bHasItemAdded = true;
    }
    
    if(bHasItemAdded){
        NSString* strFooter = [[[NSArray<NSString*> alloc] initWithObjects:
            strNewLine, strBoundarySeparator, DDCHttpMultiPartRequest_StrBoundary, strBoundarySeparator, strNewLine,
            nil] componentsJoinedByString:@""];
        [smRequestBodyData appendData:[strFooter dataUsingEncoding:DDCHttpMultiPartRequest_Encoding]];
    }
    return smRequestBodyData;
}
@end
