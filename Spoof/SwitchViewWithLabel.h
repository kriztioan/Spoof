/**
 *  @file   SwitchViewWithLabel.h
 *  @brief  SwitchViewWithLabel Class Definition
 *  @author KrizTioaN (christiaanboersma@hotmail.com)
 *  @date   2021-07-23
 *  @note   BSD-3 licensed
 *
 ***********************************************/

#import <Cocoa/Cocoa.h>

#ifndef SWITCHVIEWWITHLABEL_H_
#define SWITCHVIEWWITHLABEL_H_

NS_ASSUME_NONNULL_BEGIN

@interface SwitchViewWithLabel : NSView
@property (nonatomic, retain) NSTextField *label;
@property (nonatomic, retain) NSSwitch *toggle;
@end

NS_ASSUME_NONNULL_END

#endif // End of SWITCHVIEWWITHLABEL_H_
