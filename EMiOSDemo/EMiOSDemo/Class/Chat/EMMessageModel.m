//
//  EMMessageModel.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageModel.h"

@implementation EMMessageModel

- (instancetype)initWithEMMessage:(EMMessage *)aMsg
{
    self = [super init];
    if (self) {
        _emModel = aMsg;
        _direction = aMsg.direction;
        //_readReceiptCount = aMsg
        //_isReadReceipt = false;
        if (aMsg.body.type == EMMessageBodyTypeText) {
            if ([aMsg.ext objectForKey:MSG_EXT_GIF]) {
                _type = EMMessageTypeExtGif;
            } else if ([aMsg.ext objectForKey:MSG_EXT_RECALL]) {
                _type = EMMessageTypeExtRecall;
            } else {
                NSString *conferenceId = [aMsg.ext objectForKey:@"conferenceId"];
                if ([conferenceId length] == 0) {
                    conferenceId = [aMsg.ext objectForKey:MSG_EXT_CALLID];
                }
                if ([conferenceId length] > 0) {
                    _type = EMMessageTypeExtCall;
                } else {
                    _type = EMMessageTypeText;
                }
            }
            if (aMsg.isNeedGroupAck) {
                NSLog(@"\ncount:  %d",aMsg.groupAckCount);
                _readReceiptCount = [NSString stringWithFormat:@"阅读回执，已读用户（%d）",aMsg.groupAckCount];
            }
            /*
            if ([aMsg.ext objectForKey:MSG_EXT_READ_RECEIPT]){ //阅读回执
                _isReadReceipt = true;
            }*/
        } else {
            _type = (EMMessageType)aMsg.body.type;
        }
    }
    
    return self;
}

@end
