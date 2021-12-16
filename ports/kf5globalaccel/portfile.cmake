vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kglobalaccel
    REF v5.88.0
    SHA512 cf0e9c2414944efc0e612ef9db171ac861a7fb686bd1f5ba2eb8e6e4bbc96b4970b41bb3811bc11145124f5ec3ad3b87d2b7933b482d5240413b355cb47a3306
    HEAD_REF master
    PATCHES
        xcb_xtest_optional.diff # https://invent.kde.org/frameworks/kglobalaccel/-/merge_requests/30
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5GlobalAccel CONFIG_PATH lib/cmake/KF5GlobalAccel)
vcpkg_copy_pdbs()

vcpkg_copy_tools(
    TOOL_NAMES kglobalaccel5
    AUTO_CLEAN
 )

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
