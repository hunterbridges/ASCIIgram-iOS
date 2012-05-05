#import <Foundation/Foundation.h>

@class TextArtView;
@protocol TextArtViewDelegate <NSObject>

-(void)textArtViewWasClicked:(TextArtView *)view;

@end
