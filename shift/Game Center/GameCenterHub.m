//
//  GameCenterHub.m
//  shift
//
//  Created by Alex Chesebro on 2/20/12.
//  Copyright (c) 2012 __Oh_Shift__. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "GKAchievementNotification/GKAchievementHandler.h"
#import "MultiplayerTypeMenu.h"
#import "MultiplayerGame.h"
#import "GameCenterHub.h"
#import "MainMenu.h"
#import "cocos2d.h"

@implementation GameCenterHub

@synthesize achievementDict;
@synthesize notificationCenter;
@synthesize rootViewController;
@synthesize gameCenterAvailable;
@synthesize userAuthenticated;
@synthesize currentMatch;
@synthesize unsentScores;


// Singleton accessor method for the GameCenterHub
//
+(GameCenterHub*) sharedHub
{
  static GameCenterHub* sharedHub = nil;

  if (sharedHub != nil)
    return sharedHub;
  
  @synchronized(self)
  {
    sharedHub = [[GameCenterHub alloc] init];
  }
  return sharedHub;
}

// Default initialization method for GameCenterHub
//
-(id) init
{
  if ((self = [super init]))
  {
    userAuthenticated = NO;
    gameCenterAvailable = [self isGameCenterAvailable];
    NSLog(@"GameCenter: %@", gameCenterAvailable ? @"Available" : @"Unavailable");
    achievementDict = [NSMutableDictionary dictionaryWithCapacity:25];
    unsentScores = [NSMutableDictionary dictionaryWithCapacity:25];
    
    if (gameCenterAvailable)
    {
      notificationCenter = [NSNotificationCenter defaultCenter];
      [notificationCenter addObserver:self 
                             selector:@selector(authenticationChanged) 
                                 name:GKPlayerAuthenticationDidChangeNotificationName 
                               object:nil];
    }
  }
  return self;
}

/*
 ********** User Account Functions **********
 */

// Authenticates the local player with Game Center
//
-(void) authenticateLocalPlayer
{
  [self loadAchievements];
  if (!gameCenterAvailable) 
    return;

  // Setup event handler
  void (^setGKEventHandlerDelegate)(NSError *) = ^ (NSError* error)
  {
    GKTurnBasedEventHandler *ev = [GKTurnBasedEventHandler sharedTurnBasedEventHandler];
    ev.delegate = self;
  };

  // Authenticate local player and setup GKEventHandlerDelegate
  if(![GKLocalPlayer localPlayer].isAuthenticated)
  {
    [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:setGKEventHandlerDelegate];
    [self getPlayerFriends];
    NSLog(@"Authenticated user");
  }
  else
  {
    NSLog(@"Already authenticated");
    setGKEventHandlerDelegate(nil);
  }
}

// Handles any events where a players authentication changes
//
-(void) authenticationChanged 
{
  [self loadAchievements];
  if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated)
  {
    NSLog(@"Auth changed; player authenticated.");
    userAuthenticated = YES;
    [self loadAchievements];
  }
  else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated)
  {
    NSLog(@"Auth changed; player not authenticated.");
    userAuthenticated = NO;
  }
}

// Retreives the local player's friends
//
-(void) getPlayerFriends
{
  GKLocalPlayer* me = [GKLocalPlayer localPlayer];
  
  if (me.isAuthenticated)
  {
    [me loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error) 
    {
      if (error != nil)
      {
        NSLog(@"getPlayerFriendsError: %@", error.description);
        return;
      }
      if (![friends count])
      {
        [self loadPlayerData:friends];
      }
    }];
  }
}

// Processes GKPlayer data into a form that the GCHub can utilize
//
-(void) loadPlayerData:(NSArray*) identifiers
{
  NSLog(@"You have this many friends: %@", [identifiers count]); 
  [GKPlayer loadPlayersForIdentifiers:identifiers 
                withCompletionHandler:^(NSArray* players, NSError* error) 
   {
     if (error != nil)
     {
       NSLog(@"loadPlayerData error: %@", error.description);
     }
     if (players != nil)
     {
       // TODO: Process the array of GKPlayer objects.
     }
   }];
}


// Allows a player to invite a new person to be their friend.
//
-(void) inviteFriends: (NSArray*) identifiers
{
  GKFriendRequestComposeViewController* friendRequestVc = [[GKFriendRequestComposeViewController alloc] init];
  friendRequestVc.composeViewDelegate = self;
  if (identifiers)
  {
    [friendRequestVc addRecipientsWithPlayerIDs: identifiers];
  }
  
  [rootViewController presentModalViewController: friendRequestVc animated: YES];
}

// Callback method for the FriendRequestViewController for when the view controller is closed
//
-(void)friendRequestComposeViewControllerDidFinish:(GKFriendRequestComposeViewController*)viewController
{
  [rootViewController dismissModalViewControllerAnimated:YES];
}


