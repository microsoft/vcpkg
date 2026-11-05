vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stiffstream/sobjectizer
    REF "v${VERSION}"
    SHA512 8ebfcdbe2a18b0ba658c5ce126d96659b8737ae929f3d2dffb7dc12ed3fcbc0420f26472fa075e27a3c5c13408cbe7bf1b70e7c395e5004acd9571851074233c
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SOBJECTIZER_BUILD_STATIC )
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOBJECTIZER_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/dev"
    OPTIONS
        -DSOBJECTIZER_BUILD_STATIC=${SOBJECTIZER_BUILD_STATIC}
        -DSOBJECTIZER_BUILD_SHARED=${SOBJECTIZER_BUILD_SHARED}
)

vcpkg_cmake_install()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/so_5/declspec.hpp" "defined( SO_5_STATIC_LIB )" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/sobjectizer)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
