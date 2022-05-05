vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qwt/qwt
    REF 6.2.0
    FILENAME "qwt-6.2.0.zip"
    SHA512 a3946c6e23481b5a2193819a1c1298db5a069d514ca60de54accb3a249403f5acd778172ae6fae24fae252767b1e58deba524de6225462f1bafd7c947996aae9
    PATCHES
        fix-dynamic-static.patch
)

vcpkg_configure_qmake(
    SOURCE_PATH "${SOURCE_PATH}"
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
file(GLOB HEADER_FILES "${SOURCE_PATH}/src/*.h" "${SOURCE_PATH}/classincludes/*")
file(INSTALL ${HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
