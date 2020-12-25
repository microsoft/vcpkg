vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/cppfs
    REF 156d72e2cf0a9b12bdce369fc5b5d98fb5dffe2d # v1.3.0
    SHA512 da1e09f79d9e65e7676784f47196645aabe1e1284f0ea5e48e845a244f5d49f5ea4b032f9e2e38c8e6a29657ebe636c9b1c9a4601c4bbc7637e7f592c52a8961
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
