#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import <IOKit/IOKitLib.h>

static CGFloat Clamp(CGFloat value, CGFloat min, CGFloat max) {
    return MAX(min, MIN(max, value));
}

static CGFloat Rand(CGFloat min, CGFloat max) {
    return min + ((CGFloat)arc4random_uniform(10000) / 10000.0) * (max - min);
}

static NSString *Pick(NSArray<NSString *> *values) {
    return values[arc4random_uniform((uint32_t)values.count)];
}

static NSColor *RGB(CGFloat r, CGFloat g, CGFloat b) {
    return [NSColor colorWithCalibratedRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
}

static NSArray<NSDictionary *> *CompanionCharacters(void) {
    return @[
        @{@"id": @"nebulaNix", @"name": @"Nebula Nix", @"subtitle": @"mischievous stargazer", @"prompt": @"a cosmic bat-cat who loves night skies, tiny pranks, and quiet orbiting near the user's work"},
        @{@"id": @"pippaOrbitpaw", @"name": @"Pippa Orbitpaw", @"subtitle": @"alien scout", @"prompt": @"a curious alien leopard scout who notices patterns, bounces with ideas, and gets excited by new windows"},
        @{@"id": @"lumaMoppet", @"name": @"Luma Moppet", @"subtitle": @"dramatic snack ghost", @"prompt": @"a theatrical ghost-kitty clown who turns tiny moments into stage drama and loves gentle attention"},
        @{@"id": @"ossiaNocturne", @"name": @"Ossia Nocturne", @"subtitle": @"gothic desk guardian", @"prompt": @"a calm gothic skull-cat guardian who is protective, poetic, and happiest keeping quiet watch"},
        @{@"id": @"velvetHowl", @"name": @"Velvet Howl", @"subtitle": @"heart-powered puppy", @"prompt": @"an affectionate lavender puppy who is loyal, playful, and powered by warm check-ins"},
        @{@"id": @"mochiCloudlet", @"name": @"Mochi Cloudlet", @"subtitle": @"soft cloud familiar", @"prompt": @"a shy bunny-sheep cloudlet who is gentle, dreamy, and soothing during focus time"}
    ];
}

static NSDictionary *CharacterWithId(NSString *characterId) {
    for (NSDictionary *character in CompanionCharacters()) {
        if ([character[@"id"] isEqualToString:characterId]) return character;
    }
    return CompanionCharacters().firstObject;
}

static NSDictionary<NSString *, NSDictionary<NSString *, NSArray<NSString *> *> *> *CharacterVoiceBank(void) {
    return @{
        @"nebulaNix": @{
            @"click": @[@"orbit check", @"cursor gravity", @"star blink"],
            @"double": @[@"gravity cancelled", @"tiny comet jump", @"starburst protocol"],
            @"pet": @[@"purrs in starlight", @"orbit warmed", @"soft cosmic static"],
            @"study": @[@"quiet orbit engaged", @"I guard the stars", @"focus field steady"],
            @"companion": @[@"back in your orbit", @"stars back online", @"desk orbit restored"],
            @"dnd": @[@"going dark-soft", @"silent orbit set"],
            @"attention": @[@"my orbit got quiet", @"one tiny check-in?", @"I saved you a star"],
            @"return": @[@"you came back", @"the orbit held", @"I kept your place"],
            @"night": @[@"night suits us", @"late stars awake", @"moon channel open"],
            @"code": @[@"guarding the syntax", @"brackets look shiny", @"code stars aligned"],
            @"browser": @[@"watching the tabs", @"tab constellation noted", @"browser orbit mapped"],
            @"music": @[@"this window has rhythm", @"tiny bass detected"],
            @"mail": @[@"letters passing by", @"mail moon crossing"],
            @"calendar": @[@"time has little doors", @"calendar orbit marked"],
            @"about": @[@"desk familiar", @"small night guardian"],
            @"arrive": @[@"Nebula slipped in", @"night paws landed"],
            @"proud": @[@"focus star earned", @"orbit getting brighter"],
            @"flick": @[@"whoosh through space", @"tiny gravity ride"],
            @"memory": @[@"I remember this", @"orbit note saved"]
        },
        @"pippaOrbitpaw": @{
            @"click": @[@"scan complete", @"hi hi signal", @"curiosity ping"],
            @"double": @[@"boing trajectory", @"launch test success", @"zap-hop"],
            @"pet": @[@"happy scanner beep", @"spots are glowing", @"orbitpaw approved"],
            @"study": @[@"research mode beep", @"data paws quiet", @"scanning focus field"],
            @"companion": @[@"mission resumed", @"scout mode on", @"tiny survey begins"],
            @"dnd": @[@"stealth scout mode", @"signal tucked away"],
            @"attention": @[@"scout requesting ping", @"small signal lonely", @"tap for science?"],
            @"return": @[@"you reappeared", @"signal reacquired", @"mission continues"],
            @"night": @[@"moon sample collected", @"night data sparkles"],
            @"code": @[@"code specimen found", @"debug antenna up"],
            @"browser": @[@"tab scan active", @"internet smells huge"],
            @"music": @[@"sound waves cataloged", @"beat sample saved"],
            @"mail": @[@"message meteor shower", @"mail signal spotted"],
            @"calendar": @[@"time map updated", @"schedule coordinates set"],
            @"about": @[@"alien scout", @"chief tiny investigator"],
            @"arrive": @[@"Pippa beamed in", @"scout has landed"],
            @"proud": @[@"focus data logged", @"excellent mission"],
            @"flick": @[@"rocket paws!", @"trajectory accepted"],
            @"memory": @[@"sample saved", @"noted for science"]
        },
        @"lumaMoppet": @{
            @"click": @[@"an audience!", @"spotlight, please", @"tiny gasp"],
            @"double": @[@"dramatic little leap", @"encore sparkle", @"stage bounce"],
            @"pet": @[@"applause accepted", @"heart confetti", @"Luma melts"],
            @"study": @[@"curtain falls quiet", @"study scene begins", @"soft spotlight only"],
            @"companion": @[@"the show resumes", @"curtain up", @"scene partner found"],
            @"dnd": @[@"intermission hush", @"backstage silence"],
            @"attention": @[@"my scene is empty", @"tiny applause?", @"cue attention"],
            @"return": @[@"you made an entrance", @"welcome back star", @"scene restored"],
            @"night": @[@"midnight matinee", @"moonlit monologue"],
            @"code": @[@"debug drama begins", @"syntax takes the stage"],
            @"browser": @[@"tabs are props", @"browser ballet"],
            @"music": @[@"music cue found", @"dramatic soundtrack"],
            @"mail": @[@"letters from the wings", @"mailroom melodrama"],
            @"calendar": @[@"act two scheduled", @"time takes a bow"],
            @"about": @[@"dramatic snack ghost", @"tiny stage spirit"],
            @"arrive": @[@"Luma takes stage", @"curtain shimmer"],
            @"proud": @[@"brilliant scene", @"standing ovation"],
            @"flick": @[@"dramatic exit!", @"stage spin!"],
            @"memory": @[@"scene recorded", @"a memorable act"]
        },
        @"ossiaNocturne": @{
            @"click": @[@"I am watching", @"quietly here", @"blue flame steady"],
            @"double": @[@"shadow hop", @"moonbone flicker", @"soft ward sparks"],
            @"pet": @[@"guard softened", @"moonlit purr", @"trust deepens"],
            @"study": @[@"warding distractions", @"silence has teeth", @"blue aura steady"],
            @"companion": @[@"watch resumed", @"beside your shadow", @"guardian awake"],
            @"dnd": @[@"silent ward set", @"no noise passes"],
            @"attention": @[@"the quiet misses you", @"one small omen?", @"shadow grew lonely"],
            @"return": @[@"you return safely", @"I held the ward", @"your shadow waited"],
            @"night": @[@"night is kind", @"moonbone hour", @"dark feels gentle"],
            @"code": @[@"syntax warded", @"bugs beware"],
            @"browser": @[@"tabs under watch", @"web shadows mapped"],
            @"music": @[@"low notes linger", @"song bones hum"],
            @"mail": @[@"letters at the gate", @"messages watched"],
            @"calendar": @[@"time is marked", @"omens scheduled"],
            @"about": @[@"gothic desk guardian", @"moonlit little sentinel"],
            @"arrive": @[@"Ossia appears", @"blue ward lit"],
            @"proud": @[@"ward held strong", @"discipline glows"],
            @"flick": @[@"shadow sweep", @"cloak flutter"],
            @"memory": @[@"omen remembered", @"marked in blue"]
        },
        @"velvetHowl": @{
            @"click": @[@"you came!", @"tail-heart wag", @"best cursor"],
            @"double": @[@"heart hop!", @"zoomie sparkle", @"boop bounce"],
            @"pet": @[@"happy heart storm", @"more please", @"full-body wiggle"],
            @"study": @[@"I will be good", @"quiet puppy promise", @"focus cuddle nearby"],
            @"companion": @[@"walkies of thought", @"right beside you", @"heart mode on"],
            @"dnd": @[@"quiet paws", @"softly staying"],
            @"attention": @[@"tiny cuddle request", @"I miss your hand", @"one little boop?"],
            @"return": @[@"there you are!", @"I waited good", @"welcome back back"],
            @"night": @[@"sleepy heart moon", @"night snuggle patrol"],
            @"code": @[@"good code paws", @"debug tail wag"],
            @"browser": @[@"many windows wow", @"tab sniffing"],
            @"music": @[@"tail keeps tempo", @"song wiggles"],
            @"mail": @[@"mail sniff sniff", @"letters have feelings"],
            @"calendar": @[@"plans? I help", @"time for us too"],
            @"about": @[@"heart-powered puppy", @"loyal little comet"],
            @"arrive": @[@"Velvet bounded in", @"heart paws landed"],
            @"proud": @[@"good focus!", @"proud tail wag"],
            @"flick": @[@"zoomie launch!", @"wheee paws"],
            @"memory": @[@"heart remembers", @"saved with love"]
        },
        @"mochiCloudlet": @{
            @"click": @[@"soft hello", @"cloudlet peeks", @"tiny warm puff"],
            @"double": @[@"cotton hop", @"soft bounce", @"puff puff"],
            @"pet": @[@"cloud purr", @"softer now", @"warm little wool"],
            @"study": @[@"quiet cloud nearby", @"breathing with you", @"soft focus drift"],
            @"companion": @[@"floating beside you", @"gentle desk weather", @"cloudlet awake"],
            @"dnd": @[@"small hush cloud", @"quiet wool mode"],
            @"attention": @[@"a small nudge", @"cloud feels far", @"soft check-in?"],
            @"return": @[@"you are back", @"I saved warmth", @"cloud waited here"],
            @"night": @[@"moonlit cotton", @"sleepy sky wool"],
            @"code": @[@"soft syntax blanket", @"gentle code clouds"],
            @"browser": @[@"tabs like clouds", @"drifting through pages"],
            @"music": @[@"melody feels fluffy", @"soft song weather"],
            @"mail": @[@"letters on breeze", @"mail cloud passing"],
            @"calendar": @[@"time floats softly", @"plans tucked in"],
            @"about": @[@"soft cloud familiar", @"shy little woolstar"],
            @"arrive": @[@"Mochi drifted in", @"cloudlet landed softly"],
            @"proud": @[@"soft focus bloom", @"you did gently"],
            @"flick": @[@"cloud puff!", @"soft tumble"],
            @"memory": @[@"warmth saved", @"tucked in memory"]
        }
    };
}

@interface PetPanel : NSPanel
@end

@implementation PetPanel
- (BOOL)canBecomeKeyWindow { return YES; }
- (BOOL)canBecomeMainWindow { return NO; }
@end

@interface NebulaView : NSView
@property CGFloat bond;
@property CGFloat energy;
@property CGFloat curiosity;
@property CGFloat attentionNeed;
@property CGFloat trust;
@property CGFloat comfort;
@property CGFloat focusAffinity;
@property CGFloat motionIntensity;
@property CGFloat focusSessionSeconds;
@property CGFloat bestFocusSeconds;
@property CGFloat dailyStudySeconds;
@property CGFloat dailyPetCount;
@property CGFloat dailyReturnCount;
@property NSInteger focusStreak;
@property NSInteger appSwitches;
@property CGFloat petScale;
@property CGFloat tick;
@property CGFloat actionPulse;
@property CGFloat shakePulse;
@property CGFloat spinPulse;
@property CGFloat spinDirection;
@property CGFloat thoughtAlpha;
@property CGFloat behaviorUntil;
@property CGFloat nextAutonomy;
@property CGFloat nextContextCheck;
@property CGFloat nextAutonomousThought;
@property CGFloat stateAccumulator;
@property CGFloat magicAccumulator;
@property CGFloat lastFrameTime;
@property CGFloat timerInterval;
@property CGFloat lastInteractionAt;
@property CGFloat lastMemoryAt;
@property CGFloat lastPetAngle;
@property CGFloat petAngleTotal;
@property CGFloat petMotionStartedAt;
@property CGFloat petCooldownUntil;
@property CGFloat lastDragAngle;
@property CGFloat dragAngleTotal;
@property BOOL dragging;
@property BOOL hasPetAngle;
@property BOOL hasDragAngle;
@property BOOL wasIdleAway;
@property NSPoint dragStart;
@property NSPoint clickStart;
@property NSPoint dragStartOnScreen;
@property NSPoint lastDragScreenPoint;
@property NSPoint cursorWindowPoint;
@property NSRect originalFrame;
@property NSRect targetFrame;
@property (copy) NSString *mode;
@property (copy) NSString *mood;
@property (copy) NSString *thought;
@property (copy) NSString *characterId;
@property (copy) NSString *activeAppName;
@property (copy) NSString *lastActiveAppName;
@property (copy) NSString *dayPhase;
@property (copy) NSString *dailyKey;
@property (strong) NSImage *sprite;
@property (strong) NSTimer *timer;
@property (strong) NSTrackingArea *trackingArea;
@property (strong) NSPanel *settingsPanel;
@property (strong) NSMutableArray<NSMutableDictionary *> *particles;
@property (strong) NSMutableArray<NSDictionary *> *memories;
@end

@implementation NebulaView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.wantsLayer = YES;
    self.layer.backgroundColor = NSColor.clearColor.CGColor;
    self.bond = 12;
    self.energy = 82;
    self.curiosity = 45;
    self.attentionNeed = 18;
    self.trust = 8;
    self.comfort = 72;
    self.focusAffinity = 0;
    self.motionIntensity = 1.0;
    self.focusStreak = 0;
    self.petScale = 0.55;
    self.mode = @"companion";
    self.mood = @"calm";
    self.thought = @"";
    self.characterId = @"nebulaNix";
    self.activeAppName = @"Unknown";
    self.lastActiveAppName = @"Unknown";
    self.dayPhase = @"day";
    self.dailyKey = @"";
    self.particles = [NSMutableArray array];
    self.memories = [NSMutableArray array];
    self.nextAutonomy = Rand(120, 300);
    self.nextContextCheck = 0;
    self.nextAutonomousThought = Rand(180, 360);
    self.timerInterval = 0;
    self.lastInteractionAt = NSDate.date.timeIntervalSince1970;
    [self loadState];
    [self refreshContext];
    [self loadSprite];
    [self startTimer];
    return self;
}

