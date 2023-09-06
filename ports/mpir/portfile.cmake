if(EXISTS "${CURRENT_INSTALLED_DIR}/include/gmp.h" OR EXISTS "${CURRENT_INSTALLED_DIR}/include/gmpxx.h")
    message(FATAL_ERROR "Can't build ${PORT} if gmp is installed. Please remove gmp, and try to install ${PORT} again if you need it.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wbhart/mpir
    REF cdd444aedfcbb190f00328526ef278428702d56e # 3.0.0
    SHA512 f46e45bdba27c9f89953ba23186b694486fd3010bd370ea2de71a4649a2816e716a6520c9baa96936f1884437ef03f92b21c0b1fb5b757beba5a05fed30b2bfc
    HEAD_REF master
    PATCHES 
        enable-runtimelibrary-toggle.patch
        fix-static-include-files.patch
)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(YASM)

    set(SHARED_STATIC --disable-static --enable-shared)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(SHARED_STATIC --enable-static --disable-shared --with-pic)
    endif()

    set(OPTIONS --disable-silent-rules --enable-gmpcompat --enable-cxx ${SHARED_STATIC})

    string(APPEND VCPKG_C_FLAGS " -Wno-implicit-function-declaration")
    string(APPEND VCPKG_CXX_FLAGS " -Wno-implicit-function-declaration")

    # on Linux, autoconf is required; on macOS, it isn't
    if(VCPKG_TARGET_IS_LINUX)
        set(AUTOCONFIG "AUTOCONFIG")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        ${AUTOCONFIG}
        OPTIONS ${OPTIONS}
    )
    vcpkg_install_make()
else()
    set(MSVC_VERSION 14)
    if(VCPKG_PLATFORM_TOOLSET MATCHES "v14(1|2|3)")
        set(MSVC_VERSION 15)
    endif()

    set(DLL_OR_LIB dll)
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(DLL_OR_LIB lib)
    endif()

    # Note: Could probably be moved to use vcpkg_configure_make on windows
    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "build.vc${MSVC_VERSION}/${DLL_OR_LIB}_mpir_gc/${DLL_OR_LIB}_mpir_gc.vcxproj"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_msbuild_install(
            SOURCE_PATH "${SOURCE_PATH}"
            PROJECT_SUBPATH "build.vc${MSVC_VERSION}/${DLL_OR_LIB}_mpir_cxx/${DLL_OR_LIB}_mpir_cxx.vcxproj"
        )
    endif()

    file(GLOB HEADERS
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/*/Release/gmp.h"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/*/Release/gmpxx.h"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/*/Release/mpir.h"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*/*/Release/mpirxx.h"
    )
    file(INSTALL ${HEADERS} DESTINATION "${CURRENT_PACKAGES_DIR}/include")

    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/COPYING.LIB" "${CURRENT_PACKAGES_DIR}/debug/lib/COPYING.LIB")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
    )

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING" "${SOURCE_PATH}/COPYING.LIB")
