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
    
    UIBarButtonItem *status = [[UIBarButtonItem alloc] initWithTitle:@"En attente…"
                                                               style:UIBarButtonItemStyleDone
                                                              target:nil action:nil];
    status.tintColor = [UIColor grayColor];
    UIBarButtonItem *nom    = [[UIBarButtonItem alloc] initWithTitle:@""
                                                               style:UIBarButtonItemStylePlain
                                                              target:nil action:nil];
    nom.tintColor = [UIColor whiteColor];
    UIBarButtonItem *ecole  = [[UIBarButtonItem alloc] initWithTitle:@""
                                                               style:UIBarButtonItemStylePlain
                                                              target:nil action:nil];
    ecole.tintColor = [UIColor whiteColor];
    self.toolbarItems = @[status, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil action:nil],
                          nom,    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil action:nil],
                          ecole];
    toolbarInfos = self.toolbarItems;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (codeDetecte)
        return;
    
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
            [self flash:nil];
        } downBlock:^{
            if (runningTask == nil || runningTask.state == NSURLSessionTaskStateCompleted)
                [self retry:nil];
            else
                [self cancel];
        }];
    });
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (flash)
            [self flash:nil];
        [session stopRunning];
        volumeButtonHandler = nil;
    });
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
    if (codeDetecte)
        detectView.frame = CGRectNull;
}

#pragma mark - Actions

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
    detectView.layer.borderColor = [UIColor colorWithRed:0 green:0.88 blue:1 alpha:1].CGColor;
    [session startRunning];
    
    if (flash)
    {
        flash = !flash;
        [self flash:nil];
    }
    
    self.toolbarItems = nil;
    UIBarButtonItem *b1 = toolbarInfos[0];
    b1.title = @"En attente…";
    b1.tintColor = [UIColor grayColor];
    self.toolbarItems = @[b1, toolbarInfos[1]];
    self.navigationController.navigationBar.barTintColor = [UINavigationBar appearance].barTintColor;
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void) cancel
{
    cancel = YES;
    [runningTask cancel];
    [self retry:nil];
}

- (void) detectionCode:(NSString *)data
{
    codeDetecte = YES;
    
    // DÉTECTION HORS LIGNE
    @try {
        if (data != nil && ![data isEqualToString:@""] && [data rangeOfString:@","].location != NSNotFound)
        {
            NSArray *d = [data componentsSeparatedByString:@","];
            
            UIColor *coul = [UIColor colorWithRed:1.0 green:0.502 blue:0.0 alpha:1.0];
            UIBarButtonItem *b1 = toolbarInfos[0];
            b1.title = @"HORS-LIGNE";
            b1.tintColor = coul;
            UIBarButtonItem *b2 = toolbarInfos[2];
            b2.title = @"?";
            if ([d count] > 0 && d[0] != nil && ![d[0] isEqualToString:@""])
            {
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:d[0] options:0];
                if (decodedData)
                {
                    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
                    if (decodedString)
                        b2.title = decodedString;
                }
            }
            self.toolbarItems = @[b1, toolbarInfos[1], b2];
            self.navigationController.navigationBar.barTintColor = coul;
            detectView.layer.borderColor = coul.CGColor;
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    // VÉRIFICATION EN LIGNE
    if (runningTask == nil || runningTask.state == NSURLSessionTaskStateCompleted)
    {
        UIActivityIndicatorView *spin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spin startAnimating];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
        [spin setUserInteractionEnabled:YES];
        [spin addGestureRecognizer:tap];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:spin] animated:YES];
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession              *defaultSession      = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                                       delegate:nil
                                                                                  delegateQueue:[NSOperationQueue mainQueue]];
        
        NSString *qrdt = [[data dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        NSString *body = [NSString stringWithFormat:@"login=%@&password=%@&idevent=%ld&type=QR_CODE&barcode=%@",
                          [[Data sharedData] login], [[Data sharedData] pass], [[Data sharedData] sellEvent], qrdt];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL_CHECK]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
        runningTask = [defaultSession dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *r, NSError *error)
                       {
                           [[Data sharedData] updLoadingActivity:NO];
                           if (!cancel)
                               [self.navigationItem setRightBarButtonItem:refresh animated:YES];
                           else
                               cancel = NO;
                           
                           if (error == nil && data != nil)
                           {
                               NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:nil];
                               UIColor *coul = [UIColor colorWithRed:237/255. green:28/255. blue:36/255. alpha:1];
                               if ([JSON[@"status"] intValue] == 1)
                               {
                                   coul = [UIColor colorWithRed:0.3529 green:0.8314 blue:0.1529 alpha:1.0];
                                   UIBarButtonItem *b1 = toolbarInfos[0];
                                   b1.title = @"VALIDE";
                                   b1.tintColor = coul;
                                   UIBarButtonItem *b2 = toolbarInfos[2];
                                   b2.title = JSON[@"data"][@"clientname"];
                                   UIBarButtonItem *b3 = toolbarInfos[2];
                                   b3.title = JSON[@"data"][@"clientinfo"];
                                   self.toolbarItems = @[b1, toolbarInfos[1], b2, toolbarInfos[2], b3];
                               }
                               else
                               {
                                   UIBarButtonItem *b1 = toolbarInfos[0];
                                   b1.title = @"ERREUR";
                                   b1.tintColor = coul;
                                   UIBarButtonItem *b2 = toolbarInfos[2];
                                   b2.title = JSON[@"cause"];
                                   self.toolbarItems = @[b1, toolbarInfos[1], b2];
                               }
                               self.navigationController.navigationBar.barTintColor = coul;
                               detectView.layer.borderColor = coul.CGColor;
                           }
                       }];
        [runningTask resume];
        [[Data sharedData] updLoadingActivity:YES];
    }
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
