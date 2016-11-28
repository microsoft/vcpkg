include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/aws-sdk-cpp-1.0.34)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aws/aws-sdk-cpp/archive/1.0.34.tar.gz"
    FILENAME "1.0.34.tar.gz"
    SHA512 21ca03eb323eecb55c29866b73c07956a36aad7c9c051eb7ca201cfd356c3f9732c89898cf0c89660d6c1279dc52438bb389b37d613bf741bae81bb3e773a3c5
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES 
		${CMAKE_CURRENT_LIST_DIR}/drop_git.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-sdk-cpp RENAME copyright)