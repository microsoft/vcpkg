vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmocom/rtl-sdr
    REF v2.0.2
    SHA512 20a1630df7d4da5d263c5ffd4d83a7c2a6fc674e3838bf02b2b59c1da8d946dafc48790d410ab2fcbc0362c2ac70e5cdcae9391c5f04803bf2cdddafd6f58483
    HEAD_REF master
)

file(
    COPY "${CMAKE_CURRENT_LIST_DIR}/Findlibusb.cmake"
    DESTINATION "${SOURCE_PATH}/cmake/Modules"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rtlsdr)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(
    INSTALL "${SOURCE_PATH}/COPYING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/rtlsdr"
    RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
else()
    file(GLOB DEBUG_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    file(GLOB RELEASE_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
    file(
        INSTALL ${RELEASE_TOOLS}
        DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}"
    )
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE ${DEBUG_TOOLS} ${RELEASE_TOOLS})
endif()
