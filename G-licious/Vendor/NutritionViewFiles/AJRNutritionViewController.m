//
//  AJRNutritionViewController.m
//  AJRNutritionControllerDemo
//
//  Created by Andrew Rosenblum on 2/9/13.
//  Copyright (c) 2013 On Tap Media. All rights reserved.
//
//
//Copyright (c) 2013, Andrew Rosenblum All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. Neither the name of the nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "AJRNutritionViewController.h"
#import "AJRNutritionLabelView.h"
#import "AJRBackgroundDimmer.h"
#import "AJRNutritionLabelCalculation.h"

@interface AJRNutritionViewController () {
    IBOutlet AJRNutritionLabelView *backgroundView;
    AJRBackgroundDimmer *backgroundGradientView;
    
    __weak IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *servingLabel;
    IBOutlet UILabel *caloriesLabel;
    IBOutlet UILabel *fatLabel;
    IBOutlet UILabel *saturatedFatLabel;
    IBOutlet UILabel *transFatLabel;
    IBOutlet UILabel *cholesterolLabel;

    IBOutlet UILabel *sodiumLabel;

    IBOutlet UILabel *carbsLabel;
    IBOutlet UILabel *DietaryFiberLabel;
    IBOutlet UILabel *sugarLabel;
    
    IBOutlet UILabel *proteinLabel;
    
    IBOutlet UILabel *fatDailyValueLabel;
    IBOutlet UILabel *satfatDailyValueLabel;
    IBOutlet UILabel *cholesterolDailyValueLabel;
    IBOutlet UILabel *sodiumDailyValueLabel;
    IBOutlet UILabel *carbDailyValueLabel;
    IBOutlet UILabel *dietaryFiberDailyValueLabel;
    IBOutlet UILabel *proteinDailyValueLabel;



}


@end

@implementation AJRNutritionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"AJRNutritionViewController" bundle:nibBundleOrNil];
    if (self) {
        self.shouldDimBackground = YES;
        self.shouldAnimateOnAppear = YES;
        self.shouldAnimateOnDisappear = YES;
        self.allowSwipeToDismiss = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Sets up the background of the nutrition view
    backgroundView.layer.cornerRadius = 10.0f;
    backgroundView.layer.masksToBounds = YES;
    backgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
    backgroundView.layer.borderWidth = 4.5f;
    
    //Sets the labels
    servingLabel.text =  self.servingSize;
    caloriesLabel.text = [NSString stringWithFormat:@"%i", self.calories];
    fatLabel.text = [NSString stringWithFormat:@"%.1fg", self.fat];
    saturatedFatLabel.text = [NSString stringWithFormat:@"%.01fg", self.satfat];
    transFatLabel.text = [NSString stringWithFormat:@"%.1fg", self.transfat];
    cholesterolLabel.text = [NSString stringWithFormat:@"%.1fmg", self.cholesterol];
    sodiumLabel.text = [NSString stringWithFormat:@"%.01fmg", self.sodium];
    carbsLabel.text = [NSString stringWithFormat:@"%.01fg", self.carbs];
    DietaryFiberLabel.text = [NSString stringWithFormat:@"%.01fg", self.dietaryfiber];
    sugarLabel.text = [NSString stringWithFormat:@"%.01fg", self.sugar];
    proteinLabel.text = [NSString stringWithFormat:@"%.01fg", self.protein];
    
    //Calculates the % daily value for the appropiate fields
    fatDailyValueLabel.text = [AJRNutritionLabelCalculation calculateFatDailyValue:[self fat]];
    satfatDailyValueLabel.text = [AJRNutritionLabelCalculation calculateSaturatedFatDailyValue:[self satfat]];
    cholesterolDailyValueLabel.text = [AJRNutritionLabelCalculation calculateCholesterolDailyValue:[self cholesterol]];
    sodiumDailyValueLabel.text = [AJRNutritionLabelCalculation calculateSodiumDailyValue:[self sodium]];
    carbDailyValueLabel.text = [AJRNutritionLabelCalculation calculateTotalCarbDailyValue:[self carbs]];
    dietaryFiberDailyValueLabel.text = [AJRNutritionLabelCalculation calculateDietaryFiberDailyValue:[self dietaryfiber]];



    carbDailyValueLabel.text =  [AJRNutritionLabelCalculation calculateTotalCarbDailyValue:[self carbs]];
    
    titleLabel.text = self.dishTitle;
    
    if (self.allowSwipeToDismiss) {
        //Add a swipe gesture recognizer to dismiss the view 
        UISwipeGestureRecognizer *downwardGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDownwards)];
        [downwardGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
        
        UISwipeGestureRecognizer *upwardGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissUpwards)];
        [upwardGestureRecognizer  setDirection:(UISwipeGestureRecognizerDirectionUp)];
        
        UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissLeftward)];
        [leftGestureRecognizer  setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        
        UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissRightward)];
        [rightGestureRecognizer  setDirection:(UISwipeGestureRecognizerDirectionRight)];



        
        [self.view addGestureRecognizer:downwardGestureRecognizer];
        [self.view addGestureRecognizer:upwardGestureRecognizer];
        [self.view addGestureRecognizer:leftGestureRecognizer];
        [self.view addGestureRecognizer:rightGestureRecognizer];
    }
}

