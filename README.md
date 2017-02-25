vcsh - Version Control System for $HOME - multiple Git repositories in $HOME

# Refactoring branch

The purpose of this branch is to gradually massage the existing vcsh code into
a more manageable form while preserving its current behavior.  Goals include
dividing the code into meaningful functions, removing global variables in
favor of function arguments and return/output, adding explanatory comments,
and writing unit tests.

## Behavior changes

While a good bit of refactoring can be done without changing the behavior of
vcsh at all, there are limits to how much cleanup can be done under that
constraint.  For instance, any internal variable which is exported is then
visible to subcommands of `run` and the subshell of `enter`.  Changing or
removing any of these would technically change the user-visible behavior of
vcsh, even though the actual impact on users may be virtually nonexistent.

Currently, the following known behavior changes exist:
- The order in which overlays are sourced may differ.  In the original code,
  repo-specific overlays (e.g. `config.d/vim`) are sourced before
  command-specific overlays (`config.d/push`).  In the refactored code,
  this is the other way around.  Overlays which are specific to both repo and
  command (`config.d/vim.push`) are still sourced last.

### Proposed

We have made every effort to be conservative with respect to behavior changes
so far.  However, if/when we identify any behaviors that could lead to better
code cleanup if it were changed, we will post them here for consideration.

- `VCSH_COMMAND` is visible in subshells
- `VCSH_DIRECTORY` is visible in subshells
- The hook that runs at the end of the clone operation is `post_retire`;
  `post_clone` happens prior to that.
- There are no hooks for delete, list, list-tracked, list-untracked, rename,
  status, or which.
- The rename command accepts/mangles a directory for the source repo but not
  for the destination.

## Bugs

The following are bugs or oddities that we have noticed while working with the
vcsh codebase.  This is currently just for the record; fixing these is not our
focus.  However, if it should happen that a code cleanup step would fix a
known bug, we may be less shy about making it...

- `VCSH_GITATTRIBUTES` is not validated like other input variables
- Several variables, if defined prior to running vcsh, can interfere with its
  operation.  Among these are `$VCSH_CONFLICT`, `$ran_once`, and potentially
  `$VCSH_REPO_NAME` (may have been fixed).
- Any pre-existing `$VCSH_OPTION_CONFIG` is sourced (intentional?)
- overlays are sourced for anything the command is a prefix of, meaning that
  any list-tracked overlays are also executed for list.
- .gitattributes.d and .gitignore.d files are auto-added even if
  `VCSH_GITIGNORE` or `VCSH_GITATTRIBUTES` is "none"
- rename does not also rename gitattributes/gitignore files
- push/pull/commit/? only return error if an error occurs for the *last* repo
- list-tracked outputs absolute paths whereas list-untracked outputs relative

### Fixed

- commands which do not set `VCSH_REPO_NAME` (e.g. which) attempt to source a
  directory
- If `$VCSH_COMMAND_RETURN_CODE` is defined prior to running vcsh, it can
  affect the eventual code returned in some cases.
