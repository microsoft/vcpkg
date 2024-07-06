list(REMOVE_ITEM ARGS "NO_MODULE" "CONFIG" "MODULE")
vcpkg_underlying_find_package(${ARGS} CONFIG)
set(LIBXML2_FOUND "${LibXml2_FOUND}") # fphsa compatibility
