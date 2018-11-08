include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/sonnet
    REF v5.51.0
    SHA512 a863b98a3fb6bb7746e3c3b331b78d3a7b0ac9ea8d7a40561f2d5287333771f8441f3af0c73c171201a1234785593739beb8406018667015e15a67ca5d1ca341
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
            -DKDE_INSTALL_PLUGINDIR=plugins
)

vcpkg_add_to_path(${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/bin)
vcpkg_add_to_path(${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/bin)
vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/kf5sonnet)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/gentrigrams.exe ${CURRENT_PACKAGES_DIR}/tools/kf5sonnet/gentrigrams.exe)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/parsetrigrams.exe ${CURRENT_PACKAGES_DIR}/tools/kf5sonnet/parsetrigrams.exe)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Sonnet)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/kf5sonnet)
vcpkg_copy_pdbs()

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/gentrigrams.exe)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/parsetrigrams.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5sonnet RENAME copyright)
