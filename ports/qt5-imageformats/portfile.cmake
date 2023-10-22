set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

include("${CURRENT_INSTALLED_DIR}/share/qt5/qt_port_functions.cmake")

list(APPEND CORE_OPTIONS
    -no-mng # must be explicitly disabled to not automatically pick up mng
    -verbose
)

if("jasper" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS -jasper)

    x_vcpkg_pkgconfig_get_modules(PREFIX jasper MODULES jasper LIBS)

    file(READ "${CURRENT_INSTALLED_DIR}/share/jasper/vcpkg_abi_info.txt" jasper_abi_info)
    if(jasper_abi_info MATCHES "(^|;)opengl(;|$)")
        find_library(FREEGLUT_RELEASE NAMES freeglut glut PATHS "${CURRENT_INSTALLED_DIR}/lib" NO_DEFAULT_PATH)
        find_library(FREEGLUT_DEBUG NAMES freeglutd freeglut glutd glut PATHS "${CURRENT_INSTALLED_DIR}/debug/lib" NO_DEFAULT_PATH)
    endif()

    list(APPEND OPT_REL "JASPER_LIBS=${jasper_LIBS_RELEASE} ${FREEGLUT_RELEASE}")
    list(APPEND OPT_DBG "JASPER_LIBS=${jasper_LIBS_DEBUG} ${FREEGLUT_DEBUG}")
else()
    list(APPEND CORE_OPTIONS -no-jasper)
endif()

if("tiff" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS -system-tiff)

    x_vcpkg_pkgconfig_get_modules(PREFIX tiff MODULES libtiff-4 LIBS)
    list(APPEND OPT_REL "TIFF_LIBS=${tiff_LIBS_RELEASE}")
    list(APPEND OPT_DBG "TIFF_LIBS=${tiff_LIBS_DEBUG}")
else()
    list(APPEND CORE_OPTIONS -no-tiff)
endif()

if("webp" IN_LIST FEATURES)
    list(APPEND CORE_OPTIONS -system-webp)

    x_vcpkg_pkgconfig_get_modules(PREFIX webp MODULES libwebp libwebpdemux libwebpmux libwebpdecoder LIBS)
    list(APPEND CORE_OPTIONS "WEBP_INCDIR=${CURRENT_INSTALLED_DIR}/include") # Requires libwebp[all]
    # This will still fail if LIBWEBP is installed with all available features due to the missing additional dependencies
    list(APPEND OPT_REL "WEBP_LIBS=${webp_LIBS_RELEASE}")
    list(APPEND OPT_DBG "WEBP_LIBS=${webp_LIBS_DEBUG}")
else()
    list(APPEND CORE_OPTIONS -no-webp)
endif()

qt_submodule_installation(BUILD_OPTIONS ${CORE_OPTIONS} BUILD_OPTIONS_RELEASE ${OPT_REL} BUILD_OPTIONS_DEBUG ${OPT_DBG})
