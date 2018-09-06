@import UIKit;
@import MessageUI;
#import "ZPCShareMessage.h"

@interface ZPCShareManager : NSObject <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

/**
 Shows the share sheet, allowing the user to share.

 @param message Content to share
 */
- (void)share:(ZPCShareMessage *)message;

@end
