# FLTK has many improperly shared global variables that get duplicated into every DLL
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fltk/fltk
    REF release-1.3.7
    SHA512 aad131027e88fac3fe73d7e0abfc2602cdc195388f14b29b58d654cb49b780e6ff2ef4270935730b45cd3d366f9e8c8fa3c27a4f17b1f6e8c8fd1f9a0a73c308
    PATCHES
        findlibsfix.patch
        config-path.patch
        include.patch
        fix-system-link.patch
)

# Remove these 2 lines when the next update
file(COPY ${CMAKE_CURRENT_LIST_DIR}/fltk_version.dat DESTINATION ${SOURCE_PATH})
file(REMOVE ${SOURCE_PATH}/VERSION)

if (VCPKG_TARGET_ARCHITECTURE MATCHES "arm" OR VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
    set(OPTION_USE_GL "-DOPTION_USE_GL=OFF")
else()
    set(OPTION_USE_GL "-DOPTION_USE_GL=ON")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFLTK_BUILD_TEST=OFF
        -DOPTION_LARGE_FILE=ON
        -DOPTION_USE_THREADS=ON
        -DOPTION_USE_SYSTEM_ZLIB=ON
        -DOPTION_USE_SYSTEM_LIBPNG=ON
        -DOPTION_USE_SYSTEM_LIBJPEG=ON
        -DOPTION_BUILD_SHARED_LIBS=OFF
        -DFLTK_CONFIG_PATH=share/fltk
        ${OPTION_USE_GL}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/fltk)

vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_OSX)
    vcpkg_copy_tools(TOOL_NAMES fluid.app fltk-config AUTO_CLEAN)
elseif(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fltk-config ${CURRENT_PACKAGES_DIR}/debug/bin/fltk-config)
    vcpkg_copy_tools(TOOL_NAMES fluid AUTO_CLEAN)
else()
    vcpkg_copy_tools(TOOL_NAMES fluid fltk-config AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug/bin
        ${CURRENT_PACKAGES_DIR}/bin
    )
endif()
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

foreach(FILE Fl_Export.H fl_utf8.h)
    file(READ ${CURRENT_PACKAGES_DIR}/include/FL/${FILE} FLTK_HEADER)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        string(REPLACE "defined(FL_DLL)" "0" FLTK_HEADER "${FLTK_HEADER}")
    else()
        string(REPLACE "defined(FL_DLL)" "1" FLTK_HEADER "${FLTK_HEADER}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/FL/${FILE} "${FLTK_HEADER}")
endforeach()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
