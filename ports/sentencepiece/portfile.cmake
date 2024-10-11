if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/sentencepiece
    REF "v${VERSION}"
    SHA512 b4214f5bfbe2a0757794c792e87e7c53fda7e65b2511b37fc757f280bf9287ba59b5d630801e17de6058f8292a3c6433211917324cb3446a212a51735402e614
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSPM_ENABLE_SHARED=OFF
        -DSPM_USE_BUILTIN_PROTOBUF=ON
        -DSPM_USE_EXTERNAL_ABSL=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_copy_tools(TOOL_NAMES spm_decode spm_encode spm_export_vocab spm_normalize spm_train AUTO_CLEAN)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()
