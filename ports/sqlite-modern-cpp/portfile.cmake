# header only
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/sqlite_modern_cpp-3.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aminroosta/sqlite_modern_cpp/archive/v3.2.tar.gz"
    FILENAME "sqlite_modern_cpp-3.2.tar.gz"
    SHA512 7e54cc41713247c9f6373a441854e8dace8e334e6ee29f870f11bc3fd3b53b5cff4e1a6d4c7e3cda33509b70a3f9a47363922a589b9a6d0730ce6dc0c884d878
)
vcpkg_extract_source_archive(${ARCHIVE})

file(INSTALL ${SOURCE_PATH}/hdr/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp)
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlite-modern-cpp RENAME copyright)
