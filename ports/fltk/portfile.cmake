vcpkg_download_distfile(ARCHIVE
    URLS "https://fltk.org/pub/fltk/1.3.5/fltk-1.3.5-source.tar.gz"
    FILENAME "fltk-1.3.5.tar.gz"
    SHA512 db7ea7c5f3489195a48216037b9371a50f1119ae7692d66f71b6711e5ccf78814670581bae015e408dee15c4bba921728309372c1cffc90113cdc092e8540821
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        findlibsfix.patch
        add-link-libraries.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(BUILD_SHARED ON)
else()
    set(BUILD_SHARED OFF)
endif()

if (VCPKG_TARGET_ARCHITECTURE MATCHES "arm" OR VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
    set(OPTION_USE_GL "-DOPTION_USE_GL=OFF")
else()
    set(OPTION_USE_GL "-DOPTION_USE_GL=ON")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPTION_BUILD_EXAMPLES=OFF
        -DOPTION_LARGE_FILE=ON
        -DOPTION_USE_THREADS=ON
        -DOPTION_USE_SYSTEM_ZLIB=ON
        -DOPTION_USE_SYSTEM_LIBPNG=ON
        -DOPTION_USE_SYSTEM_LIBJPEG=ON
        -DOPTION_BUILD_SHARED_LIBS=${BUILD_SHARED}
        ${OPTION_USE_GL}
)

vcpkg_install_cmake()

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT} TARGET_PATH share/${PORT})
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/fluid DESTINATION ${CURRENT_PACKAGES_DIR}/tools/fltk)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fluid)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fluid)
else() 
    vcpkg_fixup_cmake_targets(CONFIG_PATH CMake)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/fluid.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/fltk)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fluid.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fluid.exe)
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fltk-config)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fltk-config)

vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/fltk)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/debug/bin
        ${CURRENT_PACKAGES_DIR}/bin
    )
else()
    file(GLOB SHARED_LIBS "${CURRENT_PACKAGES_DIR}/lib/*_SHARED.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/*_SHAREDd.lib")
    file(GLOB STATIC_LIBS "${CURRENT_PACKAGES_DIR}/lib/*.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/*.lib")
    list(FILTER STATIC_LIBS EXCLUDE REGEX "_SHAREDd?\\.lib\$")
    file(REMOVE ${STATIC_LIBS})
    foreach(SHARED_LIB ${SHARED_LIBS})
        string(REGEX REPLACE "_SHARED(d?)\\.lib\$" "\\1.lib" NEWNAME ${SHARED_LIB})
        file(RENAME ${SHARED_LIB} ${NEWNAME})
    endforeach()
endif()

foreach(FILE Fl_Export.H fl_utf8.h)
    file(READ ${CURRENT_PACKAGES_DIR}/include/FL/${FILE} FLTK_HEADER)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        string(REPLACE "defined(FL_DLL)" "0" FLTK_HEADER "${FLTK_HEADER}")
    else()
        string(REPLACE "defined(FL_DLL)" "1" FLTK_HEADER "${FLTK_HEADER}")
    endif()
    file(WRITE ${CURRENT_PACKAGES_DIR}/include/FL/${FILE} "${FLTK_HEADER}")
endforeach()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
