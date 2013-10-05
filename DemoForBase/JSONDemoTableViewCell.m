//
//  JSONDemoTableViewCell.m
//  DemoForBase
//
//  Created by Alex Ovod on 10/3/13.
//  Copyright (c) 2013 Alex. All rights reserved.
//

#import "JSONDemoTableViewCell.h"

@implementation JSONDemoTableViewCell

- (void) setupLables
{
    CGRect frame1 = CGRectMake(10, 10, 100, 20);
    CGRect frame2 = frame1;
    frame2.origin.x = self.frame.size.width-100;
    
    CGRect frame3 = frame1;
    frame3.origin.y += (10 + frame2.size.height);
    
    _nameLable = [[UILabel alloc] initWithFrame:frame1];
    [self addSubview:_nameLable];
    
    _ageLable = [[UILabel alloc] initWithFrame:frame2];
    [self addSubview:_ageLable];
    
    _emailLable = [[UILabel alloc] initWithFrame:frame3];
    _emailLable.textColor = [UIColor lightGrayColor];
    [self addSubview:_emailLable];
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupLables];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
