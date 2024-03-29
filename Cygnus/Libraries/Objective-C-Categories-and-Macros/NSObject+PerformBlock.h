#pragma mark Class Interface

@interface NSObject (PerformBlock)


#pragma mark -
#pragma mark Instance Methods

- (void)performBlock: (dispatch_block_t)block 
	afterDelay: (NSTimeInterval)delay;

- (void)performBlockOnMainThread: (dispatch_block_t)block;
- (void)performBlockOnMainThread: (dispatch_block_t)block
                      afterDelay: (NSTimeInterval)delay;

- (void)performBlockInBackground: (dispatch_block_t)block;


@end // @interface NSObject (PerformBlock)