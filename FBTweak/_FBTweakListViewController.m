//
//  _FBTweakListViewController.m
//  FBTweak
//
//  Created by Paulo Andrade on 14/12/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "_FBTweakListViewController.h"
#import "FBTweakCollection.h"
#import "FBTweak.h"

@interface _FBTableView : NSTableView @end
@implementation _FBTableView
- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event { return YES; }
@end

@interface _FBTweakListViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) NSTableView *tableView;

@end

@implementation _FBTweakListViewController {
    NSArray *_flattenedTweaks;
}

- (void)loadView
{
    NSView *view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:view.bounds];
    scrollView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    
    NSTableView *tableView = [[_FBTableView alloc] initWithFrame:scrollView.bounds];
    tableView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.target = self;
    tableView.doubleAction = @selector(tableViewDoubleClicked:);
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"Name"];
    column.title = column.identifier;
    column.width = 150;
    [tableView addTableColumn:column];
    column = [[NSTableColumn alloc] initWithIdentifier:@"Default Value"];
    column.title = column.identifier;
    [tableView addTableColumn:column];
    column = [[NSTableColumn alloc] initWithIdentifier:@"Current Value"];
    column.title = column.identifier;
    [tableView addTableColumn:column];
    
    scrollView.documentView = tableView;
    scrollView.autoresizesSubviews = YES;
    
    [view addSubview:scrollView];
    
    self.tableView = tableView;
    self.view = view;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self.tableView reloadData];
}

#pragma mark - Properties

- (void)setTweakCategory:(FBTweakCategory *)tweakCategory
{
    _tweakCategory = tweakCategory;
    NSArray *sortedCollections = [_tweakCategory.tweakCollections sortedArrayUsingComparator:^(FBTweakCollection *a, FBTweakCollection *b) {
        return [a.name localizedStandardCompare:b.name];
    }];
    
    NSMutableArray *array = [NSMutableArray array];
    [sortedCollections enumerateObjectsUsingBlock:^(FBTweakCollection *collection, NSUInteger idx, BOOL *stop) {
        [array addObject:collection];
        [array addObjectsFromArray:collection.tweaks];
    }];
    _flattenedTweaks = [array copy];
    
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)showFontPanel:(id)sender
{
    NSFontManager * fontManager = [NSFontManager sharedFontManager];
    [fontManager setTarget:self];

    if ( [self.tableView selectedRow] >= 0) {
        id object =  [_flattenedTweaks objectAtIndex:[self.tableView selectedRow]];
        
        if ([object isKindOfClass:[FBTweak class]]) {
            FBTweak *tweak = (FBTweak *)object;
            if ([[tweak defaultValue] isKindOfClass:[NSFont class]]) {
                [fontManager setSelectedFont:[tweak currentValue]?:[tweak defaultValue] isMultiple:NO];
            }
        }
    }

    [fontManager orderFrontFontPanel:self];
}

- (void)tableViewDoubleClicked:(id)sender
{
    if ( [self.tableView selectedRow] >= 0) {
        if ( [self.tableView selectedRow] >= 0) {
            id object =  [_flattenedTweaks objectAtIndex:[self.tableView selectedRow]];
            
            if ([object isKindOfClass:[FBTweak class]]) {
                FBTweak *tweak =  (FBTweak *)object;
                
                if ([tweak isAction]) {
                    dispatch_block_t block = tweak.defaultValue;
                    if (block != NULL) {
                        block();
                    }
                }
            }
        }
    }
}


#pragma mark - NSTableView

