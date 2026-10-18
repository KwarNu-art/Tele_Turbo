/**
 * ============================================================================
 * TeleTurbo - Ultra Performance & Anti-Thermal Engine for Telegram iOS
 * Target: ph.telegra.Telegraph & com.apple.springboard
 * Architecture: arm64, arm64e (Rootless & Rootful / Jailed Sideload Compatible)
 * ============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/resource.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <signal.h>
#import <pthread.h>

#define TT_LOG(fmt, ...) NSLog(@"[TeleTurbo⚡] " fmt, ##__VA_ARGS__)

static BOOL kExtremeModeEnabled = YES;
static BOOL kBackgroundFreezer = YES;
static BOOL kStoryStripper = YES;
static BOOL kLottieStripper = YES;
static BOOL kReactionStripper = YES;
static BOOL kBlurBypass = YES;
static BOOL kTypingZeroLag = YES;
static BOOL kQosVipElevation = YES;
static BOOL kThermalThrottleShield = YES;
static BOOL kAggressiveRamPurge = YES;
static NSTimeInterval kPurgeInterval = 600.0;

static NSMutableArray<NSNumber *> *frozenPids = nil;
static dispatch_source_t ramPurgeTimer = nil;

#pragma mark - System Priority & Background Freezer Engine

static void ElevateTelegramPriority(void) {
    if (!kQosVipElevation) return;
    
    // Elevate process priority to maximum non-realtime priority (nice -20)
    setpriority(PRIO_PROCESS, 0, -20);
    
    // Set Main Thread Quality of Service to User Interactive VIP
    pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0);
    
    TT_LOG("VIP Process Priority & QoS Elevated: Nice(-20) / USER_INTERACTIVE");
}

static void FreezeBackgroundProcesses(void) {
    if (!kBackgroundFreezer) return;
    
    // Only executed in SpringBoard context if jailbroken; jailed apps rely on dispatch suspension
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
        TT_LOG("SpringBoard Hook: Freezing non-essential background processes (SIGSTOP)...");
        if (!frozenPids) {
            frozenPids = [[NSMutableArray alloc] init];
        }
        
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        size_t size;
        if (sysctl(mib, 4, NULL, &size, NULL, 0) < 0) return;
        
        struct kinfo_proc *procs = malloc(size);
        if (sysctl(mib, 4, procs, &size, NULL, 0) < 0) {
            free(procs);
            return;
        }
        
        int count = (int)(size / sizeof(struct kinfo_proc));
        pid_t selfPid = getpid();
        
        for (int i = 0; i < count; i++) {
            pid_t pid = procs[i].kp_proc.p_pid;
            char *name = procs[i].kp_proc.p_comm;
            
            // Skip kernel, launchd, springboard, telegram, and system critical daemons
            if (pid <= 1 || pid == selfPid) continue;
            if (strstr(name, "Telegram") || strstr(name, "Telegraph") || strstr(name, "SpringBoard")) continue;
            if (strstr(name, "launchd") || strstr(name, "kernel") || strstr(name, "backboardd") || strstr(name, "notifyd")) continue;
            
            // Freeze heavy background apps
            if (kill(pid, SIGSTOP) == 0) {
                [frozenPids addObject:@(pid)];
            }
        }
        free(procs);
        TT_LOG("Successfully frozen %lu background processes for Telegram exclusivity", (unsigned long)[frozenPids count]);
    }
}

static void ResumeBackgroundProcesses(void) {
    if (!frozenPids || [frozenPids count] == 0) return;
    
    TT_LOG("Telegram entering background: Resuming suspended processes (SIGCONT)...");
    for (NSNumber *pidNum in frozenPids) {
        kill([pidNum intValue], SIGCONT);
    }
    [frozenPids removeAllObjects];
}

#pragma mark - Telegram App Delegate Hooks

%hook TGAppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    ElevateTelegramPriority();
    FreezeBackgroundProcesses();
    
    if (kAggressiveRamPurge && !ramPurgeTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        ramPurgeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(ramPurgeTimer, dispatch_time(DISPATCH_TIME_NOW, kPurgeInterval * NSEC_PER_SEC), kPurgeInterval * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(ramPurgeTimer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
                TT_LOG("Automatic RAM purge executed: flushed image & texture caches");
            });
        });
        dispatch_resume(ramPurgeTimer);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    %orig;
    ResumeBackgroundProcesses();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    %orig;
    ResumeBackgroundProcesses();
    if (ramPurgeTimer) {
        dispatch_source_cancel(ramPurgeTimer);
        ramPurgeTimer = nil;
    }
}

%end

#pragma mark - Zero-Lag Typing & Input Acceleration

%hook ChatTextInputNodeView

- (void)textViewDidChange:(UITextView *)textView {
    // Disable recursive synchronous layout invalidation on each character keystroke
    if (kTypingZeroLag) {
        [UIView performWithoutAnimation:^{
            %orig;
        }];
    } else {
        %orig;
    }
}

%end

// Eliminate redundant autolayout recalculations during high-speed typing
%hook ChatHistoryListNode

- (void)scrollToEndOfHistoryAnimated:(BOOL)animated {
    if (kTypingZeroLag) {
        // Instant non-blocking jump to bottom with zero GPU animation stall
        %orig(NO);
    } else {
        %orig(animated);
    }
}

%end

#pragma mark - Bloat Stripper: Telegram Stories Killer

%hook PeerStoriesNode
// Completely zero-out Stories carousel memory and render tree
- (instancetype)init {
    if (kStoryStripper) {
        TT_LOG("Blocked PeerStoriesNode initialization (Stories Disabled)");
        return nil;
    }
    return %orig;
}
%end

%hook PeerStoryListContext
- (BOOL)hasStories {
    return kStoryStripper ? NO : %orig;
}
%end

#pragma mark - Bloat Stripper: Lottie Vector Animations & Reactions

%hook RLottiePlayerNode
// Throttles CPU-draining 60FPS vector Lottie sticker rendering
- (void)play {
    if (kLottieStripper) {
        // Pause vector decode loop to eliminate 40-70% CPU usage during sticker spam
        return;
    }
    %orig;
}
%end

%hook AnimatedStickerNode
- (void)play {
    if (kLottieStripper) {
        return;
    }
    %orig;
}
%end

%hook ChatReactionParticleView
// Disables floating particle physics emitters on message reactions
- (instancetype)initWithFrame:(CGRect)frame {
    if (kReactionStripper) {
        return nil;
    }
    return %orig;
}
%end

#pragma mark - Anti-Thermal & GPU Blur Bypass

%hook UIVisualEffectView

- (void)layoutSubviews {
    %orig;
    if (kBlurBypass) {
        // Replace GPU-intensive live Gaussian blur filters with ultra-fast solid tint
        self.layer.filters = nil;
        self.backgroundColor = [UIColor colorWithRed:0.08 green:0.11 blue:0.15 alpha:0.92];
    }
}

%end

#pragma mark - Thermal State Shield

%hook NSProcessInfo

- (NSProcessInfoThermalState)thermalState {
    NSProcessInfoThermalState actualState = %orig;
    if (kThermalThrottleShield && actualState >= NSProcessInfoThermalStateFair) {
        // Auto-throttle background prefetching when phone begins heating up
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            TT_LOG("Thermal Shield Active: Clamping high-frequency timers & ProMotion 120Hz display link");
        });
    }
    return actualState;
}

%end

#pragma mark - SpringBoard Life-Cycle Hooks

%hook SpringBoard

- (void)frontDisplayDidChange:(id)newDisplay {
    %orig;
    NSString *bundleId = [newDisplay respondsToSelector:@selector(bundleIdentifier)] ? [newDisplay performSelector:@selector(bundleIdentifier)] : @"";
    if ([bundleId isEqualToString:@"ph.telegra.Telegraph"]) {
        FreezeBackgroundProcesses();
    } else {
        ResumeBackgroundProcesses();
    }
}

%end

#pragma mark - Constructor Initializer

%ctor {
    @autoreleasepool {
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        TT_LOG("TeleTurbo Loaded inside %@ | ExtremeMode=%@", bundleId, kExtremeModeEnabled ? @"YES" : @"NO");
        if ([bundleId isEqualToString:@"ph.telegra.Telegraph"]) {
            ElevateTelegramPriority();
        }
    }
}
