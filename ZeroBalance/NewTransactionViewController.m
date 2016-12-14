//
//  NewTransactionViewController.m
//  ZeroBalance
//
//  Created by Brad Bernard on 12/5/16.
//  Copyright © 2016 Brad Bernard. All rights reserved.
//

#import "NewTransactionViewController.h"
#import "DataController.h"
#import "PaymentMO+CoreDataClass.h"
#import "TransactionMO+CoreDataClass.h"
#import "PersonMO+CoreDataClass.h"
#import "PaymentCollectionCell.h"

@interface NewTransactionViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *moneyText;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;
@property (weak, nonatomic) IBOutlet UILabel *perPersonLabel;

@end

@implementation NewTransactionViewController

static NSString *cellIdentifier = @"PaymentCollectionCell";
static unsigned int cellHeight = 70;

static NSString *peopleText = @"People: ";
static NSString *perPersonText = @"Per person: ";

unsigned int rowTotal = 0;
unsigned int rowSaved = 0;

NSDate *date = nil;
HSDatePickerViewController *picker = nil;
NSMutableArray<PaymentMO *> *rows = nil;
NSMutableArray<PersonMO *> *people = nil;
TransactionMO *transaction = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add Transaction";
    
    date = [NSDate date];
    picker = [[HSDatePickerViewController alloc] init];
    picker.delegate = self;
    rows = [[NSMutableArray alloc] init];
    
    [self toggleHidden:true];
    
    [self navigationItems];
    [self displayDate];
}

#pragma mark - IBActions

- (IBAction)addPayeePressed:(id)sender {
    ++rowTotal;
}

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)saveTransaction:(id)sender {
    NSLog(@"Saved");
}


- (IBAction)datePressed:(id)sender {
    [self presentViewController:picker animated:YES completion:nil];
}

# pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length  == 0) {
        textField.text = @"$0.00";
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *cleanCentString = [[textField.text componentsSeparatedByCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSInteger centValue = [cleanCentString intValue];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *myNumber = [formatter numberFromString:cleanCentString];
    NSNumber *result;
    
    if (string.length > 0) {
        centValue = centValue * 10 + [string intValue];
        double intermediate = [myNumber doubleValue] * 10 +  [[formatter numberFromString:string] doubleValue];
        result = [[NSNumber alloc] initWithDouble:intermediate];
    } else {
        centValue = centValue / 10;
        double intermediate = [myNumber doubleValue]/10;
        result = [[NSNumber alloc] initWithDouble:intermediate];
    }
        
    myNumber = result;
    NSNumber *formattedValue = [[NSNumber alloc] initWithDouble:[myNumber doubleValue]/ 100.0f];
    
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    textField.text = [currencyFormatter stringFromNumber:formattedValue];
    
    return NO;
}

#pragma Mark - Void Methods

- (void)navigationItems {
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeModal:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTransaction:)];
    
    self.navigationItem.leftBarButtonItem = close;
    self.navigationItem.rightBarButtonItem = done;
}

- (void)toggleHidden:(BOOL)toggle {
    self.peopleLabel.hidden = toggle;
    self.perPersonLabel.hidden = toggle;
    self.collectionView.hidden = toggle;
}

- (void)displayDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy h:mm a";
    NSString *string = [formatter stringFromDate:date];
    
    self.dateText.text = string;
}

- (void)hsDatePickerPickedDate:(NSDate *)selectedDate {
    date = selectedDate;
    [self displayDate];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return rowCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PaymentCollectionCell *cell = (PaymentCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, cellHeight);
}

@end