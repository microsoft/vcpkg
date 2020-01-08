vcpkg_from_github(ARCHIVE
	OUT_SOURCE_PATH SOURCE_PATH
	REPO fltk/fltk
	REF ee9ada967806dae72aa1b9ddad7b95b94f4dd2a3 # Nov 9, 2019
	SHA512 2e3c5bb06adcb0eaaaa9eb2d193353b0e792b1cc215686a79ab56486b11f7ea1aa7457fd51eb0bf65463536115b32cf02efc4ef83959842e9a9c17e122407afe
	HEAD_REF master
	PATCHES
        find-lib-cairo.patch
        find-lib-png.patch
        add-link-libraries.patch
        fluid-group-relative.patch
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(OPTION_BUILD_SHARED "-DOPTION_BUILD_SHARED_LIBS=ON")
else()
    set(OPTION_BUILD_SHARED "-DOPTION_BUILD_SHARED_LIBS=OFF")
endif()

if (VCPKG_TARGET_ARCHITECTURE MATCHES "arm" OR VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
    set(OPTION_USE_GL "-DOPTION_USE_GL=OFF")
else()
    set(OPTION_USE_GL "-DOPTION_USE_GL=ON")
endif()

if ("cairo" IN_LIST FEATURES)
    set(OPTION_USE_CAIRO "-DOPTION_CAIRO=ON")
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
        ${OPTION_BUILD_SHARED}
        ${OPTION_USE_CAIRO}
        ${OPTION_USE_GL}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/CMAKE
    ${CURRENT_PACKAGES_DIR}/debug/CMAKE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share 
)

if (VCPKG_TARGET_IS_WINDOWS)
    set(FLUID_TARGET fluid.exe)
elseif (VCPKG_TARGET_IS_OSX)
    set(FLUID_TARGET fluid.app)
endif()

if (FLUID_TARGET)
    file(COPY ${CURRENT_PACKAGES_DIR}/bin/${FLUID_TARGET} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/fltk)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/${FLUID_TARGET})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/fltk-config)

    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${FLUID_TARGET})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/fltk-config)
endif()

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
