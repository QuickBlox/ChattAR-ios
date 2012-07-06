//
//  QBRatingsService.h
//  QuickBlox
//
//  Created by Andrey Kozlov on 4/13/11.
//  Copyright 2011 QuickBlox. All rights reserved.
//

@interface QBRatingsService : BaseService {
    
}

#pragma mark -
#pragma mark Game Mode

#pragma mark -
#pragma mark Create Game Mode

/**
 Create game mode
 
 Type of Result - QBRGameModeResult
 
 @param title Title of new game mode
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) createGameModeWithTitle:(NSString*)title 
                                      delegate:(NSObject<ActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*) createGameModeWithTitle:(NSString*)title 
                                      delegate:(NSObject<ActionStatusDelegate>*)delegate 
                                       context:(void*)context;


#pragma mark -
#pragma mark Get Game Mode with ID

/**
 Get game mode with ID
 
 Type of Result - QBRGameModeResult
 
 @param gameModeId ID of game mode
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) gameModeWithID:(NSUInteger)gameModeId
                                delegate:(NSObject<ActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*) gameModeWithID:(NSUInteger)gameModeId
                                delegate:(NSObject<ActionStatusDelegate>*)delegate 
                                 context:(void*)context;


#pragma mark -
#pragma mark Get Game Modes

/**
 Get all game modes
 
 Type of Result - QBRGameModePagedResult
 
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) gameModesWithDelegate:(NSObject<ActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*) gameModesWithDelegate:(NSObject<ActionStatusDelegate>*)delegate 
                                 context:(void*)context;


#pragma mark -
#pragma mark Update Game Mode

/**
 Update game mode
 
 Type of Result - QBRGameModeResult
 
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) updateGameMode:(QBRGameMode *)gameMode
                                delegate:(NSObject<ActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*) updateGameMode:(QBRGameMode *)gameMode
                                delegate:(NSObject<ActionStatusDelegate>*)delegate 
                                 context:(void*)context;


#pragma mark -
#pragma mark Delete Game Mode

/**
 Delete game mode
 
 Type of Result - QBRGameModeResult
 
 @param gameModeId ID of game mode
 @param delegate An object for callback, must adopt ActionStatusDelegate protocol. The delegate is not retained.  Upon finish of the request, result will be an instance of QBUUserResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable>*) deleteGameModeWithID:(NSUInteger)gameModeId
                                      delegate:(NSObject<ActionStatusDelegate>*)delegate;
+ (NSObject<Cancelable>*) deleteGameModeWithID:(NSUInteger)gameModeId
                                      delegate:(NSObject<ActionStatusDelegate>*)delegate 
                                       context:(void*)context;


#pragma mark -
#pragma mark Score


#pragma mark -
#pragma mark Create Score

+ (NSObject<Cancelable> *)createScore:(QBRScore *)score delegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)createScore:(QBRScore *)score delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

#pragma mark -
#pragma mark Update Score by ID

+ (NSObject<Cancelable> *)updateScoreByID:(QBRScore *)score delegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)updateScoreByID:(QBRScore *)score delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

#pragma mark -
#pragma mark Get Score by ID

+ (NSObject<Cancelable> *)getScoreByID:(NSUInteger)scoreId delegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)getScoreByID:(NSUInteger)scoreId delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

#pragma mark -
#pragma mark Get Top N Scores by GameModeID

+ (NSObject<Cancelable> *)getTopNByGameModeID:(QBRGetTopNByGameModeIDQuery *)query delegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)getTopNByGameModeID:(QBRGetTopNByGameModeIDQuery *)query delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

#pragma mark -
#pragma mark Get Scores for User

+ (NSObject<Cancelable> *)getScoresForUser:(QBRGetScoresForUserQuery *)query delegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)getScoresForUser:(QBRGetScoresForUserQuery *)query delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

#pragma mark -
#pragma mark Get Score by ID

+ (NSObject<Cancelable> *)deleteScoreByID:(NSUInteger)scoreId delegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteScoreByID:(NSUInteger)scoreId delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

#pragma mark -
#pragma mark Get Average Scores for Application

+ (NSObject<Cancelable> *)getAverageScoresForApplication:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)getAverageScoresForApplication:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

#pragma mark -
#pragma mark Get Average Scores by GameModeID

+ (NSObject<Cancelable> *)getAverageScoresByGameModeID:(NSUInteger)gameModeId delegate:(NSObject<ActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)getAverageScoresByGameModeID:(NSUInteger)gameModeId delegate:(NSObject<ActionStatusDelegate> *)delegate context:(void *)context;

@end
