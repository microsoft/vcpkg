include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/cppfs
    REF v1.2.0
    SHA512 2e831978dd87bd40d14e5b6f5089f3a962481d41959bfd62db543339d05e306315a1167c3bc06b372517357cc314f7d06ac19605f9a2d5b4edddc9a1f3fa8d03
    HEAD_REF master
    PATCHES
        LibCrypto-fix.patch
        cmake-export-fix.patch
)

if(${TARGET_TRIPLET} MATCHES "uwp")
    message(FATAL_ERROR "cppfs does not support uwp")
endif()

set(SSH_BACKEND OFF)
if("ssh" IN_LIST FEATURES)
    set(SSH_BACKEND ON)
    if("${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "arm64")
        message(FATAL_ERROR "SSH backend of cppfs does not support arm64.")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPTION_BUILD_SSH_BACKEND=${SSH_BACKEND}
        -DOPTION_BUILD_TESTS=Off
        -DOPTION_FORCE_SYSTEM_DIR_INSTALL=On
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppfs RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME cppfs)
