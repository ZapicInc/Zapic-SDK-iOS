//
//  CInterface.m
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

//#import "CInterface.h"
#import <Foundation/Foundation.h>
#import <Zapic/Zapic-Swift.h>

extern "C" {
    
    void z_connect(){        
        [Zapic connect];
    }
    
    /*
     * Debug Log
     */
    void c_debugLog(){
        printf("Zapic log");
    }
}
