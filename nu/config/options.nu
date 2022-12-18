# Editor
load-env (
  let maybe_nvim = (which nvim);
  let editor = (if $maybe_nvim != null {
    ($maybe_nvim | first).path
  } else {
    (which vim | first).path
  });
  {
    EDITOR: $editor,
    VISUAL: $editor,
  }
)
