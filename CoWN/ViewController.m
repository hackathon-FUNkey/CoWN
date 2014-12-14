//
//  ViewController.m
//  CoWN
//
//  Created by Kudo Takuya on 2014/12/13.
//  Copyright (c) 2014年 Kudo Takuya. All rights reserved.
//

#import "ViewController.h"
#include "SocketIOPacket.h"

@implementation ViewController
@synthesize  urlfield,mywebview,chatroom,message;


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"aa");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(applicationWillResignActive)
               name:@"applicationWillResignActive"
             object:nil];
    [nc addObserver:self
           selector:@selector(applicationDidBecomeActive)
               name:@"applicationDidBecomeActive"
             object:nil];
    chati =0;
    // Do any additional setup after loading the view.
    NSString*	urlStr;
    urlStr = @"http://www.yahoo.co.jp/";
    NSURL* url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [[mywebview mainFrame]loadRequest:request];
    // URL を設定します
    [urlfield setStringValue:urlStr];
    [mywebview setFrameLoadDelegate:self];
   
     mouseImage = [[NSImageView alloc] init];
    //分かりやすく背景追加
    x=200;
    y=200;
    mouseImage.frame = CGRectMake((float)x, (float)y, 100, 100);
    mouseImage.image = [NSImage imageNamed:@"mouse.png"];
    [self.view addSubview:mouseImage];
    
    //self.datas = [NSMutableArray array];
    self.socketIO = [[SocketIO alloc] initWithDelegate:self];
    
//    
//    
    [self performSelector:@selector(myFunc) withObject:nil afterDelay:0.01];

}

- (void)applicationDidBecomeActive
{
    // localhost:3000に接続開始
    [self.socketIO connectToHost:@"192.168.1.8" onPort:3001];
}

- (void)applicationWillResignActive
{
    // 接続終了
    [self.socketIO disconnect];
}

- (void)socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"seiko");

}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"sippai");

}

- (void)myFunc{
    CGEventRef event = CGEventCreate(NULL);
    CGPoint location = CGEventGetLocation(event);
    NSPoint point;
      point = [NSEvent mouseLocation];
        int currentPosition = [[[self mywebview]stringByEvaluatingJavaScriptFromString:@"window.scrollY;"] intValue];
    int ScreenY = [[[self mywebview]stringByEvaluatingJavaScriptFromString:@" window.screenY;"] intValue];
    //NSLog(@"x座標:%f,y座標:%f",location.x,location.y+(float)currentPosition-(float)ScreenY-74.0);
    //[self.socketIO sendEvent:@"point" withData:@{@"x":(float)location.x,"y":location.y+(float)currentPosition-(float)ScreenY-74.0}];
    NSString *str_x = [NSString stringWithFormat:@"%f", location.x];
    NSString *str_y = [NSString stringWithFormat:@"%f", point.y+(float)currentPosition-(float)ScreenY-74.0];
    [self.socketIO sendEvent:@"point" withData:@{@"x":str_x,@"y":str_y}];
    [self performSelector:@selector(myFunc) withObject:nil afterDelay:0.01];
//    x=x+5;
//    y=y+5;
//    mouseImage.frame = CGRectMake((float)x, (float)y, 100, 100);
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
    if (command == @selector(insertNewlineIgnoringFieldEditor:)) {
        // Returnを入力すると、この分岐に入る
        return YES;
    } else {
        [self.socketIO sendEvent:@"message" withData:@{@"message":[message stringValue]}];
        return NO;
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)windowControllerDidLoadNib:(NSWindowController*)windowController
{
    // WebView のデリゲートを設定します
    [mywebview setFrameLoadDelegate:self];
}


- (void)webView:(WebView *)sender
didFinishLoadForFrame:(WebFrame *)frame{
    NSString* url = [mywebview stringByEvaluatingJavaScriptFromString:@"document.URL"];
    [urlfield setStringValue:url];
    NSLog(@"%@", url);
    [self.socketIO sendEvent:@"address" withData:@{@"address":url}];
    NSLog(@"ok");
    [chatroom setStringValue:@""];
    chati = 0;
}


- (IBAction)sendButton:(id)sender {
    [self.socketIO sendEvent:@"message" withData:@{@"message":[message stringValue]}];

 
 //   [self.socketIO sendEvent:@"message" withData:@{@"message" : self.formCell.textField.text}];
    
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if ([packet.name isEqualToString:@"otherMessage"]) {
        NSString* chat = [chatroom stringValue];
        if(chati!=0){
            chat =[chat stringByAppendingString:@"\n"];
        }
        chat =[chat stringByAppendingString:packet.args[0][@"message"]];
        
        chati++;
        [chatroom setStringValue:chat];
        NSLog(@"%@", [message stringValue]);
        [message setStringValue:@""];
    }
    
    if ([packet.name isEqualToString:@"otherPoints"]) {
        NSLog(@"%@", packet.args[0][@"x"]);
        int currentPosition = [[[self mywebview]stringByEvaluatingJavaScriptFromString:@"window.scrollY;"] intValue];
        int ScreenY = [[[self mywebview]stringByEvaluatingJavaScriptFromString:@" window.screenY;"] intValue];
        //float f_x = packet.args[0][@"x"].floatValue;
        float f_x = [packet.args[0][@"x"] floatValue];
        float f_y = [packet.args[0][@"y"] floatValue]-(float)currentPosition+(float)ScreenY+74.0;
        
        mouseImage.frame = CGRectMake(f_x, f_y, 100, 100);
    }
}
@end
