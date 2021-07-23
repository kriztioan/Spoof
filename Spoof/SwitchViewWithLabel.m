/**
 *  @file   SwitchViewWithLabel.m
 *  @brief  SwitchViewWithLabel Class Implementation
 *  @author KrizTioaN (christiaanboersma@hotmail.com)
 *  @date   2021-07-23
 *  @note   BSD-3 licensed
 *
 ***********************************************/

#import "SwitchViewWithLabel.h"

@implementation SwitchViewWithLabel

- (instancetype)init {
    
    if ( self = [super init] ) {
        CGRect frame = CGRectMake(0, 0, 200, 22);
        [self setFrame:frame];
        self.label = [[NSTextField alloc] initWithFrame:frame];
        [self.label setBackgroundColor:[NSColor clearColor]];
        [self.label setFont:[NSFont systemFontOfSize:14]];
        [self.label setBezeled:NO];
        [self.label setFrameOrigin:CGPointMake(12.5, 0)];
        [self.label setFrameSize:CGSizeMake(50, 22)];
        self.toggle = [[NSSwitch alloc] initWithFrame:frame];
        [self.toggle setFrameOrigin:CGPointMake(154, 0)];
        [self.toggle setFrameSize:CGSizeMake(50, 22)];
        [self addSubview:self.label];
        [self addSubview:self.toggle];
        return self;
    }
    return nil;
}

- (void)viewDidMoveToWindow {
    [[self window] becomeKeyWindow];
}

@end
