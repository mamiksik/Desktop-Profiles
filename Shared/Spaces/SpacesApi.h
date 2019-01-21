//
//  SpacesApi.h
//  CabinetproX
//
//  Created by Martin Miksik on 13/01/2019.
//  Copyright © 2019 Martin Miksik. All rights reserved.
//

#ifndef SpacesApi_h
#define SpacesApi_h

#include <Cocoa/Cocoa.h>

enum _CGSSpaceSelector
{
    kCGSSpaceCurrent = 5,
    kCGSSpaceOther = 6,
    kCGSSpaceAll = 7
};
typedef enum _CGSSpaceSelector CGSSpaceSelector;

typedef int CGSSpaceID;
typedef int CGSSpaceType;

struct _macos_space
{
    CFStringRef Ref;
    CGSSpaceID Id;
    CGSSpaceType Type;
};

typedef struct _macos_space macos_space;

#define CGSDefaultConnection _CGSDefaultConnection()
typedef int CGSConnectionID;

extern CGSConnectionID _CGSDefaultConnection(void);
extern CFArrayRef CGSCopyManagedDisplaySpaces(const CGSConnectionID Connection);
extern CFArrayRef CGSCopySpacesForWindows(CGSConnectionID Connection, CGSSpaceSelector Type, CFArrayRef Windows);

CFStringRef AXLibGetDisplayIdentifierFromArrangement(unsigned Arrangement);
CFStringRef AXLibGetDisplayIdentifierForMainDisplay();

macos_space **AXLibSpacesForDisplay(CFStringRef DisplayRef);
macos_space **AXLibSpacesForMainDisplay();
static CGSSpaceID AXLibActiveSpaceIdentifier(CFStringRef DisplayRef, CFStringRef *SpaceRef);

#endif /* SpacesApi_h */
    
