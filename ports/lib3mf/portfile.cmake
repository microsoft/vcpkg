include(vcpkg_execute_required_process)

set(VCPKG_BUILD_TYPE release) 

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vijaiaeroastro/3mfExamples/releases/download/2.3.1/lib3mf-2.3.1-complete.zip"
    FILENAME "lib3mf-2.3.1.zip"
    SHA512 6b382ef71a3af0395bd49101fcf580d92c151b309f47cf7f7d5d2988ba2feb0b67a91820e0d6b9c75b677b8095593362d3689b7c723cc71e9e9c404d7f062af7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)


# Proceed with the usual build process
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DLIB3MF_TESTS=OFF
)

# Install the package
vcpkg_cmake_install()


# Copy all PDB's
vcpkg_copy_pdbs()

# Install the license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Remove some of the debug stuff
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")