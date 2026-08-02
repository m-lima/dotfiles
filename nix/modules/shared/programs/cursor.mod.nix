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

        # CRITICAL — NO FILE CHANGES WITHOUT EXPLICIT APPROVAL

        ## Default mode: read-only

        Unless the user's **latest message** contains explicit approval to edit, you are in **read-only mode**.
        In read-only mode you may ONLY:

        - Read/search the codebase
        - Run non-destructive commands (build, test, git status, curl, etc.)
        - Explain, plan, propose diffs in chat, answer questions

        You may NOT use StrReplace, Write, Delete, EditNotebook, or any tool that creates, deletes, or modifies files.

        ## What counts as approval (ONLY these — exact intent, not inference)

        The user's **current message** must clearly authorize **editing files**, e.g.:

        - "Yes" / "Proceed" / "Apply the changes" / "Do it" / "Go ahead"
        - "Implement it" / "Make the changes" / "Write the code"
        - "Revert" / "Undo" / "Delete X" (when they ask you to change the repo)

        ## What is NOT approval (never infer permission from these)

        - Questions: "How does X work?", "What would you do?"
        - Design feedback: "I want a module", "not a separate crate", "make it generic"
        - Planning: "I was hoping to…", "I want…", "we need…"
        - Follow-ups: "What else is missing?", "Do we need anything else?"
        - Approval from a **previous** turn (each new task needs fresh approval)
        - You proposed a plan and the user replied without saying no

        If the user steers design, **update the plan and ask again** — do not edit.

        ## Required workflow before any file edit

        1. State what you will change (files + summary).
        2. Ask: **"Should I apply these changes?"**
        3. Wait for explicit approval in the **next** user message.
        4. If approval is ambiguous, ask — do not guess.

        ## Self-check (mandatory before every StrReplace/Write/Delete)

        Ask: "Did the user's **latest message** explicitly authorize editing files for **this** task?"
        If NO → stop and ask.

        ## Exceptions

        - User explicitly asked to revert/undo/delete in the current message.

        No other exceptions. "Obvious" fixes, "small" changes, and compilation errors still require approval.

        ## When proposing code

        Show proposed changes in chat (diff or new files) first.
        Do not apply them until the user approves.
        Never "implement while explaining" in the same turn as a plan.

        # IMPORTANT
        Avoid many file changes at once. If you are about to modify multiple files, consider pausing between each file if the changes are more than 50 lines in total.
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
