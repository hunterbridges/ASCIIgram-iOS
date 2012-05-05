#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TAStatusBarView.h"

@implementation TAStatusBarView
@synthesize tpl = tpl_;
@synthesize carrierName = carrierName_;
@synthesize timeString = timeString_;

- (id)init {
    self = [super init];
    if (self) {
      self.name = @"StatusBar";
      NSString *path = [[NSBundle mainBundle] pathForResource:@"StatusBar"
                                                       ofType:@"txt"];
      self.tpl =
          [NSString stringWithContentsOfFile:path
                                    encoding:NSUTF8StringEncoding
                                       error:nil];
      
      networkInfo_ = [[CTTelephonyNetworkInfo alloc] init];
      self.carrierName = networkInfo_.subscriberCellularProvider.carrierName;
      
      self.timeString = @" ";
      
      networkInfo_.subscriberCellularProviderDidUpdateNotifier =
          ^(CTCarrier* inCTCarrier) {
            dispatch_async(dispatch_get_main_queue(), ^{
              self.carrierName = inCTCarrier.carrierName;
            });
          };
      
      dateRefresher_ = 
          [NSTimer scheduledTimerWithTimeInterval:1.0
                                           target:self
                                         selector:@selector(refreshDate)
                                         userInfo:nil
                                          repeats:YES];
      dateFormatter_ = [[NSDateFormatter alloc] init];
      [dateFormatter_ setTimeStyle:NSDateFormatterShortStyle];
      [self refreshDate];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
          selector:@selector(update)
          name:UIDeviceBatteryLevelDidChangeNotification
          object:nil];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
          selector:@selector(update)
          name:UIDeviceBatteryStateDidChangeNotification
          object:nil];
      
      [self resetCanvasWithString:tpl_ andSizeToo:YES];
    }
    return self;
}

- (void)update {
  NSMutableString *line = [NSMutableString stringWithString:tpl_];
  
  // Cellular Signal
  NSMutableString *cellSignal =
      [NSMutableString stringWithString:@"                 "];
  [cellSignal replaceCharactersInRange:NSMakeRange(0, MIN(17, carrierName_.length))
                            withString:carrierName_];
  [line replaceCharactersInRange:NSMakeRange(0, 17) withString:cellSignal];
  
  // Time
  NSMutableString *time = [NSMutableString string];
  if (timeString_.length <= 7) {
    [time appendString:@""];
  }
  if (timeString_.length <= 5) {
    [time appendString:@""];
  }
  [time appendString:timeString_];
  for (int i = timeString_.length; i < 8; i++) {
    [time appendString:@" "];
  }
  [line replaceCharactersInRange:NSMakeRange(18, 8) withString:time];
  
  // Battery life
  NSMutableString *batteryLife = [NSMutableString string];
  int batteryPercentage =
      abs(floorf([[UIDevice currentDevice] batteryLevel] * 100));
  if (batteryPercentage < 100) {
    [batteryLife appendString:@" "];
  }
  [batteryLife appendString:[NSString stringWithFormat:@"%d", batteryPercentage]];
  [batteryLife appendString:@"%"];
  if ([[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateCharging ||
      [[UIDevice currentDevice] batteryState] == UIDeviceBatteryStateFull) {
    [batteryLife appendString:@"•"];
  } else {
    [batteryLife appendString:@" "];
  }
  
  NSString *emptyBatteryCell =
      [tpl_ substringWithRange:NSMakeRange(43, 1)];
  NSString *fullBatteryCell =
      [tpl_ substringWithRange:NSMakeRange(42, 1)];
  for (int i = 25; i <= 100; i += 25) {
    if (batteryPercentage >= i) {
      [batteryLife appendString:fullBatteryCell];
    } else {
      [batteryLife appendString:emptyBatteryCell];
    }
  }
  [line replaceCharactersInRange:NSMakeRange(35, 9) withString:batteryLife];
  
  [self resetCanvasWithString:line andSizeToo:YES];
  
  [self drawCanvas];
}

- (void)refreshDate {
  [now_ release];
  now_ = [[NSDate date] retain];
  self.timeString = [dateFormatter_ stringFromDate:now_];
}

- (void)setTimeString:(NSString *)timeString {
  BOOL needsUpdate = NO;
  if (timeString_ != nil) {
    if (![timeString_ isEqualToString:timeString]) needsUpdate = YES;
    [timeString_ release];
    timeString_ = nil;
  }
  timeString_ = [timeString copy];
  if (needsUpdate) {
    [self update];
  }
}

- (void)setCarrierName:(NSString *)carrierName {
  BOOL needsUpdate = NO;
  if (carrierName_ != nil) {
    if (![carrierName_ isEqualToString:carrierName]) needsUpdate = YES;
    [carrierName_ release];
    carrierName_ = nil;
  }
  if (carrierName == nil || [carrierName isEqualToString:@""]) {
    carrierName_ = [@"No Service" copy];
  } else {
    carrierName_ = [carrierName copy];
  }
  if (needsUpdate) {
    [self update];
  }
}

- (void)setSuperTextArtView:(TextArtView *)superTextArtView {
  [super setSuperTextArtView:superTextArtView];
  [self update];
}

- (void)dealloc {
  [dateRefresher_ invalidate];
  [dateFormatter_ release];
  [tpl_ release];
  [carrierName_ release];
  [super dealloc];
}
@end