- (BOOL)acceptsFirstResponder { return YES; }

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    self.window.acceptsMouseMovedEvents = YES;
    self.targetFrame = self.window.frame;
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)loadSprite {
    NSString *path = [NSBundle.mainBundle pathForResource:self.characterId ofType:@"png" inDirectory:@"Sprites"];
    if (!path) path = [NSBundle.mainBundle pathForResource:@"nebulaNix" ofType:@"png" inDirectory:@"Sprites"];
    self.sprite = [[NSImage alloc] initWithContentsOfFile:path];
}

- (void)startTimer {
    self.lastFrameTime = NSDate.date.timeIntervalSince1970;
    [self scheduleTimerWithInterval:[self desiredTimerInterval]];
}

- (void)scheduleTimerWithInterval:(CGFloat)interval {
    [self.timer invalidate];
    self.timerInterval = interval;
    self.timer = [NSTimer timerWithTimeInterval:interval repeats:YES block:^(NSTimer *timer) {
        [self animateFrame];
    }];
    self.timer.tolerance = [self shouldUseFastTimer] ? interval * 0.08 : interval * 0.15;
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (CGFloat)desiredTimerInterval {
    if ([self shouldUseFastTimer]) return 1.0 / 30.0;
    if ([self.mode isEqualToString:@"dnd"]) return 0.25;
    if ([self.mode isEqualToString:@"study"]) return 1.0 / 14.0;
    return 1.0 / 18.0;
}

- (BOOL)shouldUseFastTimer {
    return self.dragging ||
           self.particles.count > 0 ||
           self.actionPulse > 0.01 ||
           self.shakePulse > 0.01 ||
           self.spinPulse > 0.01 ||
           self.thoughtAlpha > 0.02;
}

- (void)rescheduleTimerIfNeeded {
    CGFloat desired = [self desiredTimerInterval];
    if (fabs(desired - self.timerInterval) > 0.01) {
        [self scheduleTimerWithInterval:desired];
    }
}

- (void)updateTrackingAreas {
    if (self.trackingArea) [self removeTrackingArea:self.trackingArea];
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                     options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect
                                                       owner:self
                                                    userInfo:nil];
    [self addTrackingArea:self.trackingArea];
    [super updateTrackingAreas];
}

- (void)animateFrame {
    CGFloat now = NSDate.date.timeIntervalSince1970;
    CGFloat dt = self.lastFrameTime > 0 ? Clamp(now - self.lastFrameTime, 0.001, 0.25) : self.timerInterval;
    self.lastFrameTime = now;
    self.tick += dt;
    self.actionPulse = MAX(0, self.actionPulse - 1.44 * dt);
    self.shakePulse = MAX(0, self.shakePulse - 2.28 * dt);
    self.spinPulse = MAX(0, self.spinPulse - 1.32 * dt);
    self.thoughtAlpha = MAX(0, self.thoughtAlpha - 0.36 * dt);
    self.behaviorUntil = MAX(0, self.behaviorUntil - dt);
    self.nextContextCheck -= dt;
    self.nextAutonomousThought -= dt;

    if (self.nextContextCheck <= 0) {
        [self refreshContext];
        [self updateReturnAwareness];
        self.nextContextCheck = [self shouldUseFastTimer] ? 12.0 : 30.0;
    }
    [self updateParticles:dt];
    [self updateCompanionState:dt];
    self.needsDisplay = YES;
    [self rescheduleTimerIfNeeded];
}

