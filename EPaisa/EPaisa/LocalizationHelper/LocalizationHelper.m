
//
//  LocalizationHelper.m
//  EPaisa
//
//  Created by subbu on 06/08/14.
//  Copyright (c) 2014 subbu. All rights reserved.
//

#import "LocalizationHelper.h"

static LocalizationHelper *localizationHelper = nil;

@interface LocalizationHelper()
{
    
}

@end


@implementation LocalizationHelper

@synthesize selectedLanguage = _selectedLanguage;

+(LocalizationHelper*)defaultLocalizationHelper
{
    if (localizationHelper == nil)
    {
        localizationHelper = [[LocalizationHelper alloc]init];
        
    }
    
    return localizationHelper;
}

-(void)selectedLanguageWithString:(NSString*)selected
{
    if([selected caseInsensitiveCompare:@"Spanish"]==NSOrderedSame)
    {
        _selectedLanguage = 1;
    }
    else
    {
        //DEFAULT ENGLISH
        _selectedLanguage = 2;
    }
    
}

-(NSString*) languageSelectedStringForKey:(NSString*) key
{
	NSString *path = nil;
    
    
	if(_selectedLanguage == 1)
		path = [[NSBundle mainBundle] pathForResource:@"es" ofType:@"lproj"];
	else
        path = [[NSBundle mainBundle] pathForResource:@"Base" ofType:@"lproj"];
    
    
	NSBundle* languageBundle = [NSBundle bundleWithPath:path];
	NSString* str= [languageBundle localizedStringForKey:key value:@"" table:nil];
    
    
	return str;
}

-(NSString*)selectedLocale
{
    
    NSString *locale = nil;
    
    if(_selectedLanguage==1)
        
        locale = @"es";
	else
        locale = @"en";
    
    return locale;
}



@end
