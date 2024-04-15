string(REPLACE "." "_" UNDERSCORE_VERSION "${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AcademySoftwareFoundation/openfx
    REF "OFX_Release_${UNDERSCORE_VERSION}_TAG"
    SHA512 b20512ea38823167f191b72f1592548df85fbda6cefe47673972874c139641ee91277e78c1e0d57a457b9f864385e6fa0e4a7edcdbf0c7b2eda956c03a3e1e13
    HEAD_REF main
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

if("davinci-18" IN_LIST FEATURES)
    set(DRAW_SUITE_COMMIT_REFERENCE "c0167e114582cdf373507f65f60f8e50e2076434")
    vcpkg_download_distfile(
        OFX_DRAW_SUITE_H
        URLS "https://github.com/AcademySoftwareFoundation/openfx/raw/${DRAW_SUITE_COMMIT_REFERENCE}/include/ofxDrawSuite.h"
        FILENAME "ofxDrawSuite.h"
        SHA512 9afd8d93ff4816004ac2d89d45255801d0c09ee8f5acb72dbc37048483fa7ca0637fe028554910039de5f60c9450cb5dc5e2d27477c1a0c5595c9bdf09312ec5
    )
    file(COPY ${OFX_DRAW_SUITE_H} DESTINATION ${CURRENT_PACKAGES_DIR}/include/openfx/)
endif()

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-openfx)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/DocSrc")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Support/LICENSE")