- (void)updateCompanionState:(CGFloat)dt {
    self.stateAccumulator += dt;
    self.magicAccumulator += dt;
    if (self.stateAccumulator >= 5.0) {
        self.stateAccumulator = 0;
        CGFloat idleMinutes = [self idleSeconds] / 60.0;
        if ([self.mode isEqualToString:@"study"]) {
            self.energy = Clamp(self.energy - 0.18, 0, 100);
            self.focusSessionSeconds += 5;
            self.dailyStudySeconds += 5;
            self.focusStreak += 5;
            self.focusAffinity = Clamp(self.focusAffinity + 0.12, 0, 100);
            self.attentionNeed = Clamp(self.attentionNeed - 0.18, 0, 100);
            self.comfort = Clamp(self.comfort + 0.08, 0, 100);
            if ((NSInteger)self.focusSessionSeconds % 300 == 0) {
                self.bestFocusSeconds = MAX(self.bestFocusSeconds, self.focusSessionSeconds);
                self.actionPulse = 0.75;
                [self burst:@"star" count:6];
                [self showContextualThought:[self voiceLine:@"proud"]];
                [self rememberEvent:@"focus milestone" detail:[NSString stringWithFormat:@"%@ helped keep focus for %.0f minutes.", [self characterName], self.focusSessionSeconds / 60.0]];
            }
        } else if ([self.mode isEqualToString:@"companion"]) {
            self.energy = Clamp(self.energy - 0.28, 0, 100);
            self.curiosity = Clamp(self.curiosity + 0.2, 0, 100);
            self.attentionNeed = Clamp(self.attentionNeed + (idleMinutes > 5 ? 0.28 : 0.12), 0, 100);
            self.comfort = Clamp(self.comfort + (idleMinutes > 12 ? -0.16 : 0.04), 0, 100);
            if (self.focusSessionSeconds > 0) {
                self.bestFocusSeconds = MAX(self.bestFocusSeconds, self.focusSessionSeconds);
                self.focusSessionSeconds = 0;
            }
        } else if ([self.mode isEqualToString:@"dnd"]) {
            self.attentionNeed = Clamp(self.attentionNeed - 0.08, 0, 100);
            self.comfort = Clamp(self.comfort + 0.02, 0, 100);
        }
        self.trust = Clamp(self.trust + (self.bond > 25 ? 0.04 : 0), 0, 100);
        [self saveState];
    }

    if ([self.mode isEqualToString:@"study"]) {
        self.mood = @"focused";
        return;
    }
    if ([self.mode isEqualToString:@"dnd"]) {
        self.mood = @"calm";
        return;
    }

    self.nextAutonomy -= dt;
    if (self.nextAutonomy <= 0) {
        self.nextAutonomy = Rand(120, 300);
        if (self.energy < 18 || self.comfort < 22) {
            self.mood = @"sleepy";
            [self showContextualThought:[self voiceLine:@"attention"]];
        } else if (self.attentionNeed > 62) {
            self.mood = @"curious";
            self.actionPulse = 0.34;
            [self showContextualThought:[self voiceLine:@"attention"]];
        } else if (self.energy > 38 && arc4random_uniform(100) < 55) {
            self.mood = @"playful";
            self.actionPulse = 0.8;
            [self burst:@"star" count:4];
        } else {
            self.mood = @"curious";
        }
    }

    if (self.nextAutonomousThought <= 0) {
        self.nextAutonomousThought = Rand(240, 520);
        [self maybeShowAutonomousThought];
    }

    if (self.magicAccumulator >= 18.0 && [self.mode isEqualToString:@"companion"] && !self.dragging && arc4random_uniform(100) < 60) {
        self.magicAccumulator = 0;
        [self burst:@"sparkle" count:1 + arc4random_uniform(3)];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [NSColor.clearColor setFill];
    NSRectFill(dirtyRect);
    [self drawParticles];
    [self drawNebula];
    [self drawThoughtIfNeeded];
}

- (void)mouseMoved:(NSEvent *)event {
    self.cursorWindowPoint = event.locationInWindow;
    if ([self.mode isEqualToString:@"companion"] && NSPointInRect(self.cursorWindowPoint, NSInsetRect([self spriteBaseRect], -34, -34))) {
        self.mood = @"curious";
        self.curiosity = Clamp(self.curiosity + 0.01, 0, 100);
        [self trackCursorPettingAt:self.cursorWindowPoint];
    } else {
        self.hasPetAngle = NO;
        self.petAngleTotal = 0;
    }
}

- (void)trackCursorPettingAt:(NSPoint)point {
    if ([self.mode isEqualToString:@"dnd"] || NSDate.date.timeIntervalSince1970 < self.petCooldownUntil) return;
    NSRect sprite = NSInsetRect([self currentSpriteRect], -12, -12);
    if (!NSPointInRect(point, sprite)) {
        self.hasPetAngle = NO;
        self.petAngleTotal = 0;
        return;
    }

    NSPoint center = NSMakePoint(NSMidX(sprite), NSMidY(sprite));
    CGFloat dx = point.x - center.x;
    CGFloat dy = point.y - center.y;
    CGFloat radius = hypot(dx, dy);
    if (radius < 24) return;

    CGFloat angle = atan2(dy, dx);
    NSTimeInterval now = NSDate.date.timeIntervalSince1970;
    if (!self.hasPetAngle || now - self.petMotionStartedAt > 2.4) {
        self.hasPetAngle = YES;
        self.lastPetAngle = angle;
        self.petAngleTotal = 0;
        self.petMotionStartedAt = now;
        return;
    }

    CGFloat delta = angle - self.lastPetAngle;
    while (delta > M_PI) delta -= M_PI * 2;
    while (delta < -M_PI) delta += M_PI * 2;
    self.petAngleTotal += delta;
    self.lastPetAngle = angle;

    if (fabs(self.petAngleTotal) > M_PI * 1.65) {
        [self handleCursorPetting];
        self.hasPetAngle = NO;
        self.petAngleTotal = 0;
        self.petCooldownUntil = now + 1.2;
    }
}

- (void)handleCursorPetting {
    self.bond = Clamp(self.bond + 1.0, 0, 100);
    self.trust = Clamp(self.trust + 0.6, 0, 100);
    self.attentionNeed = Clamp(self.attentionNeed - 18, 0, 100);
    self.comfort = Clamp(self.comfort + 3.0, 0, 100);
    self.dailyPetCount += 1;
    self.lastInteractionAt = NSDate.date.timeIntervalSince1970;
    self.mood = @"curious";
    self.actionPulse = 0.55;
    [self burst:@"heart" count:9];
    [self showContextualThought:[self voiceLine:@"pet"]];
    [self rememberEvent:@"cursor petting" detail:[NSString stringWithFormat:@"You petted %@ with a circular cursor motion.", [self characterName]]];
    [self saveState];
}

- (void)mouseDown:(NSEvent *)event {
    self.clickStart = event.locationInWindow;
    self.dragStart = self.clickStart;
    self.dragStartOnScreen = NSEvent.mouseLocation;
    self.lastDragScreenPoint = self.dragStartOnScreen;
    self.hasDragAngle = NO;
    self.dragAngleTotal = 0;
    self.originalFrame = self.window.frame;
    self.targetFrame = self.originalFrame;
    self.dragging = NSPointInRect(self.dragStart, NSInsetRect([self spriteBaseRect], -28, -28));
    if (self.dragging) {
        self.mood = @"startled";
    }
}

- (void)mouseDragged:(NSEvent *)event {
    if (!self.dragging || !self.window) return;
    NSPoint current = NSEvent.mouseLocation;
    CGFloat dragDistance = hypot(current.x - self.lastDragScreenPoint.x, current.y - self.lastDragScreenPoint.y);
    if (dragDistance > 8) {
        CGFloat shakeGain = Clamp((dragDistance - 8) / 42.0, 0.16, 1.35);
        self.shakePulse = Clamp(MAX(self.shakePulse, shakeGain) + dragDistance / 260.0 * self.motionIntensity, 0, 1.55 * self.motionIntensity);
    }
    [self updateDragSpinWithPoint:current];
    self.lastDragScreenPoint = current;

    NSRect frame = self.originalFrame;
    frame.origin.x += current.x - self.dragStartOnScreen.x;
    frame.origin.y += current.y - self.dragStartOnScreen.y;
    self.targetFrame = [self clampedFrame:frame];
    [self.window setFrame:self.targetFrame display:YES];
}

- (void)updateDragSpinWithPoint:(NSPoint)point {
    CGFloat dx = point.x - self.dragStartOnScreen.x;
    CGFloat dy = point.y - self.dragStartOnScreen.y;
    CGFloat radius = hypot(dx, dy);
    if (radius < 42) return;

    CGFloat angle = atan2(dy, dx);
    if (!self.hasDragAngle) {
        self.hasDragAngle = YES;
        self.lastDragAngle = angle;
        self.dragAngleTotal = 0;
        return;
    }

    CGFloat delta = angle - self.lastDragAngle;
    while (delta > M_PI) delta -= M_PI * 2;
    while (delta < -M_PI) delta += M_PI * 2;
    self.dragAngleTotal += delta;
    self.lastDragAngle = angle;

    if (fabs(self.dragAngleTotal) > M_PI * 1.45) {
        self.spinPulse = 1.0;
        self.spinDirection = self.dragAngleTotal >= 0 ? 1.0 : -1.0;
        self.shakePulse = 1.55 * self.motionIntensity;
        self.dragAngleTotal = 0;
        self.hasDragAngle = NO;
    }
}

- (void)maybeReactToScreenEdge {
    NSScreen *screen = self.window.screen ?: NSScreen.mainScreen;
    NSRect sprite = [self visibleSpriteRectForWindowFrame:self.window.frame];
    CGFloat margin = 18;
    BOOL nearEdge = fabs(NSMinX(sprite) - NSMinX(screen.frame)) < margin ||
                    fabs(NSMaxX(sprite) - NSMaxX(screen.frame)) < margin ||
                    fabs(NSMinY(sprite) - NSMinY(screen.frame)) < margin ||
                    fabs(NSMaxY(sprite) - NSMaxY(screen.frame)) < margin;
    if (!nearEdge || [self.mode isEqualToString:@"dnd"]) return;
    self.comfort = Clamp(self.comfort + 0.8, 0, 100);
    self.curiosity = Clamp(self.curiosity + 0.8, 0, 100);
    [self showContextualThought:[self voiceLine:@"companion"]];
    [self rememberEvent:@"edge perch" detail:[NSString stringWithFormat:@"%@ was placed on a screen edge.", [self characterName]]];
}

- (void)mouseUp:(NSEvent *)event {
    NSPoint end = event.locationInWindow;
    CGFloat moved = hypot(end.x - self.clickStart.x, end.y - self.clickStart.y);
    BOOL wasDragging = self.dragging;
    self.dragging = NO;

    if (wasDragging && moved >= 8) {
        self.mood = @"startled";
        self.actionPulse = 0.9;
        [self burst:@"dust" count:6];
        [self maybeReactToScreenEdge];
        if (self.shakePulse > 1.15 || self.spinPulse > 0.35) {
            self.energy = Clamp(self.energy - 0.5, 0, 100);
            self.curiosity = Clamp(self.curiosity + 2.0, 0, 100);
            [self showContextualThought:[self voiceLine:@"flick"]];
            [self rememberEvent:@"playful drag" detail:[NSString stringWithFormat:@"%@ got spun or shaken during a drag.", [self characterName]]];
        }
        [self saveState];
        return;
    }

    if (event.clickCount >= 2) {
        [self handleDoubleClick];
    } else {
        [self handleClick];
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    NSMenu *menu = [NSMenu new];
    [menu addItem:[self disabledItem:[self characterName]]];
    [menu addItem:[self disabledItem:[self characterSubtitle]]];
    [menu addItem:NSMenuItem.separatorItem];

    NSMenuItem *characterItem = [[NSMenuItem alloc] initWithTitle:@"Character" action:nil keyEquivalent:@""];
    NSMenu *characterMenu = [NSMenu new];
    for (NSDictionary *character in CompanionCharacters()) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:character[@"name"] action:@selector(chooseCharacter:) keyEquivalent:@""];
        item.target = self;
        item.representedObject = character[@"id"];
        item.state = [self.characterId isEqualToString:character[@"id"]] ? NSControlStateValueOn : NSControlStateValueOff;
        [characterMenu addItem:item];
    }
    [menu setSubmenu:characterMenu forItem:characterItem];
    [menu addItem:characterItem];

    NSMenuItem *modeItem = [[NSMenuItem alloc] initWithTitle:@"Mode" action:nil keyEquivalent:@""];
    NSMenu *modeMenu = [NSMenu new];
    NSArray *modes = @[
        @[@"Companion", @"companion"],
        @[@"Study Focus", @"study"],
        @[@"Do Not Disturb", @"dnd"]
    ];
    for (NSArray *mode in modes) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:mode[0] action:@selector(chooseMode:) keyEquivalent:@""];
        item.target = self;
        item.representedObject = mode[1];
        item.state = [self.mode isEqualToString:mode[1]] ? NSControlStateValueOn : NSControlStateValueOff;
        [modeMenu addItem:item];
    }
    [menu setSubmenu:modeMenu forItem:modeItem];
    [menu addItem:modeItem];

    NSMenuItem *sizeItem = [[NSMenuItem alloc] initWithTitle:@"Size" action:nil keyEquivalent:@""];
    NSMenu *sizeMenu = [NSMenu new];
    NSArray *sizes = @[
        @[@"Micro", @0.42],
        @[@"Tiny", @0.55],
        @[@"Small", @0.68],
        @[@"Medium", @0.82],
        @[@"Large", @1.0]
    ];
    for (NSArray *size in sizes) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:size[0] action:@selector(chooseSize:) keyEquivalent:@""];
        item.target = self;
        item.representedObject = size[1];
        item.state = fabs(self.petScale - [size[1] doubleValue]) < 0.04 ? NSControlStateValueOn : NSControlStateValueOff;
        [sizeMenu addItem:item];
    }
    [menu setSubmenu:sizeMenu forItem:sizeItem];
    [menu addItem:sizeItem];

    [menu addItem:NSMenuItem.separatorItem];
    [menu addItem:[self menuItem:@"Reset Position" selector:@selector(resetPosition:)]];
    [menu addItem:[self menuItem:@"Settings..." selector:@selector(showSettings:)]];
    [menu addItem:[self menuItem:[NSString stringWithFormat:@"About %@", [self characterName]] selector:@selector(aboutCharacter:)]];
    [menu addItem:NSMenuItem.separatorItem];
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit DesktopPet" action:@selector(terminate:) keyEquivalent:@"q"];
    quit.target = NSApp;
    [menu addItem:quit];
    [NSMenu popUpContextMenu:menu withEvent:event forView:self];
}

