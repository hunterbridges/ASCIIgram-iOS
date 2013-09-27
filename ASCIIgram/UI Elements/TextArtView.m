#import "TextArtView.h"

@implementation TextArtView

- (id)init {
  self = [super init];
  if (self) {
    _chars = [[NSMutableArray alloc] init];
    
    self.hitzones = [[NSMutableArray alloc] init];
    self.subTextArtViews = [[NSMutableArray alloc] init];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.canvas = [[UILabel alloc] init];
    self.canvas.font = [UIFont fontWithName:@"CourierNewPSMT" size:12];
    
    self.canvas.textColor = [UIColor blackColor];
    self.canvas.backgroundColor = [UIColor whiteColor];
    self.canvas.numberOfLines = 0;
    
    [self addSubview:self.canvas];
    
    self.top = 0;
    self.left = 0;
    self.rows = 0;
    self.cols = 0;
  }
  return self;
}

- (id)initWithContentsOfTextFile:(NSString *)filename {
  self = [self init];
  if (self) {
    [self resetCanvasWithFilename:filename andSizeToo:YES];
  }
  return self;
}

- (void)resetCanvasWithFilename:(NSString *)filename andSizeToo:(BOOL)size {
  self.name = filename;
  NSString *path = [[NSBundle mainBundle] pathForResource:filename
                                                   ofType:@"txt"];
  NSString *baseScreen =
      [NSString stringWithContentsOfFile:path
                                encoding:NSUTF8StringEncoding
                                   error:nil];
  [self resetCanvasWithString:baseScreen andSizeToo:size];
  [self resetHitzones];
}

- (void)resetCanvasWithString:(NSString *)string andSizeToo:(BOOL)size {
  [self.chars removeAllObjects];
  
  NSMutableArray *rowStrings = [NSMutableArray
      arrayWithArray:[string componentsSeparatedByString:@"\n"]];
  NSMutableArray *croppedRowStrings = [NSMutableArray array];
  
  int foundRows = 0;
  int foundCols = 0;
  
  for (int idx = 0; idx < [rowStrings count] || (!size && idx < self.rows); idx++) {
    NSString *obj = [rowStrings objectAtIndex:idx];
    if ([obj length]) {
      int toIndex = 0;
      if (size) {
        toIndex = [obj length] ;
        foundCols = MAX(foundCols, [obj length]);
      } else {
        toIndex = MIN(self.cols, [obj length]);
      }
      NSString *newStr = [obj substringToIndex:toIndex];
      [croppedRowStrings addObject:newStr];
    } else {
      [croppedRowStrings addObject:@""];
    }
    if (size) {
      foundRows = MAX(foundRows, idx);
    }
  }
  
  if (size) {
    self.rows = foundRows;
    self.cols = foundCols;
  }
  
  [self.chars addObjectsFromArray:croppedRowStrings];
  [self resetHitzones];
  [self drawCanvas];
}

- (void)drawCanvas {
  if (self.superTextArtView == nil) {
    NSMutableString *render = [NSMutableString string];
    [self.chars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [render appendString:obj];
      [render appendString:@"\n"];
    }];
    self.canvas.text = render;
    [self.canvas sizeToFit];
  } else {
    [self.superTextArtView drawSubTextArtView:self];
  }
}

- (void)fitToScreen {
  self.frame = CGRectMake(0,
                          0,
                          [UIScreen mainScreen].bounds.size.width,
                          [UIScreen mainScreen].bounds.size.height);
  
  float rowHeight = 14.0;
  float colWidth = 7.2;
  
  self.rows = floorf(self.frame.size.height / rowHeight);
  self.cols = floorf(self.frame.size.width / colWidth);
  
  CGRect frame = CGRectMake(2,
                            2,
                            self.frame.size.width,
                            self.frame.size.height);
  self.canvas.frame = frame;
  [self resetHitzones];
}

- (void)addSubTextArtView:(TextArtView *)view {
  [self.subTextArtViews addObject:view];
  [self drawSubTextArtView:view];
  [self layerTextArtViewOnHitzones:view];
  view.superTextArtView = self;
}

- (void)drawSubTextArtView:(TextArtView *)view {
  for (int yAdjust = [self.chars count]; yAdjust < view.top + view.rows; yAdjust++){
    [self.chars addObject:@""];
  }
  for (int y = view.top; y < view.top + view.rows; y++) {
    NSMutableString *superRow;
    superRow =
        [NSMutableString stringWithString:[self.chars objectAtIndex:y]];
    NSString *subRow = [[view chars] objectAtIndex:y - view.top];
    NSRange range = NSMakeRange(view.left, subRow.length);
    if ([superRow length] < range.length) {
      for (int spaces = 0; spaces < range.length; spaces++) {
        [superRow appendString:@" "];
      }
    }
    
    [superRow replaceCharactersInRange:range withString:subRow];
    // Hit test? Only replace characters if this view is on top?
    [self.chars replaceObjectAtIndex:y withObject:superRow];
  }
  [self drawCanvas];
}

- (void)resetHitzones {
  [self.hitzones removeAllObjects];
  for (int row = 0; row < self.rows; row++) {
    NSMutableArray *columns = [NSMutableArray array];
    for (int col = 0; col < self.cols; col++) {
      [columns addObject:self];
    }
    [self.hitzones addObject:columns];
  }
  for (int i = 0; i < [self.subTextArtViews count]; i++) {
    TextArtView *tav = [self.subTextArtViews objectAtIndex:i];
    [self layerTextArtViewOnHitzones:tav];
  }
}

- (void)layerTextArtViewOnHitzones:(TextArtView *)view {
  for (int row = view.top; row < view.rows + view.top; row++) {
    NSMutableArray *columns = [self.hitzones objectAtIndex:row];
    for (int col = view.left; col < view.cols + view.left; col++) {
      [columns replaceObjectAtIndex:col withObject:view];
    }
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  //[self testTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  //[self testTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  NSArray *views = [self testTouches:touches];
  for (int i = 0; i < views.count; i++) {
    TextArtView *view = [views objectAtIndex:i];
    if (view.delegate &&
        [view.delegate respondsToSelector:@selector(textArtViewWasClicked:)]) {
      [view.delegate textArtViewWasClicked:view];
    }
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  
}

- (NSArray *)testTouches:(NSSet *)touches {
  NSArray *touchesArray = [touches allObjects];
  NSMutableArray *matchesArray = [NSMutableArray array];
  for (int i = 0; i < [touches count]; i++) {
    UITouch *touch = [touchesArray objectAtIndex:i];
    CGPoint location = [touch locationInView:self];
    float rowHeight = 14.0;
    float colWidth = 7.2;
    
    int row = floorf(location.y / rowHeight);
    int col = floorf(location.x / colWidth);
    TextArtView *tav = [self hitForRow:row column:col];
    if (tav) [matchesArray addObject:tav];
  }
  return matchesArray;
}

- (id)hitForRow:(int)row column:(int)column {
  if (row < 0 || column < 0) return nil;
  if (row >= self.rows || column >= self.cols) return nil;
  
  TextArtView *hit = [[self.hitzones objectAtIndex:row] objectAtIndex:column];
  if (![hit isEqual:self]) {
    hit = [hit hitForRow:(row - hit.top) column:(column - hit.left)];
  }
  return hit;
}


@end
