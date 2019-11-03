include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDReports
    REF d719d0440e15ecaa0f739ae4c34b7ef207d94ea8 #kdreports-1.8.0 tag
    SHA512 538ad97fc7abfa827a03b4cbf2cbe8ec8e16b2e08335e35b637cc20fe6f4a15ed6a3f7247d80481f9fac61b918ad6509d78a53b016dfe82bef7dc17935bbf18b
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(BUILD_STATIC True)
else()
    set(BUILD_STATIC False)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DKDReports_TESTS=False
        -DKDReports_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KDReports TARGET_PATH share/KDReports)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

