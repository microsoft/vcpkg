vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-crt-cpp
    REF 9ef58ff20df19e613c91c5f761e381c763da6810 # v0.15.1
    SHA512 3409b3e6a546ed585b90180807383e8731b36b0db149b5ff92701a43164c4282b1cea4a551bf4c7b1edec7b264098575cf919faee8a2520bb10bbae62258d463
    PATCHES
        fix-cmake-target-path.patch
        fix-ios-build.patch
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
