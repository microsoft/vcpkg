include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "WindowsStore not supported")
endif()

set(VERSION 1.9.12)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/jack2-${VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/jackaudio/jack2/releases/download/v${VERSION}/jack2-${VERSION}.tar.gz"
    FILENAME "jack2-${VERSION}.tar.gz"
    SHA512 f0271dfc8f8e2f2489ca52f431ad4fa420665816d6c67a01a76da1d4b5ae91f6dad8c4e3309ec5e0c159c9d312ed56021ab323d74bce828ace26f1b8d477ddfa
)
vcpkg_extract_source_archive(${ARCHIVE})

# Install headers and a statically built JackWeakAPI.c
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# Remove duplicate headers
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/jack2 RENAME copyright)
