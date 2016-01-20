//
//  ScanVC.h
//  DigiSheep
//
//  Created by Tomn on 19/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

@import UIKit;
@import AVFoundation;

#import "Data.h"
#import "JPSVolumeButtonHandler.h"

@interface ScanVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL flash, codeDetecte, cancel;
    UIBarButtonItem *refresh;
    NSArray *toolbarInfos;
    NSURLSessionDataTask *runningTask;
    
    AVCaptureVideoPreviewLayer *prevLayer;
    AVCaptureMetadataOutput *output;
    AVCaptureDevice *captureDevice;
    AVCaptureSession *session;
    NSTimeInterval lastCheckT;
    NSString *lastCheckS;
    UIView *detectView;
    
    JPSVolumeButtonHandler *volumeButtonHandler;
}

- (IBAction) flash:(id)sender;
- (IBAction) retry:(id)sender;
- (void) cancel;
- (void) detectionCode:(NSString *)data;

@end
