vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmocom/rtl-sdr
    REF d794155ba65796a76cd0a436f9709f4601509320
    SHA512 21fe10f1dbecca651650f03d1008560930fac439d220c33b4a23acce98d78d8476ff200765eed8cfa6cddde761d45f7ba36c8b5bc3662aa85819172830ea4938
    HEAD_REF master
    PATCHES
        Compile-with-msvc.patch
        fix-version.patch
)

file(
    COPY ${CMAKE_CURRENT_LIST_DIR}/Findlibusb.cmake
    DESTINATION ${SOURCE_PATH}/cmake/Modules
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/rtlsdr)
vcpkg_copy_pdbs()

file(
    INSTALL ${SOURCE_PATH}/COPYING
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/rtlsdr
    RENAME copyright
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(GLOB DEBUG_TOOLS "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
    file(GLOB RELEASE_TOOLS "${CURRENT_PACKAGES_DIR}/bin/*.exe")
    file(
        INSTALL ${RELEASE_TOOLS}
        DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}
    )
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${DEBUG_TOOLS} ${RELEASE_TOOLS})
endif()
