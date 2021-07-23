/**
 *  @file   AppDelegate.m
 *  @brief  AppDelegate Class Implementation
 *  @author KrizTioaN (christiaanboersma@hotmail.com)
 *  @date   2021-07-23
 *  @note   BSD-3 licensed
 *
 ***********************************************/

#import "AppDelegate.h"

#import <IOKit/IOKitLib.h>
#import <IOKit/network/IOEthernetInterface.h>
#import <IOKit/network/IONetworkInterface.h>
#import <IOKit/network/IOEthernetController.h>

#import <ServiceManagement/ServiceManagement.h>

#import "SwitchViewWithLabel.h"

#import "SpoofHelperTool.h"

@interface AppDelegate ()

@property NSStatusItem *statusBarItem;
@property NSMenuItem *status;
@property SwitchViewWithLabel *view;
@property (atomic, strong, readwrite) NSXPCConnection *helperToolConnection;
@end

@implementation AppDelegate

@synthesize panel;
@synthesize MACAddressTextField;

static NSString *kSpoofKeySoftwareMac = @"softwareMac";

NSString *kSpoofSoftwareMac;
NSString *kBuiltInMac;
NSString *kPrimaryInterface;
NSImage *kSpoofImage;
NSImage *kUnspoofImage;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self findPrimaryInterfaceAndMac];
    
    NSLog(@"primary interface = %@\n", kPrimaryInterface);
    
    NSLog(@"built-in mac = %@", kBuiltInMac);
    
    if (![[NSUserDefaults standardUserDefaults] stringForKey:kSpoofKeySoftwareMac]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@"6c:40:08:b8:b6:4a" forKey:kSpoofKeySoftwareMac];
    }
    
    self.MACAddressTextField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:kSpoofKeySoftwareMac];
    
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDictionary *job = (__bridge NSDictionary *)(SMJobCopyDictionary(kSMDomainSystemLaunchd, (__bridge CFStringRef) kHelperToolMachServiceName));
    
    if(job) {
        
        [self connectAndExecuteCommandBlock:^(NSError * connectError) {
            
            if (connectError != nil) {
                
                NSLog(@"error %@ / %d\n", [connectError domain], (int) [connectError code]);
            }
            else {
                
                [[self.helperToolConnection remoteObjectProxyWithErrorHandler:^(NSError * proxyError) {
                    
                    NSLog(@"error %@ / %d\n", [proxyError domain], (int) [proxyError code]);
                }] getVersionwithReply:^(NSString *version) {
                    
                    NSLog(@"helper version = %@\n", version);
                    
                    if([version isNotEqualTo:kHelperToolVersion]) {
                        
                        [self installSpoofHelper];
                    }
                }];
            }
        }];
        
        CFRelease((__bridge CFDictionaryRef) job);
    }
    else {
        
        [self installSpoofHelper];
    }
    
    kSpoofImage = [NSImage imageNamed:@"stratego-spy.pdf"];
    [kSpoofImage setTemplate:YES];
    kSpoofImage.size = NSMakeSize(18.0, 18.0);
    
    kUnspoofImage = [NSImage imageNamed:@"stratego-marshal.pdf"];
    [kUnspoofImage setTemplate:YES];
    kUnspoofImage.size = NSMakeSize(18.0, 18.0);
    
    self.statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    NSMenu *statusBarMenu = [[NSMenu alloc] initWithTitle:@"MenuBar"];
    statusBarMenu.delegate = self;
    //statusBarMenu.autoenablesItems = NO;
    
    self.statusBarItem.menu = statusBarMenu;
    
    self.status = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    [self.status setEnabled:NO];
    [statusBarMenu addItem:self.status];
    
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    
    self.view = [[SwitchViewWithLabel alloc] init];
    [self.view.toggle setAction:@selector(spoof:)];
    [self.view.label setStringValue:@"Spoof"];
    
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [item setView:self.view];
    [statusBarMenu addItem:item];
    
    kSpoofSoftwareMac = [[NSUserDefaults standardUserDefaults] stringForKey:kSpoofKeySoftwareMac];
    
    /*item = [statusBarMenu addItemWithTitle:@"Spoof" action:@selector(spoof:)  keyEquivalent:@""];
     [item setImage:kSpoofImage];
     [item setRepresentedObject:[[NSUserDefaults standardUserDefaults] stringForKey:kSpoofKeySoftwareMac]];
     
     item = [statusBarMenu addItemWithTitle:@"Unspoof" action:@selector(spoof:) keyEquivalent:@""];
     [item setImage:kUnspoofImage];
     [item setRepresentedObject:kBuiltInMac];*/
    
    
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    
    [statusBarMenu addItemWithTitle:@"Settings…" action:@selector(settings) keyEquivalent:@""];
    
    [statusBarMenu addItem:[NSMenuItem separatorItem]];
    
    [statusBarMenu addItemWithTitle:@"Quit Spoof" action:@selector(terminate:) keyEquivalent:@"q"];
    
    [self checkStatus];
    
    [self.view.toggle setEnabled:YES];
}

