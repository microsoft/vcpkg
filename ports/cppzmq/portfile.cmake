#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cppzmq-7faa9b061843fcbceb7ed94984ee8f20284ee759)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/zeromq/cppzmq/archive/7faa9b061843fcbceb7ed94984ee8f20284ee759.zip"
    FILENAME "cppzmq-7faa.zip"
    SHA512 10ba10f0e9a2387dc75fec01c2629b969f23d6152596a475474b701a4efccc4007c8eae5ec2a89f7f26e7d117f36016aaead16bf3325a8780bfd6419d84ac54e
)
vcpkg_extract_source_archive(${ARCHIVE})

# cppzmq is a single header library, so we just need to copy that file in the include directory
file(INSTALL ${SOURCE_PATH}/zmq.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppzmq)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppzmq/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppzmq/copyright)
