# TODO: Write a little "plugin-manager"?

let-env COMPLETERS = []
let-env HOOKS = {}

# Modules
use plugins/git.nu *
use plugins/nali.nu *
use plugins/penv.nu *
use ~/code/rust/simpalt-rs/simpalt.nu *
