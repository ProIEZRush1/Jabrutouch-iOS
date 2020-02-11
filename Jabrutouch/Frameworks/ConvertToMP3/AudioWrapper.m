//
//  AudioWrapper.m
//  Jabrutouch
//
//  Created by AviDeutsch on 02/02/2020.
//  Copyright © 2020 Ravtech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioWrapper.h"
#import "lame/lame.h"

@interface AudioWrapper()
@end
@implementation AudioWrapper

+ (BOOL)convertFromWav:(NSString *)filePath destinationPath:(NSString *)destinationPath sourceSampleRate:(NSInteger)sourceSampleRate  {

    @try {
        unsigned long read, write;
//        NSString *mp3FileName = @"Mp3File";
//        mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
//        NSString *mp3FilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:mp3FileName];

        FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 8*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([destinationPath cStringUsingEncoding:1], "wb");  //output

        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        const int readCount = 2*sizeof(short int);
        short int pcm_buffer[PCM_SIZE*readCount];
        unsigned char mp3_buffer[MP3_SIZE];

        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, (int)sourceSampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);

        do {
            read = fread(pcm_buffer, readCount, PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, (int)read, mp3_buffer, MP3_SIZE);
                

            fwrite(mp3_buffer, write, 1, mp3);

        } while (read != 0);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        return NO;
    }
    @finally {
        return YES;
    }
}

@end
