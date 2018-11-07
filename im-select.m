//
//  im-select
//
//  Created by Ying Bian on 8/21/12.
//  Copyright (c) 2012 Ying Bian. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <Foundation/Foundation.h>

int main(int argc, const char* argv[])
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    int returnCode = 0;
    TISInputSourceRef current = TISCopyCurrentKeyboardInputSource();
    NSString* sourceId = (NSString*)(TISGetInputSourceProperty(current, kTISPropertyInputSourceID));
    fprintf(stdout, "%s\n", [sourceId UTF8String]);
    CFRelease(current);

    if (argc > 1) {
        NSString* imId = [NSString stringWithUTF8String:argv[1]];
        NSDictionary* filter = [NSDictionary dictionaryWithObject:imId forKey:(NSString*)kTISPropertyInputSourceID];
        CFArrayRef keyboards = TISCreateInputSourceList((CFDictionaryRef)filter, false);
        if (keyboards) {
            TISInputSourceRef selected = (TISInputSourceRef)CFArrayGetValueAtIndex(keyboards, 0);
            returnCode = TISSelectInputSource(selected);
            CFRelease(keyboards);
        } else {
            returnCode = 1;
        }
    }

    [pool release];

    return returnCode;
}