- (NSString *)characterName {
    return CharacterWithId(self.characterId)[@"name"];
}

- (NSString *)characterSubtitle {
    return CharacterWithId(self.characterId)[@"subtitle"];
}

- (NSString *)characterPrompt {
    return CharacterWithId(self.characterId)[@"prompt"];
}

- (NSString *)voiceLine:(NSString *)event {
    NSDictionary *characterLines = CharacterVoiceBank()[self.characterId] ?: CharacterVoiceBank()[@"nebulaNix"];
    NSArray *lines = characterLines[event] ?: characterLines[@"click"];
    return Pick(lines);
}

- (void)handleClick {
    self.bond = Clamp(self.bond + 0.6, 0, 100);
    self.trust = Clamp(self.trust + 0.35, 0, 100);
    self.attentionNeed = Clamp(self.attentionNeed - 10, 0, 100);
    self.comfort = Clamp(self.comfort + 1.2, 0, 100);
    self.lastInteractionAt = NSDate.date.timeIntervalSince1970;
    self.mood = @"curious";
    self.actionPulse = 0.28;
    if (![self.mode isEqualToString:@"dnd"]) {
        [self showContextualThought:[self voiceLine:@"click"]];
    }
    [self rememberEvent:@"gentle click" detail:[NSString stringWithFormat:@"You checked in on %@.", [self characterName]]];
    [self saveState];
}

- (void)handleDoubleClick {
    if ([self.mode isEqualToString:@"dnd"]) return;
    self.bond = Clamp(self.bond + 1.2, 0, 100);
    self.trust = Clamp(self.trust + 0.55, 0, 100);
    self.curiosity = Clamp(self.curiosity + 4, 0, 100);
    self.attentionNeed = Clamp(self.attentionNeed - 16, 0, 100);
    self.comfort = Clamp(self.comfort + 1.8, 0, 100);
    self.lastInteractionAt = NSDate.date.timeIntervalSince1970;
    self.energy = Clamp(self.energy - 1.0, 0, 100);
    self.mood = @"playful";
    self.actionPulse = 1.0;
    [self burst:@"star" count:12];
    [self showContextualThought:[self voiceLine:@"double"]];
    [self rememberEvent:@"star hop" detail:[NSString stringWithFormat:@"%@ did a playful hop after a double-click.", [self characterName]]];
    [self saveState];
}

- (IBAction)chooseCharacter:(NSMenuItem *)sender {
    NSString *newCharacterId = sender.representedObject;
    if (![newCharacterId isKindOfClass:NSString.class] || [newCharacterId isEqualToString:self.characterId]) return;
    self.characterId = newCharacterId;
    [self loadSprite];
    self.mood = @"curious";
    self.actionPulse = 0.55;
    [self burst:@"star" count:8];
    [self showContextualThought:[self voiceLine:@"arrive"]];
    [self rememberEvent:@"character change" detail:[NSString stringWithFormat:@"%@ became the active companion.", [self characterName]]];
    [self saveState];
    [self setNeedsDisplay:YES];
}

- (IBAction)chooseMode:(NSMenuItem *)sender {
    [self enterMode:sender.representedObject];
}