/*
 ********** Achievement Functions **********
 */

// Displays the GKAchievementViewController on the screen
//
-(void) showAchievements
{
  if (![GameCenterHub sharedHub].gameCenterAvailable || ![GameCenterHub sharedHub].userAuthenticated)
  {
    [[GameCenterHub sharedHub] displayGameCenterNotification:@"Must be logged into GameCenter to use this"];
    return;
  }
  
  GKAchievementViewController* achievements = [[GKAchievementViewController alloc] init];
  if (achievements != nil)
  {
    achievements.achievementDelegate = self;
    [rootViewController presentModalViewController: achievements animated: YES];
  }
}

// Callback method for the GKAchievementViewController for when the view controller is closed 
//
-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewController 
{
  [rootViewController dismissModalViewControllerAnimated:YES];
}

// Loads local cache of achievements and also the GameCenter's cache of achievements.
// Handles any differences between the two and updates both copies
//
-(void) loadAchievements
{  
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString* documentsDirectory = [paths objectAtIndex:0];
  NSString* filePath = [documentsDirectory stringByAppendingPathComponent:@"local_achievements"];  
  achievementDict = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];  
  
  if (![GKLocalPlayer localPlayer].isAuthenticated) return;
  
  [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* achievements, NSError* error) 
  {
     if (error != nil)
     {
       NSLog(@"loadAchievements error: %@", error.description);
     }
     if (achievements != nil)
     {
       for (GKAchievement* achievement in achievements)
       {
         GKAchievement* local = [self addOrFindIdentifier:achievement.identifier];
         
         if (achievement.percentComplete > local.percentComplete)
         {
           local.percentComplete = achievement.percentComplete;
           [self saveAchievements];
         }
       }
     }
  }];
}

// Test for an existing achievement identifier in the achievement dictionary
// if not found, then allocates a spot for it
//
-(GKAchievement*) addOrFindIdentifier:(NSString*)identifier
{
  GKAchievement* achievement = [achievementDict objectForKey:identifier];
  
  if (achievement == nil)
  {
    achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    [achievementDict setObject:achievement forKey:identifier];
  }
  
  return achievement;
}

// Wrapper method for when an achievement is completed by the player.
// 
-(void) achievementCompleted:(NSString *)title message:(NSString*) msg
{
  [[GKAchievementHandler defaultHandler] notifyAchievementTitle:title andMessage:msg];
}

// Sends data to Game Center about the achievement's completetion progress
//
-(void) reportAchievementIdentifier:(NSString*)identifier percentComplete:(float)percent
{
  GKAchievement* achievement = [self addOrFindIdentifier:identifier];
  achievement.percentComplete = percent;
  [achievement reportAchievementWithCompletionHandler:^(NSError* error)
  {
    if (error != nil)
    {
      NSLog(@"reportAchievementID error: %@", error.description);
    }
  }];
  [self saveAchievements];
}

// Resets all achievements to 0% progress for the local player
//
- (void) resetAchievements
{
  if (![GameCenterHub sharedHub].gameCenterAvailable || ![GameCenterHub sharedHub].userAuthenticated)
  {
    [[GameCenterHub sharedHub] displayGameCenterNotification:@"Must be logged into GameCenter to use this"];
    return;
  }
  
  // TODO:  Confirm reset
  achievementDict = [[NSMutableDictionary alloc] init];
  [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
  {
     if (error != nil) 
     {	
       NSLog(@"ResetAchievements: %@", error.description);
     }
  }];
}

// Writes all of the achievement dictionary cache to file for localized cache of achievements
//
- (void) saveAchievements
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *achievementPath = [documentsDirectory stringByAppendingPathComponent:@"local_achievements"];
  [NSKeyedArchiver archiveRootObject:achievementDict toFile:achievementPath];
}


/*
 ********** Leaderboard Functions **********
 */

// Displays the GKLeaderboardViewController on the main screen
//
-(void) showLeaderboard:(NSString*) category
{
  if (![GameCenterHub sharedHub].gameCenterAvailable || ![GameCenterHub sharedHub].userAuthenticated)
  {
    [[GameCenterHub sharedHub] displayGameCenterNotification:@"Must be logged into GameCenter to use this"];
    return;
  }
    
  GKLeaderboardViewController* leaderboardVc = [[GKLeaderboardViewController alloc] init];
  if (leaderboardVc != nil)
  {
    leaderboardVc.leaderboardDelegate = self;
    leaderboardVc.category = category;
    leaderboardVc.timeScope = GKLeaderboardTimeScopeAllTime;
    
    [rootViewController presentModalViewController:leaderboardVc animated:YES];
  }
}

