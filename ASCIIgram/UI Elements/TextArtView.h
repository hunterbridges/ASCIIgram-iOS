#import <UIKit/UIKit.h>
#import "TextArtViewDelegate.h"

@interface TextArtView : UIView;

@property (nonatomic, strong) UILabel *canvas;
@property (nonatomic, readonly) NSMutableArray *chars;
@property (nonatomic, strong) NSMutableArray *hitzones;
@property (nonatomic, strong) NSMutableArray *subTextArtViews;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int rows;
@property (nonatomic, assign) int cols;
@property (nonatomic, assign) int top;
@property (nonatomic, assign) int left;
@property (nonatomic, assign) BOOL fillWithSpaces;
@property (nonatomic, weak) TextArtView *superTextArtView;
@property (nonatomic, weak) id<TextArtViewDelegate> delegate;

- (id)initWithContentsOfTextFile:(NSString *)filename;
- (void)resetCanvasWithString:(NSString *)string andSizeToo:(BOOL)size;
- (void)resetCanvasWithFilename:(NSString *)filename andSizeToo:(BOOL)size;
- (void)fitToScreen;
- (void)drawCanvas;
- (void)addSubTextArtView:(TextArtView *)view;
- (void)drawSubTextArtView:(TextArtView *)view;
- (void)resetHitzones;
- (void)layerTextArtViewOnHitzones:(TextArtView *)view;
- (NSArray *)testTouches:(NSSet *)touches;
- (id)hitForRow:(int)row column:(int)column;

@end
