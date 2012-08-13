//
//  QBMEventAnswer.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

@interface QBMEventAnswer : QBMessagesServiceAnswer {
@protected
    QBMEvent *event;
}

@property (nonatomic,readonly) QBMEvent *event;

@end
