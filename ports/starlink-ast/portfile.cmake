# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
#   DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   VCPKG_TOOLCHAIN           = ON OFF
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   BUILD_ARCH                = "Win32" "x64" "ARM"
#   MSBUILD_PLATFORM          = "Win32"/"x64"/${TRIPLET_SYSTEM_ARCH}
#   DEBUG_CONFIG              = "Debug Static" "Debug Dll"
#   RELEASE_CONFIG            = "Release Static"" "Release DLL"
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_LINUX
#   VCPKG_TARGET_IS_OSX
#   VCPKG_TARGET_IS_FREEBSD
#   VCPKG_TARGET_IS_ANDROID
#   VCPKG_TARGET_IS_MINGW
#   VCPKG_TARGET_EXECUTABLE_SUFFIX
#   VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
#   VCPKG_TARGET_SHARED_LIBRARY_SUFFIX
#
# 	See additional helpful variables in /docs/maintainers/vcpkg_common_definitions.md

# # Specifies if the port install should fail immediately given a condition
# vcpkg_fail_port_install(MESSAGE "starlink-ast currently only supports Linux and Mac platforms" ON_TARGET "Windows")

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/Starlink/ast/releases/download/v9.2.3/ast-9.2.3.tar.gz"
    FILENAME "ast-9.2.3.tar.gz"
    SHA512 5cd19d153381a22f7a250189321b9914b52ec05e057b48aa735477e414c6b1b535135bfdd72049aaf1ed245b8b9ff2a8664b3fb1d374429d89bab786b491e74e
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    # (Optional) A friendly name to use instead of the filename of the archive (e.g.: a version number or tag).
    # REF 1.0.0
    # (Optional) Read the docs for how to generate patches at:
    # https://github.com/Microsoft/vcpkg/blob/master/docs/examples/patching.md
    PATCHES
        "patch-use-exeetc-envar.patch"
        "patch-avoid-gcc-specifics.patch"
    #   001_port_fixes.patch
    #   002_more_port_fixes.patch
)


set(CONFIGURE_OPTIONS "--without-fortran --without-pthreads --without-yaml")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --disable-static --enable-shared")
else()
    set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --enable-static --disable-shared")
endif()

set(CONFIGURE_OPTIONS_RELEASE "--disable-debug --enable-release --prefix=${CURRENT_PACKAGES_DIR}")
set(CONFIGURE_OPTIONS_DEBUG  "--enable-debug --disable-release --prefix=${CURRENT_PACKAGES_DIR}/debug")
set(RELEASE_TRIPLET ${TARGET_TRIPLET}-rel)
set(DEBUG_TRIPLET ${TARGET_TRIPLET}-dbg)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    mesage(ERROR "TODO!")
else()
    #set(ENV{AR_FLAGS} "-verbose")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=x86_64-w64-mingw32")
    else()
        set(CONFIGURE_OPTIONS "${CONFIGURE_OPTIONS} --host=i686-w64-mingw32")
    endif()    

    # Acquire tools
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES make automake1.16 perl)    
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        USE_WRAPPERS
        OPTIONS ${CONFIGURE_OPTIONS}
    )
    

    file(COPY ${SOURCE_PATH}/ast_par.source DESTINATION ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})
    file(COPY ${SOURCE_PATH}/ast_par.source DESTINATION ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
    file(COPY ${SOURCE_PATH}/makeh DESTINATION ${CURRENT_BUILDTREES_DIR}/${DEBUG_TRIPLET})
    file(COPY ${SOURCE_PATH}/makeh DESTINATION ${CURRENT_BUILDTREES_DIR}/${RELEASE_TRIPLET})

    vcpkg_install_make()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share")

# # Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/starlink-ast RENAME copyright)