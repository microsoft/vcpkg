vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jkriege2/TinyTIFF
    REF ${VERSION}
    SHA512 28fb3d1ef1630a4d20da021ccca93f99df8bd29462525be312dfb028239176ca940a43407b2db10488d891a1fbca65d8a59bc6cc097765389f35021e8b423885
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BUILD_SHARED_LIBS OFF)
else()
    set(BUILD_SHARED_LIBS ON)
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "winapi"    TinyTIFF_USE_WINAPI_FOR_FILEIO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTinyTIFF_BUILD_TESTS=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TinyTIFF)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/TinyTIFFXX)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
