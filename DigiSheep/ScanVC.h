//
//  ScanVC.h
//  DigiSheep
//
//  Created by Thomas Naudet on 19/01/2016.
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
