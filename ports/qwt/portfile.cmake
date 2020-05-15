include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/qwt/files/qwt/6.1.3/qwt-6.1.3.zip"
    FILENAME "qwt-6.1.3.zip"
    SHA512 8f249e23d50f71d14fca37776ea40d8d6931db14d9602e03a343bfb7a9bf55502202103135b77f583c3890a7924220e8a142a01c448dbde311860d89a3b10fc8
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES fix-dynamic-static.patch
)

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        CONFIG+=${VCPKG_LIBRARY_LINKAGE}
)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_install_qmake(
        RELEASE_TARGETS sub-src-release_ordered
        DEBUG_TARGETS sub-src-debug_ordered
    )
else ()
    vcpkg_install_qmake(
        RELEASE_TARGETS sub-src-all-ordered
        DEBUG_TARGETS sub-src-all-ordered
    )
endif()

#Install the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/qwt)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/qwt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qwt/COPYING ${CURRENT_PACKAGES_DIR}/share/qwt/copyright)
