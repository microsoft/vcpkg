list(REMOVE_ITEM ARGS "NO_MODULE" "CONFIG" "MODULE")
_find_package(${ARGS} CONFIG)
set(LIBXML2_FOUND "${LibXml2_FOUND}") # fphsa compatibility
