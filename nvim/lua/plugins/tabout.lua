-- Maps global <Tab>/<S-Tab>; blink.cmp's keymap falls back to these when
-- there's no completion or snippet to act on (see blinkcmp.lua).
require("tabout").setup({
  tabkey = "<Tab>",
  backwards_tabkey = "<S-Tab>",
  act_as_tab = true, -- insert a normal tab when there's nothing to tab out of
  act_as_shift_tab = false,
  enable_backwards = true,
  completion = false, -- blink.cmp handles its own menu, not the builtin pum
  ignore_beginning = true,
})
