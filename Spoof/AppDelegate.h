/**
 *  @file   AppDelegate.h
 *  @brief  AppDelegate Class Definition
 *  @author KrizTioaN (christiaanboersma@hotmail.com)
 *  @date   2021-07-23
 *  @note   BSD-3 licensed
 *
 ***********************************************/

#ifndef APPDELEGATE_H_
#define APPDELEGATE_H_

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>

@property (nonatomic, assign) IBOutlet NSPanel *panel;
@property (nonatomic, assign) IBOutlet NSTextField *MACAddressTextField;
@property (nonatomic, assign) IBOutlet NSTextField *statusTextField;
@end
#endif // End of APPDELEGATE_H_
