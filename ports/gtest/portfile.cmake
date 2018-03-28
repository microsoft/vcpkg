include(vcpkg_common_functions)

if (EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/googletest
    REF release-1.8.0
    SHA512 1dbece324473e53a83a60601b02c92c089f5d314761351974e097b2cf4d24af4296f9eb8653b6b03b1e363d9c5f793897acae1f0c7ac40149216035c4d395d9d
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Enable-C-11-features-for-VS2015-fix-appveyor-fail.patch
            ${CMAKE_CURRENT_LIST_DIR}/0002-Fix-z7-override.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" GTEST_FORCE_SHARED_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_GMOCK=ON
        -DBUILD_GTEST=ON
        -DCMAKE_DEBUG_POSTFIX=d
        -Dgtest_force_shared_crt=${GTEST_FORCE_SHARED_CRT}
)

set(ENV{_CL_} "/D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING")

vcpkg_install_cmake()

file(
    INSTALL
        "${SOURCE_PATH}/googletest/src/gtest.cc"
        "${SOURCE_PATH}/googletest/src/gtest_main.cc"
        "${SOURCE_PATH}/googletest/src/gtest-all.cc"
        "${SOURCE_PATH}/googletest/src/gtest-death-test.cc"
        "${SOURCE_PATH}/googletest/src/gtest-filepath.cc"
        "${SOURCE_PATH}/googletest/src/gtest-internal-inl.h"
        "${SOURCE_PATH}/googletest/src/gtest-port.cc"
        "${SOURCE_PATH}/googletest/src/gtest-printers.cc"
        "${SOURCE_PATH}/googletest/src/gtest-test-part.cc"
        "${SOURCE_PATH}/googletest/src/gtest-typed-test.cc"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/src
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/googletest/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtest RENAME copyright)

# This block will be unnecessary in googletest 1.9.0 (or later).
# These dll files are installed in ../bin directory by default settings.
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/gtest.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin/)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest.dll ${CURRENT_PACKAGES_DIR}/bin/gtest.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest_main.dll ${CURRENT_PACKAGES_DIR}/bin/gtest_main.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock.dll ${CURRENT_PACKAGES_DIR}/bin/gmock.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock_main.dll ${CURRENT_PACKAGES_DIR}/bin/gmock_main.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/gtestd.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin/)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtestd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gtestd.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest_maind.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gtest_maind.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmockd.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gmockd.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock_maind.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gmock_maind.dll)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/gtest.lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gtest.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest_main.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gtest_main.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gmock.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock_main.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gmock_main.lib)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/gtestd.lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtestd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gtestd.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest_maind.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gtest_maind.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmockd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gmockd.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock_maind.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gmock_maind.lib)
endif()

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