// Callback method for the ViewController for when it closes
//
-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
  [rootViewController dismissModalViewControllerAnimated:YES];
}

// Submits a player score to Game Center to be displayed on the leaderboard
// If Game Center is not available or connection is lost, then the score is written
// to file to be sent later
//
-(void) submitScore:(int64_t)score category:(NSString *)category
{
  if (!gameCenterAvailable || ![GKLocalPlayer localPlayer].isAuthenticated) 
  {
      // Process unsent scores
  }
  else 
  {
    GKScore* myScore = [[GKScore alloc] init];
    myScore.value = score;
    [myScore reportScoreWithCompletionHandler:^(NSError* error)
     {
       NSLog(@"submitScore error: %@", error.description);
     }];  
  }
}

// Writes the unsent scores to file
//
-(void) saveUnsentScores
{
  NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString* documentsDirectory = [paths objectAtIndex:0];
  NSString* scorePath = [documentsDirectory stringByAppendingPathComponent:@"unsent_scores"];
  [NSKeyedArchiver archiveRootObject:unsentScores toFile:scorePath];
}


/*
 ********** Matchmaking functions **********
 */

// Displays the GKTurnBasedMatchmaker on the main screen 
-(void) showMatchmaker
{
  if (![GameCenterHub sharedHub].gameCenterAvailable || ![GameCenterHub sharedHub].userAuthenticated)
  {
    [[GameCenterHub sharedHub] displayGameCenterNotification:@"Must be logged into GameCenter to use this"];
    return;
  }
  
  matchStarted = NO;
  [rootViewController dismissModalViewControllerAnimated:NO];
  
  GKMatchRequest* request = [[GKMatchRequest alloc] init];
  request.minPlayers = 2;
  request.maxPlayers = 2;
  
  GKTurnBasedMatchmakerViewController* matchmakerVc = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
  matchmakerVc.turnBasedMatchmakerDelegate = self;
  
  [rootViewController presentModalViewController:matchmakerVc animated:YES];
}

// Clears the GKTurnBasedMatchmaker of all matches, no matter what the status is
//
-(void) clearMatches
{
  if (![GameCenterHub sharedHub].gameCenterAvailable || ![GameCenterHub sharedHub].userAuthenticated)
  {
    [[GameCenterHub sharedHub] displayGameCenterNotification:@"Must be logged into GameCenter to use this"];
    return;
  }
  
  if ([GKLocalPlayer localPlayer].authenticated)
  {
    [GKTurnBasedMatch loadMatchesWithCompletionHandler:^(NSArray *matches, NSError *error)
     {
       for (GKTurnBasedMatch *match in matches) 
       { 
         NSLog(@"%@", match.matchID); 
         [match removeWithCompletionHandler:^(NSError *error)
          {
            NSLog(@"%@", error);
          }]; 
       }
     }];
  }
}


// Called when a player enters a new game
//
-(void) enterNewGame:(GKTurnBasedMatch*)match 
{
  NSLog(@"Entering a new game");
  [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[MultiplayerTypeMenu sceneWithMatch:match]]];
}


// Displays the board of the match
//
-(void) layoutMatch:(GKTurnBasedMatch*)match
{
  if (match.status != GKTurnBasedMatchStatusMatching)
  {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[MultiplayerGame gameWithMatchData:match]]];
  }
  else
  {
    [self waitForAnotherPlayer:match];
  }
  // TO STOP MOVEMENTS, Board.isTouchEnabled
  // TODO:  Implement method, show current match board
}


// Notifies the player that they need to wait for another player and goes back to the matchmaker screen
//
-(void) waitForAnotherPlayer:(GKTurnBasedMatch *)match
{
  [self displayGameCenterNotification:@"Waiting for another player to join the match"];
  [self showMatchmaker];
  NSLog(@"Waiting for another player");
}


// Sends data to the other player and ends your turn
//
-(IBAction)sendTurn:(id)sender data:(NSData*)data
{
  GKTurnBasedMatch* match =  self.currentMatch;
  NSUInteger currentIndex = [currentMatch.participants indexOfObject:match.currentParticipant];
  GKTurnBasedParticipant* nextParticipant = [match.participants objectAtIndex:((currentIndex + 1) % [currentMatch.participants count])];
  [currentMatch endTurnWithNextParticipant:nextParticipant 
                                 matchData:data 
                         completionHandler:^(NSError *error) 
  {
    if (error) 
    {
      NSLog(@"SendDataError: %@", error);
    }
  }];
  [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[MainMenu scene]]];
}


// End of game has been received from the other player so the game
// needs to display the end game results
//
-(void) displayResults:(GKTurnBasedMatch*)match
{
  
}


// Gives player a notice when turns have changed and it is their turn
//
-(void) sendNotice:(NSString*)notice forMatch:(GKTurnBasedMatch*)match
{
  UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Your turn in another game" message:notice delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
  [av show];
}