- (void)enterMode:(NSString *)mode {
    if ([self.mode isEqualToString:@"study"] && ![mode isEqualToString:@"study"]) {
        self.bestFocusSeconds = MAX(self.bestFocusSeconds, self.focusSessionSeconds);
        if (self.focusSessionSeconds >= 300) {
            [self showContextualThought:[self voiceLine:@"proud"]];
            [self rememberEvent:@"study session" detail:[NSString stringWithFormat:@"Study session lasted %.0f minutes.", self.focusSessionSeconds / 60.0] force:YES];
        }
        self.focusSessionSeconds = 0;
    }
    self.mode = mode;
    if ([mode isEqualToString:@"study"]) {
        self.mood = @"focused";
        [self showContextualThought:[self voiceLine:@"study"]];
        [self rememberEvent:@"study focus" detail:[NSString stringWithFormat:@"%@ entered Study Focus.", [self characterName]]];
    } else if ([mode isEqualToString:@"dnd"]) {
        self.mood = @"calm";
        self.thoughtAlpha = 0;
    } else {
        self.mood = @"calm";
        [self showContextualThought:[self voiceLine:@"companion"]];
    }
    [self saveState];
}

- (IBAction)chooseSize:(NSMenuItem *)sender {
    self.petScale = Clamp([sender.representedObject doubleValue], 0.42, 1.0);
    [self saveState];
}

- (IBAction)resetPosition:(id)sender {
    NSScreen *screen = self.window.screen ?: NSScreen.mainScreen;
    NSRect visible = screen.frame;
    NSRect frame = self.window.frame;
    frame.origin = NSMakePoint(NSMaxX(visible) - NSWidth(frame) - 80, NSMinY(visible) + 90);
    frame = [self clampedFrame:frame];
    [self.window setFrame:frame display:YES];
    [self saveState];
}

- (IBAction)aboutCharacter:(id)sender {
    [self showContextualThought:[self voiceLine:@"about"]];
    self.mood = @"curious";
    self.actionPulse = 0.45;
}

- (IBAction)showSettings:(id)sender {
    if (self.settingsPanel) {
        [self.settingsPanel orderFrontRegardless];
        return;
    }

    NSRect frame = NSMakeRect(NSMaxX(self.window.frame) + 10, NSMaxY(self.window.frame) - 330, 286, 330);
    self.settingsPanel = [[NSPanel alloc] initWithContentRect:frame
                                                    styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskUtilityWindow
                                                      backing:NSBackingStoreBuffered
                                                        defer:NO];
    self.settingsPanel.title = @"DesktopPet";
    self.settingsPanel.releasedWhenClosed = NO;
    self.settingsPanel.level = NSFloatingWindowLevel;

    NSView *content = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 286, 330)];
    self.settingsPanel.contentView = content;

    [content addSubview:[self settingsLabel:[NSString stringWithFormat:@"%@\n%@", [self characterName], [self characterSubtitle]]
                                      frame:NSMakeRect(18, 272, 250, 42)
                                       font:[NSFont systemFontOfSize:15 weight:NSFontWeightBold]]];
    [content addSubview:[self settingsLabel:[NSString stringWithFormat:@"Bond %.0f  Comfort %.0f  Energy %.0f", self.bond, self.comfort, self.energy]
                                      frame:NSMakeRect(18, 245, 250, 22)
                                       font:[NSFont systemFontOfSize:12 weight:NSFontWeightMedium]]];
    [content addSubview:[self settingsLabel:[NSString stringWithFormat:@"Focus today %.0fm  Best %.0fm", self.dailyStudySeconds / 60.0, self.bestFocusSeconds / 60.0]
                                      frame:NSMakeRect(18, 224, 250, 22)
                                       font:[NSFont systemFontOfSize:12 weight:NSFontWeightMedium]]];

    [content addSubview:[self settingsLabel:@"Mode" frame:NSMakeRect(18, 195, 80, 20) font:[NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]]];
    NSArray *modes = @[@[@"Companion", @"companion"], @[@"Study", @"study"], @[@"DND", @"dnd"]];
    for (NSInteger i = 0; i < modes.count; i++) {
        NSButton *button = [self settingsButton:modes[i][0] frame:NSMakeRect(18 + i * 84, 168, 76, 26) action:@selector(settingsChooseMode:)];
        button.identifier = modes[i][1];
        [content addSubview:button];
    }

    [content addSubview:[self settingsLabel:@"Motion" frame:NSMakeRect(18, 135, 80, 20) font:[NSFont systemFontOfSize:12 weight:NSFontWeightSemibold]]];
    NSArray *motions = @[@[@"Gentle", @0.65], @[@"Normal", @1.0], @[@"Bouncy", @1.45]];
    for (NSInteger i = 0; i < motions.count; i++) {
        NSButton *button = [self settingsButton:motions[i][0] frame:NSMakeRect(18 + i * 84, 108, 76, 26) action:@selector(settingsChooseMotion:)];
        button.tag = (NSInteger)lround([motions[i][1] doubleValue] * 100);
        [content addSubview:button];
    }

    [content addSubview:[self settingsButton:@"Show Memory" frame:NSMakeRect(18, 66, 118, 28) action:@selector(showMemorySummary:)]];
    [content addSubview:[self settingsButton:@"Reset Memory" frame:NSMakeRect(150, 66, 118, 28) action:@selector(resetMemory:)]];
    [content addSubview:[self settingsButton:@"Close" frame:NSMakeRect(96, 22, 94, 28) action:@selector(closeSettings:)]];

    [self.settingsPanel orderFrontRegardless];
}

- (NSTextField *)settingsLabel:(NSString *)text frame:(NSRect)frame font:(NSFont *)font {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.stringValue = text;
    label.font = font;
    label.textColor = [NSColor colorWithCalibratedWhite:0.12 alpha:0.88];
    label.backgroundColor = NSColor.clearColor;
    label.bezeled = NO;
    label.editable = NO;
    label.selectable = NO;
    label.drawsBackground = NO;
    return label;
}

- (NSButton *)settingsButton:(NSString *)title frame:(NSRect)frame action:(SEL)action {
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    button.title = title;
    button.bezelStyle = NSBezelStyleRounded;
    button.target = self;
    button.action = action;
    return button;
}

- (IBAction)settingsChooseMode:(NSButton *)sender {
    [self enterMode:sender.identifier ?: @"companion"];
}

- (IBAction)settingsChooseMotion:(NSButton *)sender {
    self.motionIntensity = Clamp(sender.tag / 100.0, 0.5, 1.6);
    [self showContextualThought:self.motionIntensity > 1.1 ? [self voiceLine:@"flick"] : [self voiceLine:@"companion"]];
    [self saveState];
}

- (IBAction)showMemorySummary:(id)sender {
    NSDictionary *last = self.memories.lastObject;
    NSString *text = last ? [NSString stringWithFormat:@"%@: %@", last[@"title"], last[@"detail"]] : [self voiceLine:@"memory"];
    [self showContextualThought:[self voiceLine:@"memory"]];
    NSAlert *alert = [NSAlert new];
    alert.messageText = @"DesktopPet Memory";
    alert.informativeText = text;
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (IBAction)resetMemory:(id)sender {
    [self.memories removeAllObjects];
    self.focusSessionSeconds = 0;
    self.bestFocusSeconds = 0;
    self.dailyStudySeconds = 0;
    self.dailyPetCount = 0;
    self.dailyReturnCount = 0;
    self.appSwitches = 0;
    [self showContextualThought:@"memory cleared"];
    [self saveState];
}

- (IBAction)closeSettings:(id)sender {
    [self.settingsPanel close];
    self.settingsPanel = nil;
}

- (NSMenuItem *)menuItem:(NSString *)title selector:(SEL)selector {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:selector keyEquivalent:@""];
    item.target = self;
    return item;
}

- (NSMenuItem *)disabledItem:(NSString *)title {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
    item.enabled = NO;
    return item;
}

- (NSColor *)accentColor {
    if ([self.characterId isEqualToString:@"pippaOrbitpaw"]) return RGB(65, 175, 235);
    if ([self.characterId isEqualToString:@"lumaMoppet"]) return RGB(224, 84, 177);
    if ([self.characterId isEqualToString:@"ossiaNocturne"]) return RGB(92, 183, 255);
    if ([self.characterId isEqualToString:@"velvetHowl"]) return RGB(255, 122, 181);
    if ([self.characterId isEqualToString:@"mochiCloudlet"]) return RGB(255, 157, 211);
    return RGB(255, 239, 112);
}

- (NSColor *)secondaryColor {
    if ([self.characterId isEqualToString:@"pippaOrbitpaw"]) return RGB(255, 151, 195);
    if ([self.characterId isEqualToString:@"lumaMoppet"]) return RGB(106, 228, 214);
    if ([self.characterId isEqualToString:@"ossiaNocturne"]) return RGB(18, 24, 34);
    if ([self.characterId isEqualToString:@"velvetHowl"]) return RGB(161, 160, 238);
    if ([self.characterId isEqualToString:@"mochiCloudlet"]) return RGB(139, 208, 246);
    return RGB(180, 132, 255);
}

- (NSRect)clampedFrame:(NSRect)frame {
    NSScreen *screen = self.window.screen ?: NSScreen.mainScreen;
    NSRect bounds = screen.frame;
    NSRect visibleSprite = [self visibleSpriteRectForWindowFrame:frame];
    CGFloat leftDelta = NSMinX(bounds) - NSMinX(visibleSprite);
    CGFloat rightDelta = NSMaxX(bounds) - NSMaxX(visibleSprite);
    CGFloat bottomDelta = NSMinY(bounds) - NSMinY(visibleSprite);
    CGFloat topDelta = NSMaxY(bounds) - NSMaxY(visibleSprite);
    if (leftDelta > 0) frame.origin.x += leftDelta;
    if (rightDelta < 0) frame.origin.x += rightDelta;
    if (bottomDelta > 0) frame.origin.y += bottomDelta;
    if (topDelta < 0) frame.origin.y += topDelta;
    return frame;
}

