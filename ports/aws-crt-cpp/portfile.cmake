vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-crt-cpp
    REF 3e0083069723aa263353edaec6fc635b6c85e182 # v0.19.3
    SHA512 28ad8be9e5c417a281ee6045e0c73f5c48fbb9d98815bc85d0698c5da4b9b5c6c3d96f13bee5fc12433f50bf1782cf1135be11cadf5df0ef78df7508dd74fa24
    PATCHES
        fix-cmake-target-path.patch
        no-werror.patch
        fix-cmake-config-file.patch
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
