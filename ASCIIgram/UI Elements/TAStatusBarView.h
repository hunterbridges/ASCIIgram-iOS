#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TextArtView.h"

@interface TAStatusBarView : TextArtView {
  NSString *tpl_;
  NSString *carrierName_;
  NSString *timeString_;
  
  NSDate *now_;
  NSDateFormatter *dateFormatter_;
  NSTimer *dateRefresher_;
  
  CTTelephonyNetworkInfo *networkInfo_;
}

- (id)init;
- (void)update;
- (void)refreshDate;

@property (nonatomic, copy) NSString *tpl;
@property (nonatomic, copy) NSString *carrierName;
@property (nonatomic, copy) NSString *timeString;
@end
