//
//  ScanVC.m
//  DigiSheep
//
//  Created by Tomn on 19/01/2016.
//  Copyright © 2016 Tomn. All rights reserved.
//

#import "ScanVC.h"

@implementation ScanVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    refresh = self.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    });
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (flash)
            [self flash:nil];
        [session stopRunning];
    });
}

- (IBAction) flash:(id)sender
{
    UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
    flash = !flash;
    
    [session beginConfiguration];
    [captureDevice lockForConfiguration:nil];
    [captureDevice setTorchMode:(flash) ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
    [captureDevice unlockForConfiguration];
    [session commitConfiguration];
    
    if (flash)
    {
        item.image = [UIImage imageNamed:@"flashOn"];
        [self.navigationItem setLeftBarButtonItem:item animated:YES];
    }
    else
    {
        item.image = [UIImage imageNamed:@"flashOff"];
        [self.navigationItem setLeftBarButtonItem:item animated:YES];
    }
}

- (IBAction) retry:(id)sender
{
    codeDetecte = NO;
    detectView.frame = CGRectNull;
    [session startRunning];
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void) detectionCode:(NSString *)data
{
    codeDetecte = YES;
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
                [self detectionCode:detectionString];
                [self.navigationItem setRightBarButtonItem:refresh animated:YES];
                [session stopRunning];
            }
            break;
        }
    }
    
    detectView.frame = highlightViewRect;
}

@end
