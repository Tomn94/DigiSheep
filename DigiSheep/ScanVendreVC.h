//
//  ScanVendreVC.h
//  DigiSheep
//
//  Created by Thomas Naudet on 20/01/2016.
//  Copyright © 2016 Thomas Naudet

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.

//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see http://www.gnu.org/licenses/
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
