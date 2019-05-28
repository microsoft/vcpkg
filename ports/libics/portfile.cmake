include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svi-opensource/libics
    REF b9532b738ad7f17569dfcaae74eb53d3c2959394
    SHA512 a7c0d89125570021494feaf0a187e3a1695e92c85a03d59ac9729618cdddb2ae13af94e4ce93241acbbb9d28465f75297bf03f2c46061bb7a0bba7ec28a23da4
    HEAD_REF master
    PATCHES
        cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/GNU_LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libics)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libics/GNU_LICENSE ${CURRENT_PACKAGES_DIR}/share/libics/copyright)