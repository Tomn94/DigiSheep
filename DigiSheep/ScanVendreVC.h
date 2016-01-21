//
//  ScanVendreVC.h
//  DigiSheep
//
//  Created by Tomn on 20/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

@import UIKit;
@import AVFoundation;

#import "Data.h"
#import "JPSVolumeButtonHandler.h"

@interface ScanVendreVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL flash, codeDetecte;
    NSString *dataDectect;
    UIBarButtonItem *refresh;
    NSArray *toolbarInfos;
    UIDeviceOrientation o;
    UIAlertController *loadAlert;
    
    AVCaptureVideoPreviewLayer *prevLayer;
    AVCaptureMetadataOutput *output;
    AVCaptureDevice *captureDevice;
    AVCaptureSession *session;
    NSTimeInterval lastCheckT;
    NSString *lastCheckS;
    UIView *detectView;
    
    JPSVolumeButtonHandler *volumeButtonHandler;
}

@property (strong, nonatomic) NSDictionary *navette;

- (void) flash;
- (void) retry;
- (void) valider;
- (void) retourResa:(NSNotification *)notif;
- (void) detectionCode:(NSString *)data;

@end
