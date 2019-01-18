//
//  SpacesApi.m
//  CabinetproX
//
//  Created by Martin Miksik on 13/01/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpacesApi.h"





/* NOTE(koekeishiya): Caller is responsible for calling CFRelease. */
CFStringRef AXLibGetDisplayIdentifierFromArrangement(unsigned Arrangement)
{
    unsigned Index = 0;
    CFStringRef Result = NULL;
    CFArrayRef DisplayDictionaries = CGSCopyManagedDisplaySpaces(CGSDefaultConnection);
    for (NSDictionary *DisplayDictionary in (__bridge NSArray *) DisplayDictionaries) {
        NSString *DisplayIdentifier = DisplayDictionary[@"Display Identifier"];
        if (Index == Arrangement) {
            Result = (__bridge_retained CFStringRef) [[NSString alloc] initWithString:DisplayIdentifier];
            break;
        }
        ++Index;
    }
    CFRelease(DisplayDictionaries);
    return Result;
}

/* NOTE(koekeishiya): Caller is responsible for calling CFRelease. */
CFStringRef AXLibGetDisplayIdentifierForMainDisplay()
{
    return AXLibGetDisplayIdentifierFromArrangement(0);
}

static macos_space *AXLibConstructSpace(CFStringRef Ref, CGSSpaceID Id, CGSSpaceType Type)
{
    macos_space *Space = (macos_space *) malloc(sizeof(macos_space));
    
    Space->Ref = Ref;
    Space->Id = Id;
    Space->Type = Type;
    
    return Space;
}

macos_space **AXLibSpacesForDisplay(CFStringRef DisplayRef)
{
    macos_space **Result = NULL;
//    print(Dis)
//    NSString *CurrentIdentifier =  DisplayRef;
    NSString *CurrentIdentifier = (__bridge NSString *) DisplayRef;
    
    CFArrayRef DisplayDictionaries = CGSCopyManagedDisplaySpaces(CGSDefaultConnection);
    for (NSDictionary *DisplayDictionary in (__bridge NSArray *) DisplayDictionaries) {
        
        NSString *DisplayIdentifier = DisplayDictionary[@"Display Identifier"];
        if ([DisplayIdentifier isEqualToString:CurrentIdentifier]) {
            NSArray *SpaceDictionaries = DisplayDictionary[@"Spaces"];
            int SpaceCount = [SpaceDictionaries count] + 1;
            Result = (macos_space **) malloc(SpaceCount * sizeof(macos_space *));
            
            int SpaceIndex = 0;
            for (NSDictionary *SpaceDictionary in SpaceDictionaries) {
                CGSSpaceID SpaceId = [SpaceDictionary[@"id64"] intValue];
                CGSSpaceType SpaceType = [SpaceDictionary[@"type"] intValue];
                CFStringRef SpaceRef = (__bridge CFStringRef) [[NSString alloc] initWithString:SpaceDictionary[@"uuid"]];
                macos_space *Space = AXLibConstructSpace(SpaceRef, SpaceId, SpaceType);
                Result[SpaceIndex++] = Space;
                NSLog(@"%i", SpaceId);
            }
            
            Result[SpaceIndex] = NULL;
        }
    }
    
    return Result;
}

macos_space **AXLibSpacesForMainDisplay()
{
    return AXLibSpacesForDisplay(AXLibGetDisplayIdentifierForMainDisplay());
}

static CGSSpaceID AXLibActiveSpaceIdentifier(CFStringRef DisplayRef, CFStringRef *SpaceRef)
{
    CGSSpaceID ActiveSpaceId = 0;
    NSString *CurrentIdentifier = (__bridge NSString *) DisplayRef;
    
    CFArrayRef DisplayDictionaries = CGSCopyManagedDisplaySpaces(CGSDefaultConnection);
    for (NSDictionary *DisplayDictionary in (__bridge NSArray *) DisplayDictionaries) {
        NSString *DisplayIdentifier = DisplayDictionary[@"Display Identifier"];
        if ([DisplayIdentifier isEqualToString:CurrentIdentifier]) {
            *SpaceRef = (__bridge CFStringRef) [[NSString alloc] initWithString:DisplayDictionary[@"Current Space"][@"uuid"]];
            ActiveSpaceId = [DisplayDictionary[@"Current Space"][@"id64"] intValue];
            break;
        }
    }
    
    CFRelease(DisplayDictionaries);
    return ActiveSpaceId;
}

