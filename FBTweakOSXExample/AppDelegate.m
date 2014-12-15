//
//  AppDelegate.m
//  FBTweakOSXExample
//
//  Created by Paulo Andrade on 14/12/14.
//  Copyright (c) 2014 Facebook. All rights reserved.
//

#import "AppDelegate.h"
#import <FBTweakOSX/FBTweak.h>
#import <FBTweakOSX/FBTweakInline.h>
#import <FBTweakOSX/FBTweakEditorViewController.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *label;

@property (strong) NSWindowController *tweaksWindowController;

@end

@implementation AppDelegate {
    _FBTweakBindObserver *_observer;
}

FBTweakAction(@"Actions", @"Global", @"Hello", ^{

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Hello";
    alert.informativeText = @"Global alert test.";
    [alert runModal];
});


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    FBTweakAction(@"Actions", @"Scoped", @"One", ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Hello";
        alert.informativeText = @"Scoped alert test #1.";
        [alert runModal];
    });
    
    FBTweakValue(@"Window", @"Teste", @"Bu", (NSInteger)1);
    self.window.backgroundColor = [NSColor colorWithRed:FBTweakValue(@"Window", @"Color", @"Red", 0.9, 0.0, 1.0)
                                                               green:FBTweakValue(@"Window", @"Color", @"Green", 0.9, 0.0, 1.0)
                                                                blue:FBTweakValue(@"Window", @"Color", @"Blue", 0.9, 0.0, 1.0)
                                                               alpha:1.0];
    
    FBTweakBind(_label, stringValue, @"Content", @"Label", @"String", @"Tweaks");
    FBTweakBind(_label, alphaValue, @"Content", @"Label", @"Alpha", 0.5, 0.0, 1.0);
    _label.backgroundColor = [NSColor whiteColor];
    FBTweakBind(_label, drawsBackground, @"Content", @"Label", @"Background", NO);
    
    FBTweakAction(@"Actions", @"Scoped", @"Two", ^{
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Hello";
        alert.informativeText = @"Scoped alert test #2.";
        [alert runModal];
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)openTweakWindow:(id)sender {
    if (self.tweaksWindowController == nil) {
        FBTweakEditorViewController *editor = [[FBTweakEditorViewController alloc] init];
        NSWindow *window = [NSWindow windowWithContentViewController:editor];
        self.tweaksWindowController = [[NSWindowController alloc] initWithWindow:window];
    }
    
    [self.tweaksWindowController showWindow:self];
}

@end
