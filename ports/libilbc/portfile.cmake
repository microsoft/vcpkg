set(ILBC_VERSION 3.0.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/TimothyGu/libilbc/releases/download/v${ILBC_VERSION}/libilbc-${ILBC_VERSION}.zip"
    FILENAME "libilbc-${ILBC_VERSION}.zip"
    SHA512 a5755db093529f6a3fd8fd47da63b57cffff1d3babef443d92f7c5a250ce8d1585adfba525c4037b142d9f00f1675a5054c172bf936be280dfcc22ed553c94c6
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${ILBC_VERSION}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
)
vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(GLOB EXES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
if(EXES)
    file(REMOVE ${EXES})
endif()

file(GLOB DEBUG_EXES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
if(DEBUG_EXES)
    file(REMOVE ${DEBUG_EXES})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
