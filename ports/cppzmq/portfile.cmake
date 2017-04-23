#header-only library
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/cppzmq-4.2.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/zeromq/cppzmq/archive/v4.2.1.zip"
    FILENAME "cppzmq-4.2.1.zip"
    SHA512 ee75ce4bd28ecb5ef660d1ed6f5522654eced6ded8745dc0c61df351f4ff0ff8980d1bd848b2649fcce4aa539a457e56e55b0a59cb49f44b0a29875d0ea28dce
)
vcpkg_extract_source_archive(${ARCHIVE})

# cppzmq is a single header library, so we just need to copy that file in the include directory
file(INSTALL ${SOURCE_PATH}/zmq.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/zmq_addon.hpp DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cppzmq)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/cppzmq/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppzmq/copyright)
