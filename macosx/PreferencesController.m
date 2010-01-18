
/**
 * OpenEmulator
 * Mac OS X Preferences Controller
 * (C) 2009 by Marc S. Ressl (mressl@umich.edu)
 * Released under the GPL
 *
 * Controls the preferences window.
 */

#import "PreferencesController.h"

@implementation PreferencesController

- (id) init
{
	self = [super initWithWindowNibName:@"Preferences"];

	if (self)
	{
		templateChooserViewController = [[TemplateChooserViewController alloc] init];
		[templateChooserViewController setDelegate:self];
	}
	
	return self;
}

- (void) dealloc
{
	[templateChooserViewController release];
	
	[super dealloc];
}

- (void) windowDidLoad
{
	[super windowDidLoad];
	
	NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"Preferences Toolbar"];
	NSString *selectedItemIdentifier = @"General";
	
	[toolbar setDelegate:self];
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar setSizeMode:NSToolbarSizeModeRegular];
	[toolbar setSelectedItemIdentifier:selectedItemIdentifier];
	[[self window] setToolbar:toolbar];
	[toolbar release];
	
    [self setView:selectedItemIdentifier];
	
	NSView *view = [templateChooserViewController view];
	[fTemplateChooserView addSubview:view];
	[view setFrameSize:[fTemplateChooserView frame].size];
	
	[self updateUseDefaultTemplate];
}

- (NSToolbarItem *) toolbar:(NSToolbar *) toolbar
	  itemForItemIdentifier:(NSString *) ident
  willBeInsertedIntoToolbar:(BOOL) flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:ident];
	
	if (!item)
		return nil;
	
	[item autorelease];
	
	if ([ident isEqualToString:@"General"])
	{
		[item setLabel:NSLocalizedString(@"General", "Preferences toolbar item label")];
		[item setImage:[NSImage imageNamed:@"PRGeneral.png"]];
		[item setTarget:self];
		[item setAction:@selector(selectView:)];
	}
	else if ([ident isEqualToString:@"Sound"])
	{
		[item setLabel:NSLocalizedString(@"Sound", "Preferences toolbar item label")];
		[item setImage:[NSImage imageNamed:@"PRSound.png"]];
		[item setTarget:self];
		[item setAction:@selector(selectView:)];
	}
	
	return item;
}

- (NSArray *) toolbarSelectableItemIdentifiers:(NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:@"General", @"Sound", nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *) toolbar
{
	return [self toolbarSelectableItemIdentifiers:toolbar];
}

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *) toolbar
{
	return [self toolbarSelectableItemIdentifiers:toolbar];
}

- (void) selectView:(id) sender
{
	[self setView:[sender itemIdentifier]];
}

- (void) setView:(NSString *) itemIdentifier
{
	NSView *view;
	if ([itemIdentifier isEqualToString:@"General"])
		view = fGeneralView;
	if ([itemIdentifier isEqualToString:@"Sound"])
		view = fSoundView;
	else
		view = fGeneralView;
	
    NSWindow *window = [self window];
    if ([window contentView] == view)
        return;
	
	[view setHidden:YES];
	
    NSRect windowRect = [window frame];
    float difference = (([view frame].size.height - 
						[[window contentView] frame].size.height) *
						[window userSpaceScaleFactor]);
    windowRect.origin.y -= difference;
    windowRect.size.height += difference;
	
    [window setContentView:view];
    [window setFrame:windowRect display:YES animate:YES];
    [view setHidden:NO];
    
	[window setTitle:NSLocalizedString(itemIdentifier, "Preferences view")];
}

- (void) updateUseDefaultTemplate
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[self setUseDefaultTemplate:[userDefaults boolForKey:@"OEUseDefaultTemplate"]];
}

- (void) setUseDefaultTemplate:(BOOL) useDefaultTemplate
{
	NSString *useTemplateString = NSLocalizedString(@"Use template: ", "Use template: ");
	NSString *defaultTemplate = [[NSUserDefaults standardUserDefaults]
								 stringForKey:@"OEDefaultTemplate"];
	if (defaultTemplate)
	{
		NSString *defaultTemplateName = [[defaultTemplate lastPathComponent]
										 stringByDeletingPathExtension];
		useTemplateString = [useTemplateString stringByAppendingString:defaultTemplateName];
	}
	
	[fShowTemplateChooserRadio setIntValue:!useDefaultTemplate];
	[fUseTemplateRadio setIntValue:useDefaultTemplate];
	[fUseTemplateRadio setTitle:useTemplateString];
	[fChooseTemplateButton setEnabled:useDefaultTemplate];
	
	if ((defaultTemplate == nil) && useDefaultTemplate)
		[self chooseDefaultTemplate:self];
	else
		[[NSUserDefaults standardUserDefaults] setBool:useDefaultTemplate
												forKey:@"OEUseDefaultTemplate"];
}

- (IBAction) selectUseDefaultTemplate:(id) sender
{
	[self setUseDefaultTemplate:[[sender selectedCell] tag]];
}

- (IBAction) chooseDefaultTemplate:(id) sender
{
	[templateChooserViewController updateUserTemplates];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [userDefaults stringForKey:@"OEDefaultTemplate"];
	[templateChooserViewController selectItemWithPath:path];
	
	[fTemplateChooserChooseButton setEnabled:
	 ([templateChooserViewController selectedItemPath] != nil)];
	
	[NSApp beginSheet:fTemplateChooserSheet
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo:nil];
}

- (void) chooserWasDoubleClicked:(id) sender
{
	[self chooseTemplateInSheet:sender];
}

- (IBAction) chooseTemplateInSheet:(id) sender
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[templateChooserViewController selectedItemPath]
					 forKey:@"OEDefaultTemplate"];
	[userDefaults setBool:YES
				   forKey:@"OEUseDefaultTemplate"];
	
	[self closeTemplateSheet:sender];
}

- (IBAction) closeTemplateSheet:(id) sender
{
	[NSApp endSheet:fTemplateChooserSheet];
}

- (void) didEndSheet:(NSWindow *) sheet
		  returnCode:(int) returnCode
		 contextInfo:(void *) contextInfo
{ 
    [sheet orderOut:self];
	
	[self updateUseDefaultTemplate];
}

@end