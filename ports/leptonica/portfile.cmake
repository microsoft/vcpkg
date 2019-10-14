include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DanBloomberg/leptonica
    REF 87b8219360bca3c9929a5705c3d9c50c42c34bca #1.78.0
    SHA512 b7bfa9437be7e3d9276acacf8f62ccda1cd8f88741ada5106ef0232d4965617be2c5d0b8a6b4462896a1a0b6b44d9ecefd6e6b8d0e50d4fb881bdf5e821703a4
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
        use-tiff-libraries.patch
        find-dependency.patch
        fix-find-libwebp.patch
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

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/leptonica-license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/leptonica-license.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)
