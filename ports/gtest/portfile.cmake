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
)

if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(gtest_force_shared_crt YES)
else()
    set(gtest_force_shared_crt NO)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -Dgtest_force_shared_crt=${gtest_force_shared_crt}
)

set(ENV{_CL_} "/D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING")

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/googletest/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtest RENAME copyright)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin/)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest.dll ${CURRENT_PACKAGES_DIR}/bin/gtest.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest_main.dll ${CURRENT_PACKAGES_DIR}/bin/gtest_main.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock.dll ${CURRENT_PACKAGES_DIR}/bin/gmock.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock_main.dll ${CURRENT_PACKAGES_DIR}/bin/gmock_main.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin/)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gtest.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest_main.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gtest_main.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gmock.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock_main.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gmock_main.dll)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gtest.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest_main.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gtest_main.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gmock.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock_main.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gmock_main.lib)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gtest.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest_main.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gtest_main.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gmock.lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock_main.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gmock_main.lib)

vcpkg_copy_pdbs()
