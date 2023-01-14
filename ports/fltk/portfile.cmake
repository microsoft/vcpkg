# FLTK has many improperly shared global variables that get duplicated into every DLL
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fltk/fltk
    REF release-1.3.8
    SHA512 197848d3b80a65cca936daf4f0b74609f0fe8332a4cd11af53385fb2aa45ad698b1e239a48732b118cd3cb189bc531711b72fb2eeeb85be887dc6c5a558fa4b3
    PATCHES
        dependencies.patch
        config-path.patch
        include.patch
        fix-system-link.patch
        math-h-polyfill.patch
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/jpeg"
    "${SOURCE_PATH}/png"
    "${SOURCE_PATH}/zlib"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        opengl  OPTION_USE_GL
)

set(fluid_path_param "")
if(VCPKG_CROSSCOMPILING)
    set(fluid_path_param "-DFLUID_PATH=${CURRENT_HOST_INSTALLED_DIR}/tools/fltk/fluid${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFLTK_BUILD_TEST=OFF
        -DOPTION_LARGE_FILE=ON
        -DHAVE_ALSA_ASOUNDLIB_H=OFF # tests only
        -DOPTION_USE_SYSTEM_ZLIB=ON
        -DOPTION_USE_SYSTEM_LIBPNG=ON
        -DOPTION_USE_SYSTEM_LIBJPEG=ON
        -DOPTION_BUILD_SHARED_LIBS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=1
        "-DCocoa:STRING=-framework Cocoa" # avoid absolute path
        ${fluid_path_param}
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
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/fltk-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/fltk-config")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/fltk-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../../..")
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

foreach(FILE IN ITEMS Fl_Export.H fl_utf8.h)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FL/${FILE}" "defined(FL_DLL)" "0")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FL/${FILE}" "defined(FL_DLL)" "1")
    endif()
endforeach()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fltk/UseFLTK.cmake" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel;${SOURCE_PATH}" [[${CMAKE_CURRENT_LIST_DIR}/../../include]])

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
