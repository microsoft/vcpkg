# Instead of official release, base on commit hash for now.
set(GAMMA_RELEASE_TAG "cc442ad0c5da369966cd937a96925c7b9a04e9e5")

include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/Gamma-${GAMMA_RELEASE_TAG})

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/LancePutnam/Gamma/archive/cc442ad0c5da369966cd937a96925c7b9a04e9e5.zip"
    FILENAME "gamma-${GAMMA_RELEASE_TAG}.zip"
    SHA512 de44f4d07db0b2cf09e77508d993273d09788dfa919d549393bb77534922b65e9d8a1b8193b4b02c72e6bc4dd060b41b18ff3520a36d4c28f6e2fb4b1e859ee7
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/gamma RENAME copyright)
