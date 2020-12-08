vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nuspell/nuspell
    REF v4.0.1
    SHA512 122616fd24c2de35000ba12d680d3617e7fe97881d33febbcb106ce70d3bac356a00d90680a1bc8ee631ed532ace0f4b4f9fce4760a25b0f7fc1d60553e74528
    HEAD_REF master
    PATCHES cmake-disable-cli-and-docs.patch
    # This patch disables building the CLI tool and leaves only the library.
    # That is because Vcpkg complains when it finds .exe files in the folder
    # "bin". Instead it expects them under "tools", which is different
    # convention than on Unixes. This patch is quick fix, the CLI is not
    # that important.
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
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)
file(
    INSTALL ${SOURCE_PATH}/COPYING.LESSER
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright)
