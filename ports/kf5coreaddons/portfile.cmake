vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kcoreaddons
    REF v5.87.0
    SHA512 bbba155cf347add1a364bd8a3d727096afa47bb91b9bdcf87abf9b66de9f5822e301f67531e8de186b3e912c7a20816aab11f31e4b64a0a00f5be1e8ba74f17e
    PATCHES
        fix_cmake_config.patch # https://invent.kde.org/frameworks/kcoreaddons/-/merge_requests/129
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE ${SOURCE_PATH}/.clang-format "DisableFormat: true\nSortIncludes: false\n")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME KF5CoreAddons CONFIG_PATH lib/cmake/KF5CoreAddons)
vcpkg_copy_pdbs()

vcpkg_copy_tools( 
    TOOL_NAMES desktoptojson
    AUTO_CLEAN
)

file(APPEND "${CURRENT_PACKAGES_DIR}/tools/${PORT}/qt.conf" "Data = ../../share")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")	
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSES/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