#pragma mark datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_flattenedTweaks count];
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = nil;
    id object = _flattenedTweaks[row];
    
    if ([object isKindOfClass:[FBTweakCollection class]]) {
        cellView = [self textCellViewWithString:[(FBTweakCollection *)object name]];
    }
    else {
        FBTweak *tweak = (FBTweak *)object;

        id defaultValue = [tweak defaultValue];
        
        if ( [tableColumn.identifier isEqualToString:@"Name"] ) {
            cellView = [self textCellViewWithString:[tweak name]];
        }
        else if ( [tableColumn.identifier isEqualToString:@"Default Value"] ){
            
            if ([defaultValue isKindOfClass:[NSString class]]) {
                cellView = [self textCellViewWithString:[tweak defaultValue]];
            }
            else if( [defaultValue isKindOfClass:[NSNumber class]] ) {
                cellView = [self textCellViewWithString:[NSNumberFormatter localizedStringFromNumber:defaultValue numberStyle:NSNumberFormatterDecimalStyle]];
            }
            else if( [tweak isAction] ){
                cellView = [self textCellViewWithString:@"Double-click to perform action"];
            }
            
        }
        else if ( [tableColumn.identifier isEqualToString:@"Current Value"] ){
            if ([defaultValue isKindOfClass:[NSString class]]) {
                cellView = [self editTextCellViewWithTweak:tweak];
            }
            else if ([defaultValue isKindOfClass:[NSNumber class]]) {
                cellView = [self editNumberCellViewWithTweak:tweak];
            }
        }
    }

    return cellView;
}

- (NSTableCellView *)textCellViewWithString:(NSString *)string
{
    NSTableCellView *cellView = [[NSTableCellView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    NSTextField *textField = [[NSTextField alloc] initWithFrame:cellView.bounds];
    textField.bordered = NO;
    textField.drawsBackground = NO;
    textField.editable = NO;
    textField.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    textField.stringValue = string ?: @"";
    
    [cellView addSubview:textField];
    cellView.textField = textField;
    
    return cellView;
}

- (NSTableCellView *)editTextCellViewWithTweak:(FBTweak *)tweak
{
    NSTableCellView *cellView = [[NSTableCellView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    NSTextField *textField = [[NSTextField alloc] initWithFrame:cellView.bounds];
    textField.bordered = YES;
    textField.editable = YES;
    textField.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    
    [textField bind:@"value" toObject:tweak withKeyPath:@"currentValue" options:nil];
    
    [cellView addSubview:textField];
    cellView.textField = textField;
    
    return cellView;
}

- (NSTableCellView *)editNumberCellViewWithTweak:(FBTweak *)tweak
{
    id value = [tweak defaultValue];
    
    NSTableCellView *cellView = [[NSTableCellView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    
    // In the 64-bit runtime, BOOL is a real boolean.
    // NSNumber doesn't always agree; compare both.
    if (strcmp([value objCType], @encode(char)) == 0 ||
        strcmp([value objCType], @encode(_Bool)) == 0) {
        // boolean
        NSButton *checkbox = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        [checkbox setButtonType:NSSwitchButton];
        [cellView addSubview:checkbox];
        [checkbox bind:@"value" toObject:tweak withKeyPath:@"currentValue" options:nil];
        
    } else {
        NSTextField *textField = [[NSTextField alloc] initWithFrame:cellView.bounds];
        textField.bordered = YES;
        textField.editable = YES;
        textField.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
        if (strcmp([value objCType], @encode(NSInteger)) == 0 ||
            strcmp([value objCType], @encode(NSUInteger)) == 0) {
            // integer
            formatter.allowsFloats = NO;
        } else {
            // real
            formatter.allowsFloats = YES;
        }
        
        if (tweak.minimumValue != nil) {
            formatter.minimum = tweak.minimumValue;
        }
        if (tweak.maximumValue != nil) {
            formatter.maximum = tweak.maximumValue;
        }
        
        textField.formatter = formatter;
        [cellView addSubview:textField];
        cellView.textField = textField;
        [textField bind:@"value" toObject:tweak withKeyPath:@"currentValue" options:nil];
    }
    return cellView;
}


#pragma mark delegate

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row
{
    return [_flattenedTweaks[row] isKindOfClass:[FBTweakCollection class]];
}



@end
