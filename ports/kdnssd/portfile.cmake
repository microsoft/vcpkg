vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kdnssd
    REF "v${VERSION}"
    SHA512 aff23095a075a6a175396787149807ef71557075ee16abc3ce0b351ef0a4daa71992c9619bbccc20e889b80806a7d407dfe4d1343cd1a7e8762e684e51b87518
    HEAD_REF master
    PATCHES
        dbus-only-for-avahi.patch
        fix-static-dependencies.patch
        fix-dnssd-apple.patch
)

# Prevent KDEClangFormat from writing to source effectively blocking parallel configure
file(WRITE "${SOURCE_PATH}/.clang-format" "DisableFormat: true\nSortIncludes: false\n")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        translations KF_SKIP_PO_PROCESSING
)

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND FEATURE_OPTIONS -DCMAKE_REQUIRE_FIND_PACKAGE_Avahi=ON)
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libavahi-common-dev\n\nThese can be installed on Ubuntu systems via apt-get install libavahi-common-dev")
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND FEATURE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Avahi=ON -DCMAKE_REQUIRE_FIND_PACKAGE_DNSSD=ON)
else()
    list(APPEND FEATURE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_Avahi=ON -DCMAKE_DISABLE_FIND_PACKAGE_DNSSD=ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Tools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6ToolsTools=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Widgets=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME kf6dnssd CONFIG_PATH lib/cmake/KF6DNSSD)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(GLOB LICENSE_FILES "${SOURCE_PATH}/LICENSES/*")
vcpkg_install_copyright(FILE_LIST ${LICENSE_FILES})
