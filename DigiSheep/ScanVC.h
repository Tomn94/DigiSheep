//
//  ScanVC.h
//  DigiSheep
//
//  Created by Tomn on 19/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

@import UIKit;
@import AVFoundation;

@interface ScanVC : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL flash, codeDetecte;
    UIBarButtonItem *refresh;
    
    AVCaptureVideoPreviewLayer *prevLayer;
    AVCaptureMetadataOutput *output;
    AVCaptureDevice *captureDevice;
    AVCaptureSession *session;
    NSTimeInterval lastCheckT;
    NSString *lastCheckS;
    UIView *detectView;
}

- (IBAction) flash:(id)sender;
- (IBAction) retry:(id)sender;
- (void) detectionCode:(NSString *)data;

@end
