vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kmammou/v-hacd
    REF 1a49edf29c69039df15286181f2f27e17ceb9aef
    SHA512 14157e5fd9cbfeb44735dc2952d7b4f43337ea2243f3b690125dda27e3bb8328cc38050415c7150cf11fbd85c5258c3aaa8899f306ce118f78a4d5e6139ef0f0
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(LIB_TYPE "SHARED")
else()
    set(LIB_TYPE "STATIC")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        openmp NO_OPENMP
        opencl NO_OPENCL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIB_TYPE=${LIB_TYPE}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/vhacd)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