- (void) menuWillOpen:(NSMenu *)menu {
    
    [self checkStatus];
}

- (void) checkStatus {
    
    NSString *arg2 = [NSString stringWithFormat:@"/sbin/ifconfig %@ ether | awk '/ether/{printf \"%%s\", $2}'", kPrimaryInterface];
    
    NSString *mac = [self cmd:@"/bin/sh" withArgs:@[@"-c", arg2]];
    
    [self.status setTitle:[NSString stringWithFormat:@"%@: %@", kPrimaryInterface, mac]];
    
    if([mac isEqualToString:kBuiltInMac]) {
        
        [self.view.toggle setState:NSControlStateValueOff];
        
        /*[[self.statusBarItem.menu itemWithTitle:@"Spoof"] setEnabled:YES];
         
         [[self.statusBarItem.menu itemWithTitle:@"Unspoof"] setEnabled:NO];*/
        
        [self.statusBarItem.button setImage:kUnspoofImage];
    }
    else {
        
        [self.view.toggle setState:NSControlStateValueOn];
        
        /*[[self.statusBarItem.menu itemWithTitle:@"Spoof"] setEnabled:NO];
         
         [[self.statusBarItem.menu itemWithTitle:@"Unspoof"] setEnabled:YES];*/
        
        [self.statusBarItem.button setImage:kSpoofImage];
    }
}

- (void) settings {
    
    [self.panel makeKeyAndOrderFront:self];
}

- (IBAction)done:(id)sender {
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2})$" options:NSRegularExpressionCaseInsensitive error:nil];
    
    if([regex numberOfMatchesInString:self.MACAddressTextField.stringValue options:0 range:NSMakeRange(0, [self.MACAddressTextField.stringValue length])] == 1) {
        
        self.statusTextField.stringValue = @"";
        
        [[NSUserDefaults standardUserDefaults] setObject:self.MACAddressTextField.stringValue forKey:kSpoofKeySoftwareMac];
        
        [self.panel orderOut:self];
        
        return;
    }
    
    self.statusTextField.stringValue = @"not valid";
}

- (NSString *)cmd:(NSString *)cmd withArgs:(NSArray<NSString *> *)argv{
    
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = cmd;
    task.arguments = argv;
    task.standardOutput = pipe;
    
    [[self.statusBarItem.menu itemWithTitle:@"Quit"] setEnabled:NO];
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    [[self.statusBarItem.menu itemWithTitle:@"Quit"] setEnabled:YES];
    
    return result;
}

- (void)connectToHelperTool {
    
    if (self.helperToolConnection == nil) {
        
        self.helperToolConnection = [[NSXPCConnection alloc] initWithMachServiceName:kHelperToolMachServiceName options:NSXPCConnectionPrivileged];
        
        self.helperToolConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SpoofHelperToolProtocol)];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
        self.helperToolConnection.invalidationHandler = ^{
            // If the connection gets invalidated then, on the main thread, nil out our
            // reference to it.  This ensures that we attempt to rebuild it the next time around.
            
            self.helperToolConnection.invalidationHandler = nil;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                self.helperToolConnection = nil;
                
                NSLog(@"connection = invalidated\n");
            }];
        };
        
#pragma clang diagnostic pop
        [self.helperToolConnection resume];
    }
}

- (void)connectAndExecuteCommandBlock:(void(^)(NSError *))commandBlock {
    
    [self connectToHelperTool];
    
    commandBlock(nil);
}

