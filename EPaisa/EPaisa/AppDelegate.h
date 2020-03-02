//
//  AppDelegate.h
//  EPaisa
//
//  Created by subbu on 06/08/14.
//  Copyright (c) 2014 subbu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyChainWrapper/KeychainItemWrapper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) KeychainItemWrapper *keyChainAccess;


@end
