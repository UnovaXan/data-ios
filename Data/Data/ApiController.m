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
    // local
//    self.url = [NSString stringWithFormat:@"http://data.vm:5000/api"];
    // ip pc test phone
//    self.url = [NSString stringWithFormat:@"http://172.18.34.78:5000/api"];
    // prod
    self.url = [NSString stringWithFormat:@"http://data-api.kevinbudain.fr/api"];

    self.location = [[NSMutableArray alloc]init];
}

- (void)setUserLoad:(NSDictionary *)dictionary {

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    Experience *experience = [[Experience alloc] initWithDictionary:dictionary[@"currentData"] error:nil];
    User *user = [[User alloc] initWithDictionary:dictionary error:nil];
    [ApiController sharedInstance].experience = experience;
    user.currentData = experience;
    [ApiController sharedInstance].user = user;
    self.nbDay = [experience.day count];
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"user"];

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

    return [NSString stringWithFormat:@"%@/files/uploads/%@?access_token=%@", self.url, self.user.id, self.user.token];

}

- (NSString *)getUrlUploadData {

    return [NSString stringWithFormat:@"%@/data/%@/save?access_token=%@", self.url, self.user.id, self.user.token];

}

- (NSString *)getUrlExperienceCreate {

    return [NSString stringWithFormat:@"%@/experience/%@/create?access_token=%@", self.url, self.user.id, self.user.token];
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

@end