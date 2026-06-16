path:
{
  lib,
  config,
  util,
  pkgs,
  ...
}:
let
  cfg = util.getOptions path config;
in
{
  options = util.mkOptions path {
    prompt = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = ''
        ---
        description: Global interaction preferences
        alwaysApply: true
        ---

        # CRITICAL

        Never modify files without explicitly asking for confirmation first.

        This means:
        1. When you identify issues (compilation errors, bugs, improvements), STOP
        2. Describe the issue and propose the fix
        3. Ask: "Should I apply these changes?"
        4. Wait for user confirmation
        5. Only then use StrReplace/Write/etc.

        This applies to:
        - Compilation errors (even "obvious" fixes)
        - Bug fixes
        - Refactoring
        - Code improvements
        - Following up on previous work
        - "Small" changes

        NO EXCEPTIONS. If you're about to use StrReplace/Write/EditNotebook, ask yourself:
        "Did the user explicitly confirm THIS specific change in their last message?"
        If no, STOP and ask first.

        The only time you can modify without asking is if the user's message contains explicit approval like:
        - "Yes"
        - "Proceed"
        - "Apply the changes"
        - "Do it"

        Even phrases like "What else is missing?" or "Do we need to do anything else?" are NOT approval to make changes - they're questions that require you to report findings first.

        # IMPORTANT
        Avoid many file changes at once. If you are about to modify multiple files, consider pausing between each file if the changes are more than 50 lines.
      '';
    };
  };

  config = util.enforceHome path config cfg.enable {
    home-manager = {
      home = {
        packages = [ pkgs.cursor-cli ];
        file = {
          ".cursor/rules/global.mdc".text = cfg.prompt;
        };
      };
    };
  };
}
