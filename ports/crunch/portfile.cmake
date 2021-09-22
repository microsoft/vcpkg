vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rouault/crunch
    REF 079b071dfc24d309fb22fa41ccd94a0a156cdb52
    SHA512   486f1a3d25c777d93027579ded5f6838d3d056c020a9e4536cc669d78f999794ebab1fb311be575cc816e9918a9e8d4f4e7c80fea30329667401780ad7f96775
    HEAD_REF build_fixes
    PATCHES
        osx.patch
        arm-uwp.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool BUILD_TOOL
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES crunch_exe AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/license.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)