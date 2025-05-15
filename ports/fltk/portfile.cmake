# FLTK has many improperly shared global variables that get duplicated into every DLL
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fltk/fltk
    REF "release-${VERSION}"
    SHA512 7630d0b02ff09c277d5641e10631514e5e3d8087e81f5254f38a8adb05c39ed0092ae81697085ed0dd859f0b826f94626d698090153c5e9a655f5e36263b2915
    PATCHES
        fix-options.patch
        fix-fluid-cmd.patch
        fix-export.patch
        config-path.patch
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/jpeg"
    "${SOURCE_PATH}/png"
    "${SOURCE_PATH}/zlib"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl  FLTK_USE_GL
)

set(fluid_path_param "")
if(VCPKG_CROSSCOMPILING)
    set(fluid_path_param "-DFLTK_FLUID_HOST=${CURRENT_HOST_INSTALLED_DIR}/tools/fltk/fluid${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

set(runtime_dll "ON")
if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(runtime_dll "OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFLTK_BUILD_TEST=OFF
        -DFLTK_OPTION_LARGE_FILE=ON
        -DHAVE_ALSA_ASOUNDLIB_H=OFF # tests only
        -DFLTK_USE_SYSTEM_ZLIB=ON
        -DFLTK_USE_SYSTEM_LIBPNG=ON
        -DFLTK_USE_SYSTEM_LIBJPEG=ON
        -DFLTK_BUILD_SHARED_LIBS=OFF
        -DFLTK_BUILD_FLTK_OPTIONS=ON
        -DFLTK_BUILD_FLUID=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=1
        "-DCocoa:STRING=-framework Cocoa" # avoid absolute path
        ${fluid_path_param}
        -DFLTK_MSVC_RUNTIME_DLL=${runtime_dll}
    MAYBE_UNUSED_VARIABLES
        Cocoa
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/fltk-config")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/fltk-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/fltk-config")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/fltk-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/fltk-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../.." IGNORE_UNCHANGED)
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/fltk-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/fltk-config")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/fltk-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../../..")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/fltk-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../.." IGNORE_UNCHANGED)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/fltk-config" "{prefix}/include" "{prefix}/../include")
    endif()
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/fluid${VCPKG_TARGET_EXECUTABLE_SUFFIX}" OR
   EXISTS "${CURRENT_PACKAGES_DIR}/bin/fluid${VCPKG_TARGET_BUNDLE_SUFFIX}")
   file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/fluid.icns" "${CURRENT_PACKAGES_DIR}/debug/bin/fluid.icns")
   vcpkg_copy_tools(TOOL_NAMES fluid fluid-cmd fltk-options fltk-options-cmd AUTO_CLEAN)
   if(WIN32)
    vcpkg_copy_tools(TOOL_NAMES fltk-options-cmd AUTO_CLEAN)
   endif()
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/bin"
        "${CURRENT_PACKAGES_DIR}/bin"
    )
endif()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

set(copyright_files "${SOURCE_PATH}/COPYING")
if("opengl" IN_LIST FEATURES)
    file(READ "${SOURCE_PATH}/src/freeglut_geometry.cxx" freeglut_copyright)
    string(REGEX MATCH " [*] Copyright.*" freeglut_copyright "${freeglut_copyright}" )
    string(REGEX REPLACE "[*]/.*" "" freeglut_copyright "${freeglut_copyright}")
    file(WRITE "${CURRENT_BUILDTREES_DIR}/Freeglut code copyright" "${freeglut_copyright}")
    list(APPEND copyright_files "${CURRENT_BUILDTREES_DIR}/Freeglut code copyright")

    file(READ "${SOURCE_PATH}/src/freeglut_teapot.cxx" teapot_copyright)
    string(REGEX MATCH " [*][^*]*Silicon Graphics, Inc.*" teapot_copyright "${teapot_copyright}")
    string(REGEX REPLACE "[*]/.*" "" teapot_copyright "${teapot_copyright}")
    file(WRITE "${CURRENT_BUILDTREES_DIR}/Original teapot code copyright" "${teapot_copyright}")
    list(APPEND copyright_files "${CURRENT_BUILDTREES_DIR}/Original teapot code copyright")
endif()
vcpkg_install_copyright(FILE_LIST ${copyright_files})
