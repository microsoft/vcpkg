vcpkg_minimum_required(VERSION 2022-10-12)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO antlr/antlr4
    HEAD_REF master
    REF "v${VERSION}"
    SHA512 a52356410c95ec6d7128b856dcf4c20a17cdd041270d2c4d700ef02ea715c87a00a87c2ad560277424b300435c6e9b196c8bc9c9f50ae5b6804d8214b4d397d0
    PATCHES
        fix_build_4.11.1.patch
        set-export-macro-define-as-private.patch
)

set(RUNTIME_PATH "${SOURCE_PATH}/runtime/Cpp")

message(INFO "Configure at '${RUNTIME_PATH}'")

vcpkg_cmake_configure(
    SOURCE_PATH "${RUNTIME_PATH}"
    OPTIONS
        -DANTLR4_INSTALL=ON
        -DANTLR_BUILD_CPP_TESTS=OFF
    OPTIONS_DEBUG
        "-DLIB_OUTPUT_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/dist"
    OPTIONS_RELEASE
        "-DLIB_OUTPUT_DIR=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/dist"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME antlr4-generator CONFIG_PATH lib/cmake/antlr4-generator DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(PACKAGE_NAME antlr4-runtime CONFIG_PATH lib/cmake/antlr4-runtime)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
