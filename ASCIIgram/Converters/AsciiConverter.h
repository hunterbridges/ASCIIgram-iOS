//
//  AsciiConverter.h
//  ASCIIgram
//
//  Created by Jeff Rafter on 10/1/13.
//  Copyright (c) 2013 Meedeor, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@interface AsciiConverter : NSObject

@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImageFilter *output;

- (NSString *)convert:(UIImage *)image;

@end
