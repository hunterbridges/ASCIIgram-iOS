#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "TextArtView.h"

@interface TAStatusBarView : TextArtView;

@property (nonatomic, copy) NSDate *now;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSTimer *dateRefresher;
@property (nonatomic, copy) NSString *tpl;
@property (nonatomic, copy) NSString *carrierName;
@property (nonatomic, copy) NSString *timeString;
@property (nonatomic, strong) CTTelephonyNetworkInfo *networkInfo;

- (id)init;
- (void)update;
- (void)refreshDate;

@end