- (void)presentInParentViewController:(UIViewController *)parentViewController {
    //Presents the view in the parent view controller
    
    if (self.shouldDimBackground == YES) {
        //Dims the background, unless overridden
        backgroundGradientView = [[AJRBackgroundDimmer alloc] initWithFrame:parentViewController.view.bounds];
        [parentViewController.view addSubview:backgroundGradientView];
    }
    
    //Adds the nutrition view to the parent view, as a child
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
    
    
    //Adds the bounce animation on appear unless overridden
    if (!self.shouldAnimateOnAppear)
        return;
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.duration = 0.4;
    bounceAnimation.delegate = self;
    
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.7f],
                              [NSNumber numberWithFloat:1.2f],
                              [NSNumber numberWithFloat:0.9f],
                              [NSNumber numberWithFloat:1.0f],
                              nil];
    
    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0f],
                                [NSNumber numberWithFloat:0.334f],
                                [NSNumber numberWithFloat:0.666f],
                                [NSNumber numberWithFloat:1.0f],
                                nil];
    
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                       nil];
    
    [self.view.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    fadeAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    fadeAnimation.duration = 0.1;
    [backgroundGradientView.layer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self didMoveToParentViewController:self.parentViewController];
}

- (void)dismissDownwards {
    [self dismissFromParentViewControllerDownwards:YES];
}

- (void)dismissUpwards {
    [self dismissFromParentViewControllerDownwards:NO];
}

- (void)dismissRightward {
    DLog(@"dismissright");
    [self dismissFromParentViewControllerRightwards:YES];
}

- (void)dismissLeftward {
    DLog(@"dismissleft");

    [self dismissFromParentViewControllerRightwards:NO];
}

- (IBAction)close:(id)sender {
    //The close button
    [self dismissFromParentViewControllerDownwards:YES];
}

- (void)dismissFromParentViewControllerDownwards:(BOOL)downwards
{
    //Removes the nutrition view from the superview
    
    
    [self willMoveToParentViewController:nil];
    
    //Removes the view with or without animation
    if (!self.shouldAnimateOnDisappear) {
        [self.view removeFromSuperview];
        [backgroundGradientView removeFromSuperview];
        [self removeFromParentViewController];
        return;
    }
    else {
        [UIView animateWithDuration:0.4 animations:^ {
            CGRect rect = self.view.bounds;
            if (downwards) {
                rect.origin.y += rect.size.height;
            } else
                rect.origin.y -= rect.size.height;

            self.view.frame = rect;
            backgroundGradientView.alpha = 0.0f;
        }
                         completion:^(BOOL finished) {
                             [self.view removeFromSuperview];
                             [backgroundGradientView removeFromSuperview];
                             [self removeFromParentViewController];
                         }];
    }
}

- (void)dismissFromParentViewControllerRightwards:(BOOL)rightwards
{
    [self willMoveToParentViewController:nil];
    
    //Removes the view with or without animation
    if (!self.shouldAnimateOnDisappear) {
        [self.view removeFromSuperview];
        [backgroundGradientView removeFromSuperview];
        [self removeFromParentViewController];
        return;
    } else {
        [UIView animateWithDuration:0.4
                         animations:^{
                             CGRect rect = self.view.bounds;
                             CGAffineTransform transform;
                             if (rightwards) {
                                 rect.origin.x += rect.size.width;
                              transform = CGAffineTransformMakeRotation(-30);
                             }  else {
                                 rect.origin.x -= rect.size.width;
                                 transform = CGAffineTransformMakeRotation(30);
                             }
                             self.view.frame = rect;
                             self.view.transform = transform;
                             backgroundGradientView.alpha = 0.0f;
                             
                         } completion:^(BOOL finished) {
                             [self.view removeFromSuperview];
                             [backgroundGradientView removeFromSuperview];
                             [self removeFromParentViewController];
                         }];
    }
    
}


- (void)viewDidUnload {
    saturatedFatLabel = nil;
    [super viewDidUnload];
    self->backgroundView = nil;
    self->carbDailyValueLabel = nil;
    self->fatDailyValueLabel = nil;
    NSLog(@"view did unload");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