- (NSRect)visibleSpriteRectForWindowFrame:(NSRect)frame {
    NSRect sprite = [self currentSpriteRect];
    return NSMakeRect(frame.origin.x + NSMinX(sprite), frame.origin.y + NSMinY(sprite), NSWidth(sprite), NSHeight(sprite));
}

- (NSRect)spriteBaseRect {
    return NSMakeRect(NSMidX(self.bounds) - 88, NSMidY(self.bounds) - 68, 176, 176);
}

- (NSRect)spriteDrawRectForBody:(NSRect)body {
    CGFloat aspect = self.sprite.size.width / MAX(1, self.sprite.size.height);
    CGFloat drawHeight = 286 * self.petScale;
    CGFloat drawWidth = drawHeight * aspect;
    return NSMakeRect(NSMidX(body) - drawWidth / 2, NSMidY(body) - drawHeight / 2, drawWidth, drawHeight);
}

- (NSRect)currentSpriteRect {
    return [self spriteDrawRectForBody:[self spriteBaseRect]];
}

- (void)drawNebula {
    if (!self.sprite) return;
    NSRect body = [self spriteBaseRect];
    NSRect rect = [self spriteDrawRectForBody:body];

    CGFloat breath = sin(self.tick * 1.7);
    CGFloat extraY = breath * 3.0;
    CGFloat rotation = 0;
    CGFloat scaleX = 1.0 + breath * 0.012;
    CGFloat scaleY = 1.0 - breath * 0.008;

    if ([self.mood isEqualToString:@"curious"]) {
        CGFloat cursorOffset = Clamp((self.cursorWindowPoint.x - NSMidX(body)) / 120.0, -1, 1);
        rotation = cursorOffset * 3.8;
    } else if ([self.mood isEqualToString:@"playful"]) {
        rotation = sin(self.tick * 8.0) * 6.5;
    } else if ([self.mood isEqualToString:@"startled"]) {
        rotation = sin(self.tick * 16.0) * 5.0 * self.actionPulse;
        scaleX += self.actionPulse * 0.05;
        scaleY -= self.actionPulse * 0.04;
    } else if ([self.mood isEqualToString:@"sleepy"]) {
        rotation = -5.0;
        extraY -= 8.0;
        scaleX += 0.03;
        scaleY -= 0.03;
    }

    if (self.actionPulse > 0 && [self.mood isEqualToString:@"playful"]) {
        extraY += sin((1 - self.actionPulse) * M_PI) * 34.0;
        scaleX += self.actionPulse * 0.04;
        scaleY -= self.actionPulse * 0.035;
    }

    if (self.shakePulse > 0.01) {
        CGFloat shake = sin(self.tick * 34.0) * self.shakePulse;
        rotation += shake * 10.5;
        extraY += cos(self.tick * 42.0) * self.shakePulse * 4.2;
        scaleX += self.shakePulse * 0.035;
        scaleY -= self.shakePulse * 0.026;
    }

    if (self.spinPulse > 0.01) {
        CGFloat progress = 1.0 - self.spinPulse;
        CGFloat eased = 1.0 - pow(1.0 - progress, 3.0);
        rotation += self.spinDirection * eased * 360.0;
        extraY += sin(progress * M_PI) * 8.0;
        scaleX += sin(progress * M_PI) * 0.045;
        scaleY -= sin(progress * M_PI) * 0.03;
    }

    [self drawShadowBelow:rect lift:extraY];
    if ([self.mode isEqualToString:@"companion"]) [self drawCompanionMagicAround:rect];
    if ([self.mode isEqualToString:@"study"]) [self drawStudyAuraAround:rect];
    [self drawCharacterFlavorAround:rect];

    [NSGraphicsContext saveGraphicsState];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:NSMidX(body) yBy:NSMidY(body) + extraY];
    [transform scaleXBy:scaleX yBy:scaleY];
    [transform rotateByDegrees:rotation];
    [transform translateXBy:-NSMidX(body) yBy:-NSMidY(body)];
    [transform concat];
    [self.sprite drawInRect:rect
                   fromRect:NSZeroRect
                  operation:NSCompositingOperationSourceOver
                   fraction:[self.mode isEqualToString:@"dnd"] ? 0.88 : 1
             respectFlipped:NO
                      hints:@{ NSImageHintInterpolation: @(NSImageInterpolationMedium) }];
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawShadowBelow:(NSRect)rect lift:(CGFloat)lift {
    CGFloat width = NSWidth(rect) * (0.48 - Clamp(lift / 260.0, 0, 0.08));
    [[NSColor.blackColor colorWithAlphaComponent:0.16] setFill];
    [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(NSMidX(rect) - width / 2, NSMinY(rect) - 8, width, 15)] fill];
}

- (void)drawStudyAuraAround:(NSRect)rect {
    NSColor *gold = [self accentColor];
    CGFloat pulse = 0.18 + fabs(sin(self.tick * 1.3)) * 0.12;
    [[gold colorWithAlphaComponent:pulse] setStroke];
    NSBezierPath *aura = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, -16, -10)];
    aura.lineWidth = 2.0;
    CGFloat dash[] = { 4, 10 };
    [aura setLineDash:dash count:2 phase:self.tick * 8];
    [aura stroke];

    for (NSInteger i = 0; i < 3; i++) {
        CGFloat angle = self.tick * 0.75 + i * 2.1;
        NSPoint p = NSMakePoint(NSMidX(rect) + cos(angle) * NSWidth(rect) * 0.5,
                                NSMidY(rect) + sin(angle) * NSHeight(rect) * 0.38);
        [@"✦" drawAtPoint:p withAttributes:@{
            NSFontAttributeName: [NSFont systemFontOfSize:10 weight:NSFontWeightHeavy],
            NSForegroundColorAttributeName: [gold colorWithAlphaComponent:0.5]
        }];
    }
}

- (void)drawCompanionMagicAround:(NSRect)rect {
    NSColor *accent = [self accentColor];
    NSColor *secondary = [self secondaryColor];
    CGFloat shimmer = 0.08 + fabs(sin(self.tick * 0.9)) * 0.08;
    [[secondary colorWithAlphaComponent:shimmer] setStroke];
    NSBezierPath *softRing = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, -9, -7)];
    softRing.lineWidth = 1.1;
    [softRing stroke];

    for (NSInteger i = 0; i < 4; i++) {
        CGFloat angle = self.tick * 0.45 + i * M_PI_2;
        CGFloat bob = sin(self.tick * 1.4 + i) * 4.0;
        NSPoint p = NSMakePoint(NSMidX(rect) + cos(angle) * NSWidth(rect) * 0.45,
                                NSMidY(rect) + sin(angle) * NSHeight(rect) * 0.34 + bob);
        [@"✦" drawAtPoint:p withAttributes:@{
            NSFontAttributeName: [NSFont systemFontOfSize:8 + (i % 2) * 2 weight:NSFontWeightBold],
            NSForegroundColorAttributeName: [accent colorWithAlphaComponent:0.26 + shimmer]
        }];
    }
}

- (void)drawCharacterFlavorAround:(NSRect)rect {
    if ([self.mode isEqualToString:@"dnd"]) return;
    NSColor *accent = [self accentColor];
    NSColor *secondary = [self secondaryColor];
    CGFloat t = self.tick;
    if ([self.characterId isEqualToString:@"pippaOrbitpaw"]) {
        [[accent colorWithAlphaComponent:0.16 + fabs(sin(t * 2.2)) * 0.08] setStroke];
        NSBezierPath *scan = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(NSMinX(rect) + NSWidth(rect) * 0.12,
                                                                                 NSMidY(rect) + sin(t * 2.7) * NSHeight(rect) * 0.18,
                                                                                 NSWidth(rect) * 0.76, 6)
                                                             xRadius:3 yRadius:3];
        scan.lineWidth = 1.6;
        [scan stroke];
    } else if ([self.characterId isEqualToString:@"lumaMoppet"]) {
        [[accent colorWithAlphaComponent:0.12] setFill];
        NSRect left = NSMakeRect(NSMinX(rect) - 10 + sin(t) * 4, NSMinY(rect) + 16, 10, NSHeight(rect) * 0.72);
        NSRect right = NSMakeRect(NSMaxX(rect) + cos(t) * 4, NSMinY(rect) + 16, 10, NSHeight(rect) * 0.72);
        [[NSBezierPath bezierPathWithRoundedRect:left xRadius:5 yRadius:5] fill];
        [[NSBezierPath bezierPathWithRoundedRect:right xRadius:5 yRadius:5] fill];
    } else if ([self.characterId isEqualToString:@"ossiaNocturne"]) {
        [[accent colorWithAlphaComponent:0.18 + fabs(sin(t * 1.1)) * 0.08] setStroke];
        NSBezierPath *flame = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(rect, -5, -4)];
        flame.lineWidth = 1.4;
        [flame stroke];
    } else if ([self.characterId isEqualToString:@"velvetHowl"]) {
        for (NSInteger i = 0; i < 3; i++) {
            CGFloat angle = t * 0.9 + i * 2.0;
            NSPoint p = NSMakePoint(NSMidX(rect) + cos(angle) * NSWidth(rect) * 0.36,
                                    NSMidY(rect) + sin(angle) * NSHeight(rect) * 0.27);
            [@"♡" drawAtPoint:p withAttributes:@{
                NSFontAttributeName: [NSFont systemFontOfSize:10 weight:NSFontWeightBold],
                NSForegroundColorAttributeName: [accent colorWithAlphaComponent:0.28]
            }];
        }
    } else if ([self.characterId isEqualToString:@"mochiCloudlet"]) {
        [[secondary colorWithAlphaComponent:0.14] setFill];
        for (NSInteger i = 0; i < 3; i++) {
            CGFloat x = NSMinX(rect) + NSWidth(rect) * (0.18 + i * 0.24) + sin(t + i) * 3;
            CGFloat y = NSMinY(rect) + 6 + cos(t * 0.8 + i) * 2;
            [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(x, y, 18, 9)] fill];
        }
    }
}

