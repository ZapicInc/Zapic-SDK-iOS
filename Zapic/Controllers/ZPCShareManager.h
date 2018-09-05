@import UIKit;
@import MessageUI;
#import "ZPCShareMessage.h"

@interface ZPCShareManager : NSObject <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

/**
 Initialize and configure the manager with the root view controller.
 
 @param viewController The view controller that will hold the Safari view.
 @return The newly created manager.
 */
- (instancetype)initWithController:(UIViewController *)viewController;

/**
 Shows the share sheet, allowing the user to share.

 @param message Content to share
 */
- (void)share:(ZPCShareMessage *)message;

@end
