vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eidheim/tiny-process-library
    REF 273270d0f9d0cf4a8282fadd589060a7b0eab425
    SHA512 f99e586ee6fa9b7c0a3633b59e0e099becba48e2ef375268eeecd9099a233e3b528ba373edc74983d49934ff10f99884fdeb594ff546054fc91d1341d0e86c0a
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/unofficial-${PORT}
    TARGET_PATH share/unofficial-${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