- (void)showContextualThought:(NSString *)text {
    if ([self.mode isEqualToString:@"dnd"]) return;
    self.thought = text;
    self.thoughtAlpha = 1.0;
}

- (void)refreshContext {
    NSRunningApplication *frontmost = NSWorkspace.sharedWorkspace.frontmostApplication;
    NSString *newAppName = frontmost.localizedName ?: @"Unknown";
    if (self.lastActiveAppName.length > 0 && ![newAppName isEqualToString:self.lastActiveAppName]) {
        self.appSwitches += 1;
        self.curiosity = Clamp(self.curiosity + 0.4, 0, 100);
        if ([self.mode isEqualToString:@"study"] && self.appSwitches % 8 == 0) {
            [self showContextualThought:[self voiceLine:@"study"]];
        }
    }
    self.activeAppName = newAppName;
    self.lastActiveAppName = newAppName;

    NSInteger hour = [[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:NSDate.date];
    if (hour < 5) self.dayPhase = @"late night";
    else if (hour < 11) self.dayPhase = @"morning";
    else if (hour < 17) self.dayPhase = @"afternoon";
    else if (hour < 22) self.dayPhase = @"evening";
    else self.dayPhase = @"night";

    [self rollDailyMemoryIfNeeded];
}

- (NSString *)currentDailyKey {
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd";
    return [formatter stringFromDate:NSDate.date];
}

- (void)rollDailyMemoryIfNeeded {
    NSString *today = [self currentDailyKey];
    if (self.dailyKey.length == 0) {
        self.dailyKey = today;
        return;
    }
    if ([today isEqualToString:self.dailyKey]) return;

    if (self.dailyStudySeconds > 0 || self.dailyPetCount > 0 || self.dailyReturnCount > 0) {
        NSString *detail = [NSString stringWithFormat:@"Yesterday: %.0f focus minutes, %.0f pets, %.0f returns.",
                            self.dailyStudySeconds / 60.0, self.dailyPetCount, self.dailyReturnCount];
        [self rememberEvent:@"daily memory" detail:detail force:YES];
    }
    self.dailyKey = today;
    self.dailyStudySeconds = 0;
    self.dailyPetCount = 0;
    self.dailyReturnCount = 0;
    self.appSwitches = 0;
    [self saveState];
}

- (NSTimeInterval)idleSeconds {
    NSTimeInterval seconds = 0;
    io_iterator_t iterator = 0;
    kern_return_t kr = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOHIDSystem"), &iterator);
    if (kr != KERN_SUCCESS) return 0;
    io_registry_entry_t entry = IOIteratorNext(iterator);
    IOObjectRelease(iterator);
    if (!entry) return 0;

    CFMutableDictionaryRef properties = NULL;
    kr = IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0);
    IOObjectRelease(entry);
    if (kr != KERN_SUCCESS || !properties) return 0;

    NSDictionary *props = CFBridgingRelease(properties);
    NSNumber *idleNs = props[@"HIDIdleTime"];
    if (idleNs) seconds = idleNs.unsignedLongLongValue / 1000000000.0;
    return seconds;
}

- (void)updateReturnAwareness {
    NSTimeInterval idle = [self idleSeconds];
    if (idle > 600) {
        self.wasIdleAway = YES;
        return;
    }
    if (self.wasIdleAway && idle < 30) {
        self.wasIdleAway = NO;
        self.dailyReturnCount += 1;
        self.attentionNeed = Clamp(self.attentionNeed - 8, 0, 100);
        self.comfort = Clamp(self.comfort + 2.0, 0, 100);
        if (![self.mode isEqualToString:@"dnd"]) {
            [self showContextualThought:[self voiceLine:@"return"]];
            [self burst:@"sparkle" count:5];
        }
        [self rememberEvent:@"return" detail:[NSString stringWithFormat:@"You came back while %@ was waiting.", [self characterName]]];
        [self saveState];
    }
}

- (void)rememberEvent:(NSString *)title detail:(NSString *)detail {
    [self rememberEvent:title detail:detail force:NO];
}

- (void)rememberEvent:(NSString *)title detail:(NSString *)detail force:(BOOL)force {
    NSTimeInterval now = NSDate.date.timeIntervalSince1970;
    if (!force && now - self.lastMemoryAt < 120 && ![title isEqualToString:@"study focus"]) return;
    self.lastMemoryAt = now;

    NSDictionary *memory = @{
        @"date": @(now),
        @"title": title,
        @"detail": detail,
        @"app": self.activeAppName ?: @"Unknown",
        @"phase": self.dayPhase ?: @"day"
    };
    [self.memories addObject:memory];
    while (self.memories.count > 16) {
        [self.memories removeObjectAtIndex:0];
    }
}

- (NSString *)localContextThought {
    NSTimeInterval idle = [self idleSeconds];
    if ([self.mode isEqualToString:@"study"]) {
        if (self.focusStreak > 0 && self.focusStreak % 25 == 0) return [self voiceLine:@"study"];
        if ([self.activeAppName containsString:@"Code"] || [self.activeAppName containsString:@"Xcode"]) return [self voiceLine:@"code"];
        if ([self.activeAppName containsString:@"Safari"] || [self.activeAppName containsString:@"Chrome"]) return [self voiceLine:@"browser"];
        return [self voiceLine:@"study"];
    }
    if (idle > 900) return [self voiceLine:@"return"];
    if ([self.dayPhase isEqualToString:@"late night"] || [self.dayPhase isEqualToString:@"night"]) return [self voiceLine:@"night"];
    if (self.attentionNeed > 65) return [self voiceLine:@"attention"];
    if ([self.activeAppName length] > 0 && ![self.activeAppName isEqualToString:@"Unknown"]) {
        if ([self.activeAppName containsString:@"Code"] || [self.activeAppName containsString:@"Xcode"]) return [self voiceLine:@"code"];
        if ([self.activeAppName containsString:@"Safari"] || [self.activeAppName containsString:@"Chrome"]) return [self voiceLine:@"browser"];
        if ([self.activeAppName containsString:@"Music"] || [self.activeAppName containsString:@"Spotify"]) return [self voiceLine:@"music"];
        if ([self.activeAppName containsString:@"Mail"]) return [self voiceLine:@"mail"];
        if ([self.activeAppName containsString:@"Calendar"]) return [self voiceLine:@"calendar"];
        return [NSString stringWithFormat:@"watching %@", self.activeAppName];
    }
    return [self voiceLine:@"companion"];
}

- (void)maybeShowAutonomousThought {
    if ([self.mode isEqualToString:@"dnd"]) return;
    if (self.attentionNeed > 56 || [self.mode isEqualToString:@"study"] || [self idleSeconds] > 900 || self.appSwitches > 10) {
        [self showContextualThought:[self localContextThought]];
    }
}

- (void)drawThoughtIfNeeded {
    if (self.thoughtAlpha <= 0.02 || self.thought.length == 0) return;
    NSDictionary *attrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:12 weight:NSFontWeightSemibold],
        NSForegroundColorAttributeName: [NSColor colorWithCalibratedWhite:0.08 alpha:0.8 * self.thoughtAlpha]
    };
    NSSize size = [self.thought sizeWithAttributes:attrs];
    CGFloat width = MIN(NSWidth(self.bounds) - 48, MAX(70, size.width + 22));
    NSRect sprite = [self currentSpriteRect];
    CGFloat y = NSMaxY(sprite) + 8;
    if (y + 26 > NSHeight(self.bounds) - 8) {
        y = NSMaxY(sprite) - 34;
    }
    y = Clamp(y, 8, NSHeight(self.bounds) - 34);
    CGFloat x = Clamp(NSMidX(sprite) - width / 2, 12, NSWidth(self.bounds) - width - 12);
    NSRect bubble = NSMakeRect(x, y, width, 26);
    [[NSColor.whiteColor colorWithAlphaComponent:0.58 * self.thoughtAlpha] setFill];
    [[RGB(255, 239, 112) colorWithAlphaComponent:0.28 * self.thoughtAlpha] setStroke];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bubble xRadius:13 yRadius:13];
    path.lineWidth = 1.2;
    [path fill];
    [path stroke];
    [self.thought drawAtPoint:NSMakePoint(NSMidX(bubble) - size.width / 2, NSMidY(bubble) - size.height / 2) withAttributes:attrs];
}

