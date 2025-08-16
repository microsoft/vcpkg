if(VCPKG_HOST_IS_WINDOWS)
    set(USE_GLAD -DNANOGUI_USE_GLAD=ON)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
else()
    set(USE_GLAD -DNANOGUI_USE_GLAD=OFF)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wjakob/nanogui
    REF e9ec8a1a9861cf578d9c6e85a6420080aa715c03 # Commits on Sep 23, 2019
    SHA512 36c93bf977862ced2df4030211e2b83625e60a11fc9fdb6c1f2996bb234758331d3f41a7fbafd25a5bca0239ed9bac9c93446a4a7fac4c5e6d7943af2be3e14a
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        fix-glad-dependence.patch
        fix-release-build.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "example" NANOGUI_BUILD_EXAMPLE
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DNANOGUI_EIGEN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/eigen3
        -DEIGEN_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include/eigen3
        -DNANOGUI_BUILD_SHARED=${BUILD_SHARED}
        ${USE_GLAD}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
