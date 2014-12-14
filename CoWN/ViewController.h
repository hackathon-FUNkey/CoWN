//
//  ViewController.h
//  CoWN
//
//  Created by Kudo Takuya on 2014/12/13.
//  Copyright (c) 2014年 Kudo Takuya. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SocketIO.h"

@interface ViewController : NSViewController <NSTextFieldDelegate, SocketIODelegate>{
    
    int *chati;
    int x;
    int y;
    
    NSImageView *mouseImage;
}



@property (weak) IBOutlet NSTextField *urlfield;

@property (weak) IBOutlet WebView *mywebview;

@property (weak) IBOutlet NSTextField *chatroom;

@property (weak) IBOutlet NSTextField *message;

@property (strong, nonatomic) SocketIO *socketIO;

- (IBAction)sendButton:(id)sender;

@end