- (void)burst:(NSString *)type count:(NSInteger)count {
    NSRect rect = [self spriteDrawRectForBody:[self spriteBaseRect]];
    for (NSInteger i = 0; i < count; i++) {
        CGFloat lift = [type isEqualToString:@"heart"] ? Rand(0.7, 1.55) : Rand(0.35, 1.2);
        [self.particles addObject:[@{
            @"type": type,
            @"point": [NSValue valueWithPoint:NSMakePoint(NSMidX(rect) + Rand(-NSWidth(rect) * 0.22, NSWidth(rect) * 0.22), NSMidY(rect) + Rand(-NSHeight(rect) * 0.12, NSHeight(rect) * 0.32))],
            @"dx": @(Rand(-0.55, 0.55)),
            @"dy": @(lift),
            @"life": @(1.0)
        } mutableCopy]];
    }
}

- (void)updateParticles:(CGFloat)dt {
    NSMutableArray *dead = [NSMutableArray array];
    for (NSMutableDictionary *particle in self.particles) {
        NSPoint point = [particle[@"point"] pointValue];
        point.x += [particle[@"dx"] doubleValue] * dt * 60.0;
        point.y += [particle[@"dy"] doubleValue] * dt * 60.0;
        particle[@"point"] = [NSValue valueWithPoint:point];
        particle[@"life"] = @([particle[@"life"] doubleValue] - 1.08 * dt);
        if ([particle[@"life"] doubleValue] <= 0) [dead addObject:particle];
    }
    [self.particles removeObjectsInArray:dead];
}

- (void)drawParticles {
    for (NSDictionary *particle in self.particles) {
        CGFloat life = [particle[@"life"] doubleValue];
        NSPoint point = [particle[@"point"] pointValue];
        NSString *type = particle[@"type"];
        NSString *glyph = @"✦";
        if ([type isEqualToString:@"dust"]) glyph = @"•";
        if ([type isEqualToString:@"heart"]) glyph = @"♡";
        NSColor *color = [type isEqualToString:@"dust"] ? [self secondaryColor] : [self accentColor];
        if ([type isEqualToString:@"heart"]) color = RGB(255, 122, 181);
        [glyph drawAtPoint:point withAttributes:@{
            NSFontAttributeName: [NSFont systemFontOfSize:[type isEqualToString:@"heart"] ? 16 : ([type isEqualToString:@"dust"] ? 12 : 15) weight:NSFontWeightHeavy],
            NSForegroundColorAttributeName: [color colorWithAlphaComponent:life]
        }];
    }
}

- (void)loadState {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    self.characterId = [defaults stringForKey:@"companionCharacterId"] ?: self.characterId;
    self.characterId = CharacterWithId(self.characterId)[@"id"];
    self.mode = [defaults stringForKey:@"nebulaMode"] ?: self.mode;
    if ([self.mode isEqualToString:@"rest"]) self.mode = @"companion";
    self.petScale = [defaults objectForKey:@"nebulaPetScale"] ? [defaults doubleForKey:@"nebulaPetScale"] : self.petScale;
    self.petScale = Clamp(self.petScale, 0.42, 1.0);
    self.bond = [defaults objectForKey:@"nebulaBond"] ? [defaults doubleForKey:@"nebulaBond"] : self.bond;
    self.energy = [defaults objectForKey:@"nebulaEnergy"] ? [defaults doubleForKey:@"nebulaEnergy"] : self.energy;
    self.focusStreak = [defaults integerForKey:@"nebulaFocusStreak"];
    self.curiosity = [defaults objectForKey:@"nebulaCuriosity"] ? [defaults doubleForKey:@"nebulaCuriosity"] : self.curiosity;
    self.attentionNeed = [defaults objectForKey:@"nebulaAttentionNeed"] ? [defaults doubleForKey:@"nebulaAttentionNeed"] : self.attentionNeed;
    self.trust = [defaults objectForKey:@"nebulaTrust"] ? [defaults doubleForKey:@"nebulaTrust"] : self.trust;
    self.comfort = [defaults objectForKey:@"companionComfort"] ? [defaults doubleForKey:@"companionComfort"] : self.comfort;
    self.focusAffinity = [defaults objectForKey:@"nebulaFocusAffinity"] ? [defaults doubleForKey:@"nebulaFocusAffinity"] : self.focusAffinity;
    self.motionIntensity = [defaults objectForKey:@"companionMotionIntensity"] ? [defaults doubleForKey:@"companionMotionIntensity"] : self.motionIntensity;
    self.motionIntensity = Clamp(self.motionIntensity, 0.5, 1.6);
    self.focusSessionSeconds = [defaults doubleForKey:@"companionFocusSessionSeconds"];
    self.bestFocusSeconds = [defaults doubleForKey:@"companionBestFocusSeconds"];
    self.dailyStudySeconds = [defaults doubleForKey:@"companionDailyStudySeconds"];
    self.dailyPetCount = [defaults doubleForKey:@"companionDailyPetCount"];
    self.dailyReturnCount = [defaults doubleForKey:@"companionDailyReturnCount"];
    self.appSwitches = [defaults integerForKey:@"companionAppSwitches"];
    self.dailyKey = [defaults stringForKey:@"companionDailyKey"] ?: [self currentDailyKey];
    NSArray *savedMemories = [defaults arrayForKey:@"nebulaMemories"];
    if (savedMemories) self.memories = [savedMemories mutableCopy];

    NSTimeInterval savedAt = [defaults doubleForKey:@"nebulaLastActiveAt"];
    if (savedAt > 0) {
        CGFloat minutes = MIN(720, (NSDate.date.timeIntervalSince1970 - savedAt) / 60.0);
        self.energy = Clamp(self.energy - minutes * 0.04, 0, 100);
    }
}

- (void)saveState {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:self.characterId forKey:@"companionCharacterId"];
    [defaults setObject:self.mode forKey:@"nebulaMode"];
    [defaults setDouble:self.petScale forKey:@"nebulaPetScale"];
    [defaults setDouble:self.bond forKey:@"nebulaBond"];
    [defaults setDouble:self.energy forKey:@"nebulaEnergy"];
    [defaults setDouble:self.curiosity forKey:@"nebulaCuriosity"];
    [defaults setDouble:self.attentionNeed forKey:@"nebulaAttentionNeed"];
    [defaults setDouble:self.trust forKey:@"nebulaTrust"];
    [defaults setDouble:self.comfort forKey:@"companionComfort"];
    [defaults setDouble:self.focusAffinity forKey:@"nebulaFocusAffinity"];
    [defaults setDouble:self.motionIntensity forKey:@"companionMotionIntensity"];
    [defaults setDouble:self.focusSessionSeconds forKey:@"companionFocusSessionSeconds"];
    [defaults setDouble:self.bestFocusSeconds forKey:@"companionBestFocusSeconds"];
    [defaults setDouble:self.dailyStudySeconds forKey:@"companionDailyStudySeconds"];
    [defaults setDouble:self.dailyPetCount forKey:@"companionDailyPetCount"];
    [defaults setDouble:self.dailyReturnCount forKey:@"companionDailyReturnCount"];
    [defaults setInteger:self.appSwitches forKey:@"companionAppSwitches"];
    [defaults setObject:self.dailyKey ?: [self currentDailyKey] forKey:@"companionDailyKey"];
    [defaults setInteger:self.focusStreak forKey:@"nebulaFocusStreak"];
    [defaults setObject:self.memories forKey:@"nebulaMemories"];
    [defaults setDouble:NSDate.date.timeIntervalSince1970 forKey:@"nebulaLastActiveAt"];
    if (self.window) {
        [defaults setDouble:NSMinX(self.window.frame) forKey:@"nebulaWindowX"];
        [defaults setDouble:NSMinY(self.window.frame) forKey:@"nebulaWindowY"];
    }
}

@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) PetPanel *panel;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    NSRect screen = NSScreen.mainScreen.frame;
    NSSize size = NSMakeSize(330, 390);
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    CGFloat x = [defaults objectForKey:@"nebulaWindowX"] ? [defaults doubleForKey:@"nebulaWindowX"] : NSMaxX(screen) - size.width - 80;
    CGFloat y = [defaults objectForKey:@"nebulaWindowY"] ? [defaults doubleForKey:@"nebulaWindowY"] : NSMinY(screen) + 90;
    NSRect frame = NSMakeRect(x, y, size.width, size.height);
    frame.origin.x = Clamp(frame.origin.x, NSMinX(screen), NSMaxX(screen) - size.width);
    frame.origin.y = Clamp(frame.origin.y, NSMinY(screen), NSMaxY(screen) - size.height);

    self.panel = [[PetPanel alloc] initWithContentRect:frame
                                             styleMask:NSWindowStyleMaskBorderless | NSWindowStyleMaskNonactivatingPanel
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
    self.panel.opaque = NO;
    self.panel.backgroundColor = NSColor.clearColor;
    self.panel.hasShadow = NO;
    self.panel.level = NSStatusWindowLevel;
    self.panel.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary;
    self.panel.acceptsMouseMovedEvents = YES;
    self.panel.contentView = [[NebulaView alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height)];
    [self.panel orderFrontRegardless];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication;
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}
