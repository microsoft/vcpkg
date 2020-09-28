vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qwt/qwt
    REF 6.1.5
    FILENAME "qwt-6.1.5.zip"
    SHA512 249634d2032ccc8083e26f1d151b301d6ccfcc3140a2c2c469d77d3d8973bc296872a1cff96e002944c40fa558a9896ca2a0f1a0531169c3c8d0fe2240610266
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

#Install the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/src/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