/**
 ********** TurnBasedMatch Functions **********
 */

// Called when user selects a match from the list of matches in GKMatchmakerViewController
//
-(void) turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)myMatch 
{
  NSLog(@"didFindMatch");
  [rootViewController dismissModalViewControllerAnimated:YES];
  self.currentMatch = myMatch;
  GKTurnBasedParticipant* firstParticipant = [myMatch.participants objectAtIndex:0];
  
  // Someone has had a turn already
  if (firstParticipant.lastTurnDate)
  {
    // Your turn
    if ([myMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) 
    {
      [self layoutMatch:myMatch];
    } 
    // Other person's turn
    else 
    {
      [self layoutMatch:myMatch];
    }     
  } 
  // Nobody is in the game yet
  else 
  {
    [self waitForAnotherPlayer:myMatch];
  }
}


// Called when user hits cancel button in the GKTurnBasedMatchmakerViewController
//
-(void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController 
{
  NSLog(@"viewControllerWasCanceled");
  [rootViewController dismissModalViewControllerAnimated:YES];
}

// Called when there is an error in the GKTurnBasedMatchmakerViewController
// EX:  Connection lost
//
-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController 
                        didFailWithError:(NSError *)error 
{
  NSLog(@"didFailWithError");
  [rootViewController dismissModalViewControllerAnimated:YES];
  NSLog(@"Error finding match: %@", error.localizedDescription);
}

// Called when a player removes or just quits a match
//
-(void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)myMatch 
{
  NSLog(@"playerQuitForMatch");
  NSUInteger currentIndex = [myMatch.participants indexOfObject:myMatch.currentParticipant];
  GKTurnBasedParticipant* part;
  
  for (int i = 0; i < [myMatch.participants count]; i++) {
    part = [myMatch.participants objectAtIndex:(currentIndex + 1 + i) % myMatch.participants.count];
    if (part.matchOutcome != GKTurnBasedMatchOutcomeQuit) 
    {
      break;
    } 
  }
  NSLog(@"playerquitforMatch, %@, %@", myMatch, myMatch.currentParticipant);
  [myMatch participantQuitInTurnWithOutcome: GKTurnBasedMatchOutcomeQuit 
                            nextParticipant:part 
                                  matchData:myMatch.matchData 
                          completionHandler:nil];
}


/**
 ********** Event Handler Functions **********
 */

// Handles any invitations received from GameCenter for match requests
//
-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite 
{
  [rootViewController dismissModalViewControllerAnimated:YES];
  GKMatchRequest* request = [[GKMatchRequest alloc] init]; 
  request.playersToInvite = playersToInvite;
  request.maxPlayers = 2;
  request.minPlayers = 2;
  
  GKTurnBasedMatchmakerViewController* viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
  viewController.showExistingMatches = NO;
  viewController.turnBasedMatchmakerDelegate = self;
  [rootViewController presentModalViewController:viewController animated:YES];
}


// Handles any Turn changed events from Game Center
//
-(void)handleTurnEventForMatch:(GKTurnBasedMatch*)myMatch 
{
    NSLog(@"Turn has happened");
    if ([myMatch.matchID isEqualToString:currentMatch.matchID]) 
    {
      if ([myMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) 
      {
        // Current game, your turn
        self.currentMatch = myMatch;
        [self sendNotice:@"It's your turn for another match" forMatch:myMatch];
      } 
      else 
      {
        // Current game, not your turn
        self.currentMatch = myMatch;
        [self sendNotice:@"It's your turn for another match" forMatch:myMatch];
      }
    } 
    else 
    {
      if ([myMatch.currentParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) 
      {
        // Other game, your turn
        [self sendNotice:@"It's your turn for another match" forMatch:myMatch];
      } 
    }
}


// Handles the match end event from Game Center 
//
-(void)handleMatchEnded:(GKTurnBasedMatch*)myMatch 
{
  NSLog(@"This game is over");
  if ([myMatch.matchID isEqualToString:currentMatch.matchID]) 
  {
    [self displayResults:myMatch];
  } 
  else 
  {
    [self sendNotice:@"A different game has ended" forMatch:myMatch];
  }
}


/*
 ********** Helper Functions **********
 */

// Checks to see if the iOS version is sufficient and GameCenter is present
//
-(BOOL) isGameCenterAvailable
{
  BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
  NSString* reqSysVer = @"4.1";
  NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
  BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
  return (localPlayerClassAvailable && osVersionSupported);
}

// Displays a notification to the player
//
-(void) displayGameCenterNotification:(NSString*) message
{
  [[[UIAlertView alloc] initWithTitle:@"GameCenter" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

@end
