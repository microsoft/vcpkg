vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rafat/wavelib
    REF f104d084be91cc7e59dc3253bedceb11ece77136
    SHA512 5db4a3141e23ddaae0b5c6c1e119404343f2f6bef6b24ef94c99cd412f1d9d444512386484266cf4070f7572bbf69fca691f4f95a583dc46e2ea81ca1c147181
    HEAD_REF master
    PATCHES
        fix-uwp-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_UT=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