- (void)spoof:(id)sender {
    
    //NSString *address = [sender representedObject];

    NSString *address = self.view.toggle.state == NSControlStateValueOff ? kBuiltInMac : kSpoofSoftwareMac;

    [self connectAndExecuteCommandBlock:^(NSError * connectError) {
        
        if (connectError != nil) {
            
            NSLog(@"error %@ / %d\n", [connectError domain], (int) [connectError code]);
        }
        else {
            
            [[self.helperToolConnection remoteObjectProxyWithErrorHandler:^(NSError * proxyError) {
                
                NSLog(@"error %@ / %d\n", [proxyError domain], (int) [proxyError code]);
            }] spoofInterface:kPrimaryInterface withMac:address andReply:^(NSString *status) {
                
                NSLog(@"helper spoof = %@\n", status);
                
                [self performSelectorOnMainThread:@selector(checkStatus) withObject:nil waitUntilDone:NO];
            }];
        }
    }];
}

- (void)installSpoofHelper {
    
    BOOL success = NO;
    
    CFErrorRef error = nil;
    
    AuthorizationItem authItem  = {kSMRightBlessPrivilegedHelper, 0, NULL, 0};
    AuthorizationRights authRights = {1, &authItem};
    AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
    
    AuthorizationRef authRef = NULL;
    
    OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
    
    if (status != errAuthorizationSuccess) {
        
        CFStringRef errorMessageString = SecCopyErrorMessageString(status, NULL);
        
        NSLog(@"Failed to create AuthorizationRef. Error: %@", errorMessageString);
        
        CFRelease(errorMessageString);
    }
    else {
        
        success = SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef) kHelperToolMachServiceName, authRef, &error);
    }
    
    if (success) {
        
        NSLog(@"helper installation = success\n");
    }
    else {
        
        NSLog(@"error %@ / %d\n", [(__bridge NSError *) error domain], (int) [(__bridge NSError *) error code]);
    }
}

- (kern_return_t) findPrimaryInterfaceAndMac {
    
    kern_return_t kern_return = KERN_FAILURE;
    CFMutableDictionaryRef matchingDict;
    CFMutableDictionaryRef propertyMatchDict;
    io_iterator_t matchingServices;
    
    matchingDict = IOServiceMatching(kIOEthernetInterfaceClass);
    
    propertyMatchDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0,
                                                  &kCFTypeDictionaryKeyCallBacks,
                                                  &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(propertyMatchDict, CFSTR(kIOPrimaryInterface), kCFBooleanTrue);
    CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertyMatchDict);
    
    CFRelease(propertyMatchDict);
    
    kern_return = IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &matchingServices);
    
    if(kern_return == KERN_FAILURE) {
        
        return kern_return;
    }
    
    io_object_t interfaceService;
    io_object_t controllerService;
    
    while((interfaceService = IOIteratorNext(matchingServices))) {
        
        CFTypeRef MACAddressAsCFData;
        CFTypeRef interfacePrefixNameAsCFString;
        CFTypeRef interfaceUnitAsCFNumber;
        
        kern_return = IORegistryEntryGetParentEntry(interfaceService, kIOServicePlane, &controllerService);
        
        if(KERN_SUCCESS != kern_return) {
            
            NSLog(@"IORegistryEntryGetParentEntry = 0x%08x\n", kern_return);
        }
        else {
            
            interfacePrefixNameAsCFString = IORegistryEntryCreateCFProperty(interfaceService, CFSTR(kIOInterfaceNamePrefix), kCFAllocatorDefault, 0);
            
            if(interfacePrefixNameAsCFString) {
                
                kPrimaryInterface = (__bridge NSString * _Nonnull) interfacePrefixNameAsCFString;
                
                CFRelease(interfacePrefixNameAsCFString);
            }
            
            interfaceUnitAsCFNumber = IORegistryEntryCreateCFProperty(interfaceService, CFSTR(kIOInterfaceUnit), kCFAllocatorDefault, 0);
            
            if(interfaceUnitAsCFNumber) {
                
                kPrimaryInterface = [kPrimaryInterface stringByAppendingString:[(__bridge NSNumber *) interfaceUnitAsCFNumber stringValue]];
                
                CFRelease(interfaceUnitAsCFNumber);
            }
            
            MACAddressAsCFData = IORegistryEntryCreateCFProperty(controllerService, CFSTR(kIOMACAddress), kCFAllocatorDefault, 0);
            
            if (MACAddressAsCFData) {
                
                UInt8 mac[kIOEthernetAddressSize];
                bzero(mac, kIOEthernetAddressSize);
                
                CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), mac);
                
                kBuiltInMac = [[NSString alloc] initWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]];
                
                CFRelease(MACAddressAsCFData);
            }
            
            (void) IOObjectRelease(controllerService);
        }
        
        (void) IOObjectRelease(interfaceService);
    }
    
    (void) IOObjectRelease(matchingServices);
    
    return kern_return;
}

@end
