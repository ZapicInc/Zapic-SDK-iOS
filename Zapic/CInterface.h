//
//  CInterface.h
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern “C” {
#endif
    
    void framework_hello();
    void framework_message(const char* message);
    
#ifdef __cplusplus
}
#endif
