//
//  MeetingViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/9/20.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import "MeetingViewController.h"

@interface MeetingViewController ()

@end

@implementation MeetingViewController

- (instancetype)initWithPassword:(NSString *)aPassword
                     inviteUsers:(NSArray *)aInviteUsers
{
    self = [super initWithType:EMConferenceTypeLargeCommunication password:aPassword inviteUsers:aInviteUsers];
    if (self) {
        self.isCreater = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _createOrJoinConference];
    
    //TODO: invite
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Subviews

#pragma mark - Video Views

- (CGRect)_getNewVideoViewFrame
{
    NSInteger count = [self.streamItemDict count];
    
    NSInteger row = count / kConferenceVideoMaxCol;
    NSInteger col = count % kConferenceVideoMaxCol;
    CGRect frame = CGRectMake(col * (self.videoViewSize.width + self.videoViewBorder), row * (self.videoViewSize.height + self.videoViewBorder), self.videoViewSize.width, self.videoViewSize.height);
    
    return frame;
}

- (EMConferenceVideoItem *)_setupNewVideoViewWithName:(NSString *)aName
                                          displayView:(UIView *)aDisplayView
                                               stream:(EMCallStream *)aStream
{
    CGRect frame = [self _getNewVideoViewFrame];
    EMConferenceVideoView *videoView = [[EMConferenceVideoView alloc] initWithFrame:frame];
    videoView.nameLabel.text = aName;
    videoView.displayView = aDisplayView;
    [videoView addSubview:aDisplayView];
    [videoView sendSubviewToBack:aDisplayView];
    [aDisplayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(videoView);
    }];
    [self.scrollView addSubview:videoView];
    
    EMConferenceVideoItem *retItem = [[EMConferenceVideoItem alloc] init];
    retItem.videoView = videoView;
    retItem.stream = aStream;
    if ([aStream.streamId length] > 0) {
        [self.streamItemDict setObject:retItem forKey:aStream.streamId];
    }
    
    return retItem;
}

#pragma mark - EMConference

- (void)_createOrJoinConference
{
    __weak typeof(self) weakself = self;
    void (^block)(EMCallConference *aCall, NSString *aPassword, EMError *aError) = ^(EMCallConference *aCall, NSString *aPassword, EMError *aError) {
        if (aError) {
            [self hangupAction];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:@"创建会议失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
            return ;
        }
        
        weakself.conference = aCall;
        weakself.password = aPassword;
        
        [weakself _pubLocalStreamWithEnableVideo:NO completion:nil];
    };
    
    if (self.isCreater) {
        [[EMClient sharedClient].conferenceManager createAndJoinConferenceWithType:self.type password:self.password completion:block];
    } else {
//        [[EMClient sharedClient].conferenceManager joinConferenceWithConfId:self.conferenceId password:self.password completion:^(EMCallConference *aCall, EMError *aError) {
//            block(aCall, @"", aError);
//        }];
    }
    
}

#pragma mark - EMStream

- (void)_pubLocalStreamWithEnableVideo:(BOOL)aEnableVideo
                            completion:(void (^)(NSString *aPubStreamId))aCompletionBlock
{
    //上传流的过程中，不允许操作视频按钮
    self.videoButton.enabled = NO;
    self.switchCameraButton.enabled = NO;
    
    EMStreamParam *pubConfig = [[EMStreamParam alloc] init];
    pubConfig.streamName = [EMClient sharedClient].currentUsername;
    pubConfig.enableVideo = aEnableVideo;
    
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    pubConfig.isFixedVideoResolution = options.isFixedVideoResolution;
    pubConfig.maxVideoKbps = (int)options.maxVideoKbps;
    pubConfig.maxAudioKbps = (int)options.maxAudioKbps;
    pubConfig.videoResolution = options.videoResolution;
    
    pubConfig.isBackCamera = self.switchCameraButton.isSelected;
    
    EMCallLocalView *localView = [[EMCallLocalView alloc] init];
    localView.scaleMode = EMCallViewScaleModeAspectFill;
    localView.backgroundColor = [UIColor blueColor];
    EMConferenceVideoItem *videoItem = [self _setupNewVideoViewWithName:pubConfig.streamName displayView:localView stream:nil];
    videoItem.videoView.enableVideo = aEnableVideo;
    pubConfig.localView = localView;
    
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient].conferenceManager publishConference:self.conference streamParam:pubConfig completion:^(NSString *aPubStreamId, EMError *aError) {
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"上传本地视频流失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return ;
            
            //TODO: 后续处理是怎么样的
        }
        
        weakself.videoButton.enabled = YES;
        weakself.videoButton.selected = aEnableVideo;
        weakself.switchCameraButton.enabled = YES;
        
        weakself.pubStreamId = aPubStreamId;
        [self.streamItemDict setObject:videoItem forKey:aPubStreamId];
        
        if (aCompletionBlock) {
            aCompletionBlock(aPubStreamId);
        }
    }];
}

#pragma mark - Action

- (void)videoButtonAction:(EMButton *)aButton
{
    aButton.selected = !aButton.isSelected;
    [[EMClient sharedClient].conferenceManager updateConference:self.conference enableVideo:aButton.selected];
    
    //TODO: 更新View
    EMConferenceVideoItem *videoItem = [self.streamItemDict objectForKey:self.pubStreamId];
    videoItem.videoView.enableVideo = aButton.isSelected;
}

@end
