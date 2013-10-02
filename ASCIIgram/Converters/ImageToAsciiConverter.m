//
//  ImageToAsciiConverter.m
//  ASCIIgram
//
//  Created by Jeff Rafter on 10/1/13.
//  Copyright (c) 2013 Meedeor, LLC. All rights reserved.
//

#import "ImageToAsciiConverter.h"

@implementation ImageToAsciiConverter

// Symbols in order of visual magnitude (with escapes for \ and "
static const char *palette = "MN#H@gBWmKERqQ8kbXd9UaShpfFPDVA0nye4wsG5OTY6Zu$LzIJvxo2&C3rjct17][li+%\"=*?)/(\\<>;}{:_,^-!~'..` ";
static int paletteLength = 95;

- (char)charForPixel:(int)redValue {
  int index = round((redValue / 256.0) * paletteLength);
  return palette[index];
}


@end
