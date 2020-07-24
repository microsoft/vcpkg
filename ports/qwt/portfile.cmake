vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qwt/qwt
    REF 6.1.4
    FILENAME "qwt-6.1.4.zip"
    SHA512 c7f9d4c715479421640e484b2834e0a6868844b1e4986513147e911e02f9af1ef8393d6f8196aca50880fcaa870e60a9b91bc429e30199280e31b8c37fb14b3e 
    PATCHES fix-dynamic-static.patch
            build.patch
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
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)