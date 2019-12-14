vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO garyhouston/rxspencer
    REF ca9dface691015093c3c35e4693d512025e49dfa
    SHA512 8c8e97949b17d1f286abfe03bcfdab0b455df9e71eca8489543857e47eb53e42cf09749cbc06973fa451aaa2855c44e3b0f2d5397949e89d0bdbe7fc09ee501d
    HEAD_REF master
    PATCHES 0001-Add-CMake-build-scripts-derived-from-LuaDist.patch
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
