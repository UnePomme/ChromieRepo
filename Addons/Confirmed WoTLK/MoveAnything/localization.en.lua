local addonname, modRef = ...

_G["MOVANY"] = modRef
MOVANY.RESET_FRAME_CONFIRM = "Reset %s? Press again within 5 seconds to confirm"
MOVANY.RESETTING_FRAME = "Resetting %s"
MOVANY.FRAME_PROTECTED_DURING_COMBAT = "Can't interact with %s during combat"
MOVANY.DISABLED_DURING_COMBAT = "Disabled during combat"
MOVANY.UNSUPPORTED_TYPE = "Unsupported type: %s"
MOVANY.UNSUPPORTED_FRAME = "Unsupported frame: %s"
MOVANY.FRAME_VISIBILITY_ONLY = "%s can only be hidden"
MOVANY.ONLY_WHEN_VISIBLE = "%s can only be modified while it's shown on the screen"
MOVANY.MAX_MOVERS = "You can only move %i frames at once"
MOVANY.ELEMENT_NOT_FOUND = "UI element not found"
MOVANY.ELEMENT_NOT_FOUND_NAMED = "UI element not found: %s"
MOVANY.PROFILES_CANT_SWITCH_DURING_COMBAT = "Profiles can't be switched during combat"
MOVANY.CMD_SYNTAX_UNMOVE = "Syntax: /unmove framename"
MOVANY.CMD_SYNTAX_IMPORT = "Syntax: /moveimport ProfileName"
MOVANY.CMD_SYNTAX_EXPORT = "Syntax: /moveexport ProfileName"
MOVANY.CMD_SYNTAX_DELETE = "Syntax: /movedelete ProfileName"
MOVANY.CMD_SYNTAX_HIDE = "Syntax: /hide ProfileName"
MOVANY.RESET_ALL_CONFIRM = "MoveAnything: Reset MoveAnything to installation state?\n\nWarning: this will delete all frame settings and clear out the custom frame list."
MOVANY.PROFILE_UNKNOWN = "Unknown profile: %s"
MOVANY.PROFILE_IMPORTED = "Profile imported: %s"
MOVANY.PROFILE_EXPORTED = "Profile exported: %s"
MOVANY.PROFILE_DELETED = "Profile deleted: %s"
MOVANY.PROFILE_RESET_CONFIRM = "MoveAnything: Reset all frames in the current profile?"
MOVANY.PROFILE_CANT_DELETE_CURRENT_IN_COMBAT = "Can't delete current profile during combat"
MOVANY.PROFILES = "Profiles"
MOVANY.PROFILE_CURRENT = "Current"
MOVANY.FRAME_UNPOSITIONED = "%s is currently unpositioned and can't be moved till it is"
MOVANY.NO_NAMED_FRAMES_FOUND = "No named elements found"
MOVANY.SEARCH_TEXT = "Search    "
MOVANY.LIST_HEADING_CATEGORY_AND_FRAMES = "Categories and Frames"
MOVANY.LIST_HEADING_SEARCH_RESULTS = "Search results: %i"
MOVANY.LIST_HEADING_HIDE = "Hide"
MOVANY.LIST_HEADING_MOVER = "Mover"