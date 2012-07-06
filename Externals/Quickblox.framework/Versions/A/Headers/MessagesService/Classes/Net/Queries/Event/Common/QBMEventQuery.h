//
//  QBMEventQuery.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QBMEventQuery : QBMessagesServiceQuery {
	QBMEvent *event;
}
@property (nonatomic,retain) QBMEvent *event;

- (id)initWithEvent:(QBMEvent *)event;

@end
