if (EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/googletest
    REF "v${VERSION}"
    SHA512 bec8dad2a5abbea8e9e5f0ceedd8c9dbdb8939e9f74785476b0948f21f5db5901018157e78387e106c6717326558d6642fc0e39379c62af57bf1205a9df8a18b
    HEAD_REF main
    PATCHES
        001-fix-UWP-death-test.patch
        clang-tidy-no-lint.patch
        fix-main-lib-path.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" GTEST_FORCE_SHARED_CRT)

set(GTEST_USE_CXX17_OPTION "")
if("cxx17" IN_LIST FEATURES)
    set(GTEST_USE_CXX17_OPTION "-DCMAKE_CXX_STANDARD=17")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_GMOCK=ON
        -Dgtest_force_shared_crt=${GTEST_FORCE_SHARED_CRT}
        ${GTEST_USE_CXX17_OPTION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/GTest)

file(
    INSTALL
        "${SOURCE_PATH}/googletest/src/gtest.cc"
        "${SOURCE_PATH}/googletest/src/gtest_main.cc"
        "${SOURCE_PATH}/googletest/src/gtest-all.cc"
        "${SOURCE_PATH}/googletest/src/gtest-assertion-result.cc"
        "${SOURCE_PATH}/googletest/src/gtest-death-test.cc"
        "${SOURCE_PATH}/googletest/src/gtest-filepath.cc"
        "${SOURCE_PATH}/googletest/src/gtest-internal-inl.h"
        "${SOURCE_PATH}/googletest/src/gtest-matchers.cc"
        "${SOURCE_PATH}/googletest/src/gtest-port.cc"
        "${SOURCE_PATH}/googletest/src/gtest-printers.cc"
        "${SOURCE_PATH}/googletest/src/gtest-test-part.cc"
        "${SOURCE_PATH}/googletest/src/gtest-typed-test.cc"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/src
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_pkgconfig()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gmock_main.pc" "libdir=\${prefix}/lib" "libdir=\${prefix}/lib/manual-link")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gtest_main.pc" "libdir=\${prefix}/lib" "libdir=\${prefix}/lib/manual-link")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gmock_main.pc" "libdir=\${prefix}/lib" "libdir=\${prefix}/lib/manual-link")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gtest_main.pc" "libdir=\${prefix}/lib" "libdir=\${prefix}/lib/manual-link")
endif()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
