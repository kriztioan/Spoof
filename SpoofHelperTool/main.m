/**
 *  @file   main.m
 *  @brief  SpoofHelperTool Entrypoint
 *  @author KrizTioaN (christiaanboersma@hotmail.com)
 *  @date   2021-07-23
 *  @note   BSD-3 licensed
 *
 ***********************************************/

#import <Foundation/Foundation.h>

#import "SpoofHelperTool.h"

int main(int argc, const char * argv[]) {
     
      @autoreleasepool {

          SpoofHelperTool *  m;
          
          m = [[SpoofHelperTool alloc] init];
          [m run];
      }
      
      return EXIT_FAILURE;
}
