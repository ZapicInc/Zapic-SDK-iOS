#import "ZPCShareManager.h"

@interface ZPCShareManager ()
@property (readonly) UIViewController *viewController;
@end

@implementation ZPCShareManager

- (instancetype)initWithController:(UIViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)share:(ZPCShareMessage *)message {
    NSString *target = message.target;

    if (!target || [target isEqual:@"sheet"]) {
        NSMutableArray *objectsToShare = [NSMutableArray array];

        if (message.text) {
            [objectsToShare addObject:message.text];
        }

        if (message.image) {
            [objectsToShare addObject:message.image];
        }

        if (message.url) {
            [objectsToShare addObject:message.url];
        }

        UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

        [_viewController presentViewController:shareController animated:YES completion:nil];

    } else if ([target isEqual:@"sms"]) {
        if (![MFMessageComposeViewController canSendText]) {
            NSLog(@"Message services are not available.");
        } else {
            MFMessageComposeViewController *composeVC = [[MFMessageComposeViewController alloc] init];
            composeVC.messageComposeDelegate = self;

            composeVC.body = [NSString stringWithFormat:@"%@\r%@", message.text, message.url.absoluteString];
            composeVC.subject = message.subject;

            // Present the view controller modally.
            [_viewController presentViewController:composeVC animated:YES completion:nil];
        }
    } else if ([target isEqual:@"email"]) {
        if (![MFMailComposeViewController canSendMail]) {
            NSLog(@"Mail services are not available.");
            return;
        } else {
            MFMailComposeViewController *composeVC = [[MFMailComposeViewController alloc] init];
            composeVC.mailComposeDelegate = self;

            NSString *body = [NSString stringWithFormat:@"%@\r%@", message.text, message.url];

            [composeVC setSubject:message.subject];
            [composeVC setMessageBody:body isHTML:NO];

            // Present the view controller modally.
            [_viewController presentViewController:composeVC animated:YES completion:nil];
        }
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    // Check the result or perform other tasks.    // Dismiss the message compose view controller.
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    // Check the result or perform other tasks.

    // Dismiss the mail compose view controller.
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
