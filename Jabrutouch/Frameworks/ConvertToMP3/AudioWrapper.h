//
//  AudioWrapper.h
//  Jabrutouch
//
//  Created by AviDeutsch on 02/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifndef AudioWrapper_h
#define AudioWrapper_h


#endif /* AudioWrapper_h */
@interface AudioWrapper : NSObject
+ (BOOL)convertFromWav:(NSString *)filePath destinationPath:(NSString *)destinationPath sourceSampleRate:(NSInteger)sourceSampleRate;
@end
