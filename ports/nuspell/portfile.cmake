vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nuspell/nuspell
    REF v5.0.0
    SHA512 92605c5f0d413b86711fea3b993d656552d5e72440303d3e71907a503d060ead032dfeb0dd8dbb790f35599b8cca8854bdd8650f0560793d9c62a11aebccc2e5
    HEAD_REF master
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_TESTING=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nuspell)
vcpkg_fixup_pkgconfig(
    # nuspell.pc depends on icu-uc.pc which has -lm specified as private
    # library. Ignore this -lm, otherwise this function shows error
    # because it can't find this. -lm is part of glibc on Linux.
    SYSTEM_LIBRARIES m
)
vcpkg_copy_tools(TOOL_NAMES nuspell AUTO_CLEAN)
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)
file(
    INSTALL ${SOURCE_PATH}/COPYING.LESSER
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)
