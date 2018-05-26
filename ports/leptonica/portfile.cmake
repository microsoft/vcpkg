include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF 1.74.4
    SHA512 3b9d0be937883f733f72cbdf0b624ec245d9256a8b4622997f437d309efd7ad9695ad1cbe2224d543eb3ef8c44833567b3cc9a95e9a774ef9046b7acaf0ae744
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/fix-cmakelists.patch
        ${CMAKE_CURRENT_LIST_DIR}/use-tiff-libraries.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSTATIC=${STATIC}
        -DCMAKE_REQUIRED_INCLUDES=${CURRENT_INSTALLED_DIR}/include # for check_include_file()
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

# Handle copyright
file(COPY ${SOURCE_PATH}/leptonica-license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/leptonica)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/leptonica/leptonica-license.txt ${CURRENT_PACKAGES_DIR}/share/leptonica/copyright)
