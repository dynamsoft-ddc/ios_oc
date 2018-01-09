//
//  DDCHttpMultiPartRequest.h
//  ddc_oc_sample
//
//  Created by Shifeng Wang on 14/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDCFormData.h"

@interface DDCHttpOriResponse : NSObject{
@public NSString* mimetype;
@public NSData* data;
}
@end

@interface DDCHttpMultiPartRequest : NSObject
+(NSInteger)GetEncoding;
+(NSString*)GetStrBoundary;
+(DDCHttpOriResponse*)Post :(NSString*)strUrl :(NSDictionary<NSString*, NSString*>*)dicHeader :(DDCFormData*)formData;
@end
