include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/qwt-6.1.3)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/qwt/files/qwt/6.1.3/qwt-6.1.3.zip"
    FILENAME "qwt-6.1.3.zip"
    SHA512 8f249e23d50f71d14fca37776ea40d8d6931db14d9602e03a343bfb7a9bf55502202103135b77f583c3890a7924220e8a142a01c448dbde311860d89a3b10fc8
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/build-shared-lib.patch"
        QUIET
    )
else()
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/build-static-lib.patch"
        QUIET
    )
endif()

vcpkg_configure_qmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_build_qmake()

# Install following vcpkg conventions 
set(BUILD_DIR ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

file(GLOB HEADER_FILES ${SOURCE_PATH}/src/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL
    ${BUILD_DIR}/lib/qwt.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${BUILD_DIR}/lib/qwtd.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(INSTALL
        ${BUILD_DIR}/lib/qwt.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )

    file(INSTALL
        ${BUILD_DIR}/lib/qwtd.dll
        ${BUILD_DIR}/lib/qwtd.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/qwt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/qwt/COPYING ${CURRENT_PACKAGES_DIR}/share/qwt/copyright)
