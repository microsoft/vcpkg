vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-crt-cpp
    REF "v${VERSION}"
    SHA512 497bd9a127caaafe4b2a97c8f16fe3847085c59ac5ef43d1819bcb9cc6ad32fbd3d1ec507cb42810871a5e5ce08033a1a36aced0e250b2538bf905bf61459950
    PATCHES
        fix-cmake-target-path.patch
        no-werror.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        "-DSTATIC_CRT=${STATIC_CRT}"
        -DBUILD_DEPS=OFF
        "-DCMAKE_MODULE_PATH=${CURRENT_INSTALLED_DIR}/share/aws-c-common" # use extra cmake files
        -DBUILD_TESTING=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-crt-cpp/cmake)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/aws-crt-cpp"
    "${CURRENT_PACKAGES_DIR}/lib/aws-crt-cpp"
)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
