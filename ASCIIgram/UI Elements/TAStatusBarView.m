#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TAStatusBarView.h"

@implementation TAStatusBarView

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
      
      self.networkInfo = [[CTTelephonyNetworkInfo alloc] init];
      self.carrierName = self.networkInfo.subscriberCellularProvider.carrierName;
      
      self.timeString = @" ";
      
      // Avoid the retain cycle in the block below
      __weak typeof(self) weakSelf = self;
        
      self.networkInfo.subscriberCellularProviderDidUpdateNotifier =
          ^(CTCarrier* inCTCarrier) {
            dispatch_async(dispatch_get_main_queue(), ^{
              weakSelf.carrierName = inCTCarrier.carrierName;
            });
          };
      
      self.dateRefresher =
          [NSTimer scheduledTimerWithTimeInterval:1.0
                                           target:self
                                         selector:@selector(refreshDate)
                                         userInfo:nil
                                          repeats:YES];
      self.dateFormatter = [[NSDateFormatter alloc] init];
      [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
      [self refreshDate];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
          selector:@selector(update)
          name:UIDeviceBatteryLevelDidChangeNotification
          object:nil];
      
      [[NSNotificationCenter defaultCenter] addObserver:self
          selector:@selector(update)
          name:UIDeviceBatteryStateDidChangeNotification
          object:nil];
      
      [self resetCanvasWithString:self.tpl andSizeToo:YES];
    }
    return self;
}

- (void)update {
  NSMutableString *line = [NSMutableString stringWithString:self.tpl];
  
  // Cellular Signal
  NSMutableString *cellSignal =
      [NSMutableString stringWithString:@"                 "];
  [cellSignal replaceCharactersInRange:NSMakeRange(0, MIN(17, self.carrierName.length))
                            withString:self.carrierName];
  [line replaceCharactersInRange:NSMakeRange(0, 17) withString:cellSignal];
  
  // Time
  NSMutableString *time = [NSMutableString string];
  if (self.timeString.length <= 7) {
    [time appendString:@""];
  }
  if (self.timeString.length <= 5) {
    [time appendString:@""];
  }
  [time appendString:self.timeString];
  for (int i = self.timeString.length; i < 8; i++) {
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
      [self.tpl substringWithRange:NSMakeRange(43, 1)];
  NSString *fullBatteryCell =
      [self.tpl substringWithRange:NSMakeRange(42, 1)];
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
  self.now = [NSDate date];
  self.timeString = [self.dateFormatter stringFromDate:self.now];
}

- (void)setTimeString:(NSString *)timeString {
  BOOL needsUpdate = NO;
  if (_timeString != nil) {
    if (![_timeString isEqualToString:timeString]) needsUpdate = YES;
    _timeString = nil;
  }
  _timeString = [timeString copy];
  if (needsUpdate) {
    [self update];
  }
}

- (void)setCarrierName:(NSString *)carrierName {
  BOOL needsUpdate = NO;
  if (_carrierName != nil) {
    if (![_carrierName isEqualToString:carrierName]) needsUpdate = YES;
    _carrierName = nil;
  }
  if (carrierName == nil || [carrierName isEqualToString:@""]) {
    _carrierName = [@"No Service" copy];
  } else {
    _carrierName = [carrierName copy];
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
  [self.dateRefresher invalidate];
}
@end
