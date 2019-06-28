include(vcpkg_common_functions)

if (NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "${PORT} currently only supports x64 architecture.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmem/pmdk-convert
    REF  1.5.1
    SHA512 5c23a3f1d0daf20ef76d7b4cd137ae5570bb4cba2a4ddb000981bc649681ba5167ef60d56f8fad6793840e550d9abd764dafa8661d2115388a5faa9ad4bb41d6
    HEAD_REF master
    PATCHES
    fix-file-path.patch
    fix-include-and-targets-bug.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS 
    -DMIN_VERSION=1.5
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/pmdk-convert.exe)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/pmdk-convert.exe)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)