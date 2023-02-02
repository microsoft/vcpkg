set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
include(${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake)


list(APPEND CORE_OPTIONS
    -system-tiff
    -system-webp
    -jasper 
    -no-mng # must be explicitly disabled to not automatically pick up mng
    -verbose)
    
x_vcpkg_pkgconfig_get_modules(PREFIX tiff MODULES libtiff-4 LIBS)

find_library(JPEG_RELEASE NAMES jpeg jpeg-static PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(JPEG_DEBUG NAMES jpeg jpeg-static jpegd jpeg-staticd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
find_library(ZLIB_RELEASE NAMES z zlib PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(ZLIB_DEBUG NAMES z zlib zd zlibd PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

find_library(JASPER_RELEASE NAMES jasper PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
find_library(JASPER_DEBUG NAMES jasperd jasper libjasperd libjasper PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)

if(NOT VCPKG_TARGET_IS_OSX AND NOT (VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64"))
    set(FREEGLUT_NEEDED ON)
endif()

if(FREEGLUT_NEEDED)
    find_library(FREEGLUT_RELEASE NAMES freeglut glut PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
    find_library(FREEGLUT_DEBUG NAMES freeglutd freeglut glutd glut PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
endif()

x_vcpkg_pkgconfig_get_modules(PREFIX webp MODULES libwebp libwebpdemux libwebpmux libwebpdecoder LIBS)

set(OPT_REL "TIFF_LIBS=${tiff_LIBS_RELEASE}"
            "WEBP_LIBS=${webp_LIBS_RELEASE}"
            "JASPER_LIBS=${JASPER_RELEASE} ${JPEG_RELEASE} ${ZLIB_RELEASE}") # This will still fail if LIBWEBP is installed with all available features due to the missing additional dependencies
set(OPT_DBG "TIFF_LIBS=${tiff_LIBS_DEBUG}"
            "WEBP_LIBS=${webp_LIBS_DEBUG}"
            "JASPER_LIBS=${JASPER_DEBUG}  ${JPEG_DEBUG} ${ZLIB_DEBUG}")

if(FREEGLUT_NEEDED)
    set(OPT_REL "${OPT_REL} ${FREEGLUT_RELEASE}")
    set(OPT_DBG "${OPT_DBG} ${FREEGLUT_DEBUG}")
endif()

list(APPEND CORE_OPTIONS "WEBP_INCDIR=${CURRENT_INSTALLED_DIR}/include") # Requires libwebp[all]

qt_submodule_installation(BUILD_OPTIONS ${CORE_OPTIONS} BUILD_OPTIONS_RELEASE ${OPT_REL} BUILD_OPTIONS_DEBUG ${OPT_DBG})