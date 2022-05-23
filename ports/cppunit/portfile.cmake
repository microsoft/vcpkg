vcpkg_download_distfile(ARCHIVE
    URLS "https://dev-www.libreoffice.org/src/cppunit-1.15.1.tar.gz"
    FILENAME "cppunit-1.15.1.tar.gz"
    SHA512 0feb47faec451357bb4c4e287efa17bb60fd3ad966d5350e9f25b414aaab79e94921024b0c0497672f8d3eeb22a599213d2d71d9e1d28b243b3e37f3a9a43691
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    # Use a simple CMakeLists.txt to build CppUnit on windows
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

    vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
    )

    vcpkg_cmake_install()

    # Move EXE to 'tools'
    vcpkg_copy_tools(TOOL_NAMES DllPlugInTester AUTO_CLEAN)
else()
    # Use a configure on unix. It should be doable to use the cmake, but may require some patching
    if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(LINKAGE_DYNAMIC yes)
        set(LINKAGE_STATIC no)
    else()
        set(LINKAGE_DYNAMIC no)
        set(LINKAGE_STATIC yes)
    endif()

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        AUTOCONFIG
        OPTIONS
            "--enable-shared=${LINKAGE_DYNAMIC}"
            "--enable-static=${LINKAGE_STATIC}"
            "--prefix=${CURRENT_INSTALLED_DIR}"
            "--disable-doxygen"
        OPTIONS_DEBUG
            "--enable-debug"
    )

    vcpkg_install_make()
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Install CppUnitConfig.cmake
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CppUnitConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# Cleanup
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
