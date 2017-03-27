include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pybind11-2.0.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/pybind/pybind11/archive/v2.1.0.tar.gz"
    FILENAME "pybind11-2.1.0.tar.gz"
    SHA512 2f74dcd2b82d8e41da7db36351284fe04511038bec66bdde820da9c0fce92f6d2c5aeb2e48264058a91a775a1a6a99bc757d26ebf001de3df4183d700d46efa1
)
vcpkg_extract_source_archive(${ARCHIVE})

# link the MSVC runtime statically if set.
if(VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(CRUNTIME /MD)
else()
    set(CRUNTIME /MT)
endif()

vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/)


# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pybind11/copyright)