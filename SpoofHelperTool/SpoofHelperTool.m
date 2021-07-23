/**
 *  @file   SpoofHelperTool.m
 *  @brief  SpoofHelperTool Class Implementation
 *  @author KrizTioaN (christiaanboersma@hotmail.com)
 *  @date   2021-07-23
 *  @note   BSD-3 licensed
 *
 ***********************************************/

#import "SpoofHelperTool.h"

@interface SpoofHelperTool () <NSXPCListenerDelegate, SpoofHelperToolProtocol>

@property (atomic, strong, readwrite) NSXPCListener *listener;
@end

@implementation SpoofHelperTool

- (id)init {

    self = [super init];
    if (self != nil) {

        self->_listener = [[NSXPCListener alloc] initWithMachServiceName:kHelperToolMachServiceName];

        self->_listener.delegate = self;
    }

    return self;
}

- (void)run {
    
    [self.listener resume];
    
    [[NSRunLoop currentRunLoop] run];
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
 
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(SpoofHelperToolProtocol)];
 
    newConnection.exportedObject = self;
    
    [newConnection resume];
    
    return YES;
}

- (void)getVersionwithReply:(void(^)(NSString * version))reply {

    reply(kHelperToolVersion);
}

- (void)spoofInterface:(NSString *)interface withMac:(NSString *)mac andReply:(void(^)(NSString *status))reply {

    [self cmd:@"/sbin/ifconfig" withArgs:@[interface, @"ether", mac]];

    reply(@"success");
}

- (NSString *)cmd:(NSString *)cmd withArgs:(NSArray<NSString *> *)argv {
    
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = cmd;
    task.arguments = argv;
    task.standardOutput = pipe;
    
    [task launch];

    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *result = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    return result;
}

@end
