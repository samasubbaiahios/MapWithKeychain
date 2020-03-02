//
//  LocalizationHelper.h
//  EPaisa
//
//  Created by subbu on 06/08/14.
//  Copyright (c) 2014 subbu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalizationHelper : NSObject

+(LocalizationHelper*)defaultLocalizationHelper;

-(void) selectedLanguageWithString:(NSString*)selected;
-(NSString*)languageSelectedStringForKey:(NSString*)key;
-(NSString*) selectedLocale;

@property(nonatomic,assign) int selectedLanguage;
@end


