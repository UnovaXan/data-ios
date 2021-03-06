//
//  ApiController.m
//  Data
//
//  Created by kevin Budain on 09/03/2015.
//  Copyright (c) 2015 kevin Budain. All rights reserved.
//

#import "ApiController.h"
#import "Experience.h"
#import "Day.h"
#import "Data.h"
#import "AFHTTPRequestOperationManager.h"
#import "PairingViewController.h"

@implementation ApiController

+ (ApiController *)sharedInstance
{
    static ApiController *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ApiController alloc] init];
        [sharedInstance loadApi];
    });
    return sharedInstance;
}

- (void)loadApi {
    // vagrant
//    self.url = [NSString stringWithFormat:@"192.168.1.15:5000/api"];
//    self.socketUrl = [NSString stringWithFormat:@"192.168.1.15:9090"];

    // local
//    self.url = [NSString stringWithFormat:@"http://data.vm:5000/api"];    
//    self.socketUrl = [NSString stringWithFormat:@"http://data.vm:9090"];

    // mac gobelins
//    self.url = [NSString stringWithFormat:@"http://172.18.33.171:5000/api"];
//    self.socketUrl = [NSString stringWithFormat:@"http://172.18.33.171:9090"];

    // prod
    self.url = [NSString stringWithFormat:@"http://data-api.kevinbudain.fr/api"];
    self.socketUrl = [NSString stringWithFormat:@"http://178.32.221.32:9090"];

    self.location = [[NSMutableArray alloc]init];
}

- (void)setUserLoad:(NSDictionary *)dictionary {

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    Experience *experience = [[Experience alloc] initWithDictionary:dictionary[@"currentData"] error:nil];
    User *user = [[User alloc] initWithDictionary:dictionary error:nil];
    self.experience = experience;
    user.currentData = experience;
    self.user = user;
    self.nbDay = [experience.day count];
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"user"];

}

- (void)removeUser {

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    self.experience = nil;
    self.user = nil;
    self.nbDay = 0;

}

- (NSString *)getDateWithTime {

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [[NSDate alloc] init];
    NSString *dateTime = [dateFormat stringFromDate:now];

    return dateTime;

}

- (NSString *)getDate {

    NSDateFormatter *dateFormatDate = [[NSDateFormatter alloc] init];
    [dateFormatDate setDateFormat:@"yyyy-MM-dd"];
    NSDate *now = [[NSDate alloc] init];
    NSString *theDate = [dateFormatDate stringFromDate:now];

    return theDate;
}

- (NSString *)getUrlSignIn {

    return [NSString stringWithFormat:@"%@/user/login", self.url];

}

- (NSString *)getUrlSignUp {

    return [NSString stringWithFormat:@"%@/user/create", self.url];
    
}

- (NSString *)getUrlUploadImages {

    return [NSString stringWithFormat:@"%@/files/uploads/%@?access_token=%@", self.url, self.user._id, self.user.token];

}

- (NSString *)getUrlUploadData {

    return [NSString stringWithFormat:@"%@/data/%@/save?access_token=%@", self.url, self.user._id, self.user.token];

}

- (NSString *)getUrlExperienceCreate {

    return [NSString stringWithFormat:@"%@/experience/%@/create?access_token=%@", self.url, self.user._id, self.user.token];
}

- (NSString *)getUrlParringGeoloc:(NSString *)idString Token:(NSString *)tokenString {

    return [NSString stringWithFormat:@"%@/data/%@/first-geoloc?access_token=%@", self.url, idString, tokenString];

}

- (NSString *)getUrlExperienceDate {

    return [NSString stringWithFormat:@"%@/experience/%@/update-date?access_token=%@", self.url, self.user._id, self.user.token];
}

- (NSString *)getUrlUploadPodometer {

    return [NSString stringWithFormat:@"%@/data/%@/pedometer?access_token=%@", self.url, self.user._id, self.user.token];

}

- (BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (Data *)GetLastData {
    NSInteger dayCount = [[ApiController sharedInstance].experience.day count] - 1;
    Day *currentDay = [ApiController sharedInstance].experience.day[dayCount];
    NSInteger dataCount = [currentDay.data count] - 1;
    Data *currentData = currentDay.data[dataCount];
    return currentData;
}

- (int)getIndexData {
    NSInteger dayCount = [[ApiController sharedInstance].experience.day count] - 1;
    Day *currentDay = [ApiController sharedInstance].experience.day[dayCount];
    return (int)[currentDay.data count] - 1;
}

- (void)updateToken {

    if (![ApiController sharedInstance].user.deviceToken) {

        NSString *urlString = [NSString stringWithFormat:@"%@/user/update/%@/deviceToken?access_token=%@", self.url, self.user._id, self.user.token];

        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
        if([deviceToken length] == 0) {
            deviceToken = @"<75fedbaa f43d810d e308bf55 1862c25c d464de93 27b2a763 5aab8b38 0ad1fdc0>";
        }

        NSLog(@"%@", deviceToken);
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *parameters = @{
                                 @"deviceToken": deviceToken,
                                 };

        [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSDictionary *dictionary = responseObject[@"user"];
            [self setUserLoad:dictionary];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            [self performSelector:@selector(updateToken) withObject:nil afterDelay:120.0f];

        }];
    }

}

- (JFRWebSocket *)activeSocket:(UIViewController *)viewController {

    self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", self.socketUrl]] protocols:@[@"chat",@"superchat"]];

    if([viewController isKindOfClass:[PairingViewController class]]) {
        PairingViewController *currentViewController = (PairingViewController *)viewController;
        [self.socket setDelegate: currentViewController];
    }
    [self.socket connect];

    NSDictionary *dictionary = @{
                                 @"type": @"mobile",
                                 @"token": self.user.token
                                 };

    NSData* myData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];

    [self writeDataSocket:jsonString];

    return self.socket;
}

- (void)websocketDidConnect:(JFRWebSocket*)socket {
    NSLog(@"websocket is connected");
}

- (void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    NSLog(@"websocket is disconnected: %@",[error localizedDescription]);
}

- (void)writeDataSocket:(NSString *)string {

    [self.socket writeString:string];

}

@end