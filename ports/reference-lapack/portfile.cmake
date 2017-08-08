include(vcpkg_common_functions)

set(LAPACK_VERSION "3.7.1")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "Reference-LAPACK/lapack"
    REF "v${LAPACK_VERSION}"
    SHA512 84fab803ee7535dcc7e32b1e7ca3d0bab1e427f715f360a2e7ccb2d529d857c95d20ef83ab3783e30f6e4c3e7407bc4546fc8245d8c31e5879a2dbd60b3ca91f
    HEAD_REF "master"
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-include-order.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-try-compile-fortran-flags.patch
)

vcpkg_enable_fortran()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
        -DBUILD_TESTING=OFF
        -DCBLAS=ON
        -DLAPACKE=ON
)

vcpkg_install_cmake()

# We can just move this files because the relative depths of this directories 
# lib/cmake/lapack-${LAPACK_VERSION} and share/reference-lapack/cmake is the same 
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/lapack-${LAPACK_VERSION}/lapack-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/reference-lapack/cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/lapack-${LAPACK_VERSION}/lapack-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/reference-lapack/cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/lapack-${LAPACK_VERSION}/lapack-targets.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/reference-lapack/cmake)
file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/lapack-${LAPACK_VERSION}/lapack-targets-release.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/reference-lapack/cmake)

file(READ ${CURRENT_PACKAGES_DIR}/debug/lib/cmake/lapack-${LAPACK_VERSION}/lapack-targets-debug.cmake LAPACK_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" LAPACK_DEBUG_MODULE "${LAPACK_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/reference-lapack/cmake/lapack-targets-debug.cmake "${LAPACK_DEBUG_MODULE}")

# Remove cmake and pkg-config leftovers 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

# Remove debug includes 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/reference-lapack)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/reference-lapack/LICENSE ${CURRENT_PACKAGES_DIR}/share/reference-lapack/copyright)
