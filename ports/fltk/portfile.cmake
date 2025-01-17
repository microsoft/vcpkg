vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fltk/fltk
    REF "release-${VERSION}"
    SHA512 aaaffc49d8b9f05b1e57e8b34c359b437fc0a8f8b63cc33bafb2b3769c493b0f47a273d21cda494d18160f591eb13446119d77fd7c32f35ba2d93619388e408d
    PATCHES
        math-h-polyfill.patch
    HEAD_REF master
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/jpeg"
    "${SOURCE_PATH}/png"
    "${SOURCE_PATH}/zlib"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl  FLTK_BUILD_GL
        fluid   FLTK_BUILD_FLUID
)

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
        -DFLTK_USE_SYSTEM_ZLIB=ON
        -DFLTK_USE_SYSTEM_LIBPNG=ON
        -DFLTK_USE_SYSTEM_LIBJPEG=ON
        -DFLTK_BUILD_SHARED_LIBS=OFF
        -DFLTK_BUILD_FLTK_OPTIONS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=1
        -DFLTK_MSVC_RUNTIME_DLL=${runtime_dll}
)

vcpkg_cmake_install()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH "CMake")
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "share/fltk")
endif()

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
   vcpkg_copy_tools(TOOL_NAMES fluid AUTO_CLEAN)
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

foreach(FILE IN ITEMS Fl_Export.H)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FL/${FILE}" "defined(FL_DLL)" "0")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FL/${FILE}" "defined(FL_DLL)" "1")
    endif()
endforeach()

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
