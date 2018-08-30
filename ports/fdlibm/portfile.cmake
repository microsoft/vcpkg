include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)
vcpkg_download_distfile(ARCHIVE
    URLS "https://android.googlesource.com/platform/external/fdlibm/+archive/59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac.tar.gz"
    FILENAME "fdlibm-59f7335e4dd8275a7dc2f8aeb4fd00758fde37ac.tar.gz"
    SHA512 bb998648429c8977a7d574e01689ef6ee04b4b25c0850a61087a5c79fa91e0e43da99061fd38bcff56c8e7a8347cf8c176c873bc8b05c3d3b036943c0734c7dd
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/libm5.def DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG 
    -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/NOTICE DESTINATION ${CURRENT_PACKAGES_DIR}/share/fdlibm RENAME copyright)
