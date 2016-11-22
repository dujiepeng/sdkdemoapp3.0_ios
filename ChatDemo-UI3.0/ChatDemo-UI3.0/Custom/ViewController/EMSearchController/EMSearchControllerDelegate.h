/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@protocol EMSearchControllerDelegate <NSObject>

@optional

- (void)willSearchBegin;

- (void)willSearchFinish;

- (void)cancelButtonClicked;

- (void)searchButtonClickedWithString:(NSString *)aString;

@end