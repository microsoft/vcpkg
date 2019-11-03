include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/KDSoap
    REF 7585cce5cb516f64ae89a962c3856fb456bd50f2 #kdsoap-1.8.0 tag
    SHA512 6e2b9e39e2c23fdf0434d4d9bd1e852dde1fc0afa51ad2db889bdcd5c4a6f444b8e1d88bb00b9a5adda9af41b9662cb34fdf2a749f2e5481d472dd56f9bada6f
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
        -DKDSoap_TESTS=False
        -DKDSoap_STATIC=${BUILD_STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KDSoap TARGET_PATH share/KDSoap)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
