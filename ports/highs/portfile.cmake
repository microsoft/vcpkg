vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ERGO-Code/HiGHS
    REF v${VERSION}
    SHA512 4780fd4338e144b5639f00bffed4075ee7260479d904270c704c8220a6e2f0379a7ff167ba6a64587f897b86b99e24d5dea7b6817decfd8534fc832e2c925fa4
    HEAD_REF master
    PATCHES
        respect-user-selected-compiler.patch
        fix-extras-metadata.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        extras HIPO
)

set(HIGHS_EXTRAS_BLAS_OPTIONS "")
if("extras" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_OSX)
    # HiGHS's own BLAS discovery (cmake/FindHipoDeps.cmake) prefers OpenBLAS's
    # own CMake package over the generic find_package(BLAS) module whenever
    # it can find one, which would leave highs_extras linked against
    # OpenBLAS::OpenBLAS instead of the BLAS::BLAS target that vcpkg's "blas"
    # port (and thus any consumer's find_package(highs)) resolves. Forcing a
    # non-empty BLA_VENDOR here skips that preferential lookup so the build
    # goes through find_package(BLAS) instead, which the "blas" port's
    # vcpkg-cmake-wrapper.cmake intercepts and resolves consistently.
    list(APPEND HIGHS_EXTRAS_BLAS_OPTIONS -DBLA_VENDOR=OpenBLAS)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${HIGHS_EXTRAS_BLAS_OPTIONS}
        -DFAST_BUILD=ON
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
        -DBUILD_SHARED_EXTRAS_LIB=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(TOOL_NAMES highs AUTO_CLEAN)

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/highs")
set(HIGHS_COPYRIGHT_FILES
    "${SOURCE_PATH}/LICENSE.txt"
    "${SOURCE_PATH}/THIRD_PARTY_NOTICES.md"
    "${SOURCE_PATH}/extern/cli11/CLI11.hpp"
    "${SOURCE_PATH}/extern/pdqsort/license.txt"
    "${SOURCE_PATH}/extern/zstr/LICENSE"
)
if("extras" IN_LIST FEATURES)
    # amd, metis/GKlib, and rcm are only compiled in when HIPO (the "extras" feature) is enabled.
    list(APPEND HIGHS_COPYRIGHT_FILES
        "${SOURCE_PATH}/extern/amd/License.txt"
        "${SOURCE_PATH}/extern/metis/LICENSE.txt"
        "${SOURCE_PATH}/extern/rcm/LICENSE"
    )
endif()
vcpkg_install_copyright(FILE_LIST ${HIGHS_COPYRIGHT_FILES})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
