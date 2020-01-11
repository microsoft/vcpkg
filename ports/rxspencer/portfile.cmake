vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO garyhouston/rxspencer
    REF e42b6a667f1385aedf49b533b9fbba58e5a26934
    SHA512 2842e1c78c3ebbbd03d15fb85e55f861740bb446aa57157f3fc90876d931d9f865242f5eaefc94f31c8d78e0d531a008d4c579e9b4f9c7179f5c7a95a98359fd
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DCMAKE_CONFIG_DEST=share/rxspencer
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "share/rxspencer")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/regex)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/rxspencer RENAME copyright)

vcpkg_copy_pdbs()
