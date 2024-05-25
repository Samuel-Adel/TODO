//
//  Task.m
//  workshop
//
//  Created by Samuel Adel on 17/04/2024.
//

#import "Task.h"

@implementation Task
- (void)encodeWithCoder:(nonnull NSCoder *)encoder {
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_desc forKey:@"desc"];
    [encoder encodeObject:_date forKey:@"date"];
    [encoder encodeObject:_status forKey:@"status"];
    [encoder encodeObject:_priority forKey:@"priority"];
}

-(id) initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        _name = [decoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        _desc = [decoder decodeObjectOfClass:[NSString class] forKey:@"desc"];
        _date = [decoder decodeObjectOfClass:[NSString class] forKey:@"date"];
        _status = [decoder decodeObjectOfClass:[NSString class] forKey:@"status"];
        _priority = [decoder decodeObjectOfClass:[NSString class] forKey:@"priority"];
    }
    return self;
}


+(BOOL)supportsSecureCoding { 
    return YES;
}
@end
