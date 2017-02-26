//
//  ScanVendreVC.m
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

#import "ScanVendreVC.h"

@implementation ScanVendreVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    o = [UIDevice currentDevice].orientation;
    self.view.backgroundColor = [UIColor blackColor];
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.navigationItem.title = @"Scanner le ticket à vendre";
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"flashOff"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(flash)] animated:NO];
    self.navigationItem.rightBarButtonItem.tintColor = [UINavigationBar appearance].tintColor;
    
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *status = [[UIBarButtonItem alloc] initWithTitle:@"En attente…"
                                                               style:UIBarButtonItemStyleDone
                                                              target:nil action:nil];
    status.tintColor = [UIColor grayColor];
    UIBarButtonItem *envoi = [[UIBarButtonItem alloc] initWithTitle:@"Envoi en cours…"
                                                               style:UIBarButtonItemStyleDone
                                                              target:nil action:nil];
    envoi.tintColor = [UIColor grayColor];
    UIBarButtonItem *annuler    = [[UIBarButtonItem alloc] initWithTitle:@"Reprendre"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(retry)];
    annuler.tintColor = [UIColor colorWithRed:237/255. green:28/255. blue:36/255. alpha:1];
    UIBarButtonItem *ok  = [[UIBarButtonItem alloc] initWithTitle:@"Valider"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self action:@selector(valider)];
    ok.tintColor = [UIColor colorWithRed:0.3529 green:0.8314 blue:0.1529 alpha:1.0];
    toolbarInfos = @[status, annuler, ok, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                        target:nil action:nil], envoi];
    self.toolbarItems = @[toolbarInfos[3], status, toolbarInfos[3]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retourResa:) name:@"retourResa" object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (codeDetecte)
        return;
    
    self.navigationController.toolbarHidden = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (input)
        {
            session = [AVCaptureSession new];
            if ([session canAddInput:input])
            {
                [session addInput:input];
                
                output = [AVCaptureMetadataOutput new];
                [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
                [session addOutput:output];
                output.metadataObjectTypes = [output availableMetadataObjectTypes];
                
                prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
                prevLayer.frame = self.view.bounds;
                prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                [self.view.layer addSublayer:prevLayer];
                
                detectView = [UIView new];
                detectView.layer.borderColor = [UIColor colorWithRed:0 green:0.88 blue:1 alpha:1].CGColor;
                detectView.layer.borderWidth = 3;
                detectView.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6].CGColor;
                [self.view addSubview:detectView];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pas d'accès à la caméra"
                                                                               message:@"Autorisez DigiSheep dans\nRéglages › Confidentialité › Appareil photo"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pas d'accès à la caméra"
                                                                           message:@"Autorisez DigiSheep dans\nRéglages › Confidentialité › Appareil photo"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        [session startRunning];
        
        volumeButtonHandler = [JPSVolumeButtonHandler volumeButtonHandlerWithUpBlock:^{
            [self flash];
        } downBlock:^{
            [self retry];
        }];
    });
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (flash)
            [self flash];
        [session stopRunning];
        volumeButtonHandler = nil;
    });
    self.navigationController.toolbarHidden = YES;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (prevLayer.connection && prevLayer.connection.supportsVideoOrientation)
    {
        switch ([UIDevice currentDevice].orientation)
        {
            case UIDeviceOrientationPortraitUpsideDown:
                prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case UIDeviceOrientationLandscapeLeft:
                prevLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                prevLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            default:
                prevLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    prevLayer.frame = self.view.bounds;
    if ([UIDevice currentDevice].orientation != o)
        detectView.frame = CGRectNull;
    o = [UIDevice currentDevice].orientation;
}

#pragma mark - Actions

- (void) flash
{
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    flash = !flash;
    
    [session beginConfiguration];
    [captureDevice lockForConfiguration:nil];
    [captureDevice setTorchMode:(flash) ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
    [captureDevice unlockForConfiguration];
    [session commitConfiguration];
    
    if (flash)
        item.image = [UIImage imageNamed:@"flashOn"];
    else
        item.image = [UIImage imageNamed:@"flashOff"];
    item.tintColor = [UINavigationBar appearance].tintColor;
    [self.navigationItem setRightBarButtonItem:item animated:YES];
}

- (void) retry
{
    codeDetecte = NO;
    dataDectect = nil;
    
    detectView.frame = CGRectNull;
    [session startRunning];
    
    if (flash)
    {
        flash = !flash;
        [self flash];
    }
    self.navigationController.navigationBar.tintColor = [UINavigationBar appearance].tintColor;
    
    self.toolbarItems = @[toolbarInfos[3], toolbarInfos[0], toolbarInfos[3]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.343 green:0.0 blue:0.5038 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.8684 green:0.8753 blue:0.9989 alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor] }];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.8684 green:0.8753 blue:0.9989 alpha:1.0]];
    [[UIApplication sharedApplication].windows[0] setTintColor:[UIColor colorWithRed:0.343 green:0.0 blue:0.5038 alpha:1]];
}

- (void) valider
{
    NSDictionary *d = @{ @"qrcode": dataDectect };
    if (_navette != nil)
        d = @{ @"navette": _navette,
               @"qrcode": dataDectect };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendInfosResa" object:nil userInfo:d];
    
    loadAlert = [UIAlertController alertControllerWithTitle:@"Réservation en cours"
                                                    message:@"Veuillez patienter…"
                                             preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:loadAlert animated:YES completion:nil];
    self.toolbarItems = @[toolbarInfos[3], toolbarInfos[4], toolbarInfos[3]];
}

- (void) retourResa:(NSNotification *)notif
{
    [loadAlert dismissViewControllerAnimated:NO completion:^{
        if ([notif.userInfo[@"status"] intValue] == 1)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Réservation"
                                                                           message:[@"La réservation a bien été effectuée au nom de " stringByAppendingString:notif.userInfo[@"nom"]]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"clearFields" object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Erreur"
                                                                           message:notif.userInfo[@"errMsg"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            self.toolbarItems = @[toolbarInfos[3], toolbarInfos[1], toolbarInfos[3], toolbarInfos[2], toolbarInfos[3]];
        }
    }];
}

- (void) detectionCode:(NSString *)data
{
    codeDetecte = YES;
    dataDectect = data;
    
    self.toolbarItems = @[toolbarInfos[3], toolbarInfos[1], toolbarInfos[3], toolbarInfos[2], toolbarInfos[3]];
}

#pragma mark - Capture Metadata Output Objects delegate

- (void)   captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
          fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            barCodeObject = (AVMetadataMachineReadableCodeObject *)[prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
            highlightViewRect = barCodeObject.bounds;
            detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            if (!codeDetecte)
            {
                AudioServicesPlaySystemSound(1108);
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                [self detectionCode:detectionString];
                [session stopRunning];
            }
            break;
        }
    }
    
    detectView.frame = highlightViewRect;
}

@end
