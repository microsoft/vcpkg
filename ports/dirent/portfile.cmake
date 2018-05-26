if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tronkko/dirent
    REF 1.23.1
    SHA512 13c59f0d225ccc09a2b92a29b41b6644dabdb0b39df7bb528d5ac60dbe71a2770eaa37d3890e0df21065bc798e9cc018e174d34c6697da7da665caafe062bbc2
    HEAD_REF master
)
file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/dirent RENAME copyright)
vcpkg_copy_pdbs()
