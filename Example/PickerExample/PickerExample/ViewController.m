//
//  ViewController.m
//  PickerExample
//
//  Created by Yu Sugawara on 2015/12/09.
//  Copyright © 2015年 Yu Sugawara. All rights reserved.
//

#import "ViewController.h"
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import <CTAssetsPickerController/CTAssetsGridSelectedView.h>
#import <CTAssetsPickerController/CTAssetsGridView.h>

@interface ViewController () <CTAssetsPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *presentButton;
@property (weak, nonatomic) IBOutlet UIButton *childButton;
@property (weak, nonatomic) IBOutlet UIView *containerArea;

@property (nonatomic) NSArray<PHAsset *> *selectedAssets;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof(self) wself = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.presentButton.enabled = wself.childButton.enabled = YES;
        });
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)presentButtonClicked:(id)sender
{
    [self presentViewController:[self pickerController]
                       animated:YES
                     completion:nil];
}

- (IBAction)childButtonClicked:(UIButton *)sender
{
    if ([self.childViewControllers count]) {
        for (UIViewController *vc in self.childViewControllers) {
            [vc willMoveToParentViewController:nil];
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
        return;
    }
    
    CTAssetsPickerController *picker = [self pickerController];
    [picker view]; // load view
    
    [picker setOverrideTraitCollection:[UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact]
                forChildViewController:picker.childSplitViewController];
    
    picker.view.frame = self.containerArea.bounds;    
    [self.containerArea addSubview:picker.view];
    [self addChildViewController:picker];
    [picker didMoveToParentViewController:self];
}

- (CTAssetsPickerController *)pickerController
{
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.delegate = self;
    
    picker.defaultAssetCollection = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    picker.alwaysEnableDoneButton = YES;
    picker.showsSelectionIndex = YES;
    picker.showsCancelButton = NO;
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    picker.assetsFetchOptions = fetchOptions;
    
    picker.selectedAssets = [NSMutableArray arrayWithArray:self.selectedAssets];
    
    return picker;
}

- (void)dismissPickerViewController:(CTAssetsPickerController *)picker
{
    if (picker.presentingViewController) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    } else if (picker.parentViewController) {
        [picker.view removeFromSuperview];
        [picker removeFromParentViewController];
    } else {
        NSAssert(false, @"Unsupported flow");
    }
}

#pragma mark - CTAssetsPickerControllerDelegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    NSLog(@"%s", __func__);
    
    self.selectedAssets = assets;
    
    [self dismissPickerViewController:picker];
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker
{
    NSLog(@"%s", __func__);
    
    [self dismissPickerViewController:picker];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldScrollToBottomForAssetCollection:(PHAssetCollection *)assetCollection
{
    NSLog(@"%s", __func__);
    
    // As assets are sorted by date and latest assets are on top of grid view,
    // we do not scroll the asset grid view to the bottom on shown.
    return NO;
}

- (void)ys_assetsPickerController:(CTAssetsPickerController *)picker didLongPressAsset:(PHAsset *)asset
{
    NSLog(@"%s, asset: %@", __func__, asset);
}

@end
