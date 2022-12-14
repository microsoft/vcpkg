vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} currently requires the following packages:\n    libgl1-mesa-dev\n    This can be installed on Ubuntu systems via\n    sudo apt-get install -y libgl1-mesa-dev\n")
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mathgl/mathgl
    REF mathgl%20${VERSION}
    FILENAME "mathgl-${VERSION}.tar.gz"
    SHA512 1fe27962ffef8d7127c4e1294d735e5da4dd2d647397f09705c3ca860f90bd06fd447ff614e584f3d2b874a02262c5518be37d59e9e0a838dd5b8b64fd77ef9d
    PATCHES
        fix_cmakelists_and_cpp.patch
        fix_attribute.patch
        fix_default_graph_init.patch
        fix_mglDataList.patch
        fix_arma_sprintf.patch
        fix-usage.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    hdf5    enable-hdf5
    fltk    enable-fltk
    gif     enable-gif
    arma    enable-arma
    png     enable-png
    zlib    enable-zlib
    jpeg    enable-jpeg
    gsl     enable-gsl
    opengl  enable-opengl
    glut    enable-glut
    wx      enable-wx
    qt5     enable-qt5
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_cmake_config_fixup(PACKAGE_NAME MathGL2 CONFIG_PATH cmake)
  file(REMOVE "${CURRENT_PACKAGES_DIR}/mathgl2-config.cmake")
  file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/mathgl2-config.cmake")
else()
  vcpkg_cmake_config_fixup(PACKAGE_NAME MathGL2 CONFIG_PATH lib/cmake/mathgl2)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

function(handle_executable_path PATH TOOL_NAME)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/${PATH}/${TOOL_NAME}.exe" OR "${CURRENT_PACKAGES_DIR}/${PATH}/${TOOL_NAME}")
        vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAME} SEARCH_DIR "${CURRENT_PACKAGES_DIR}/${PATH}" AUTO_CLEAN)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/MathGL2/MathGLTargets-debug.cmake" 
        "${VCPKG_IMPORT_PREFIX}/debug/${PATH}/${TOOL_NAME}.exe" "${VCPKG_IMPORT_PREFIX}/tools/mathgl/${TOOL_NAME}.exe")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/MathGL2/MathGLTargets-release.cmake" 
        "${VCPKG_IMPORT_PREFIX}/${PATH}/${TOOL_NAME}.exe" "${VCPKG_IMPORT_PREFIX}/tools/mathgl/${TOOL_NAME}.exe")
    endif()
endfunction()

if("fltk" IN_LIST FEATURES)
  handle_executable_path("bin" "mgllab")
  handle_executable_path("bin" "mglview")
endif()
if("qt5" IN_LIST FEATURES)
  handle_executable_path("bin" "mglview")
  handle_executable_path("bin" "udav")
endif()

handle_executable_path("bin" "mgltask")
handle_executable_path("bin" "mglconv")
handle_executable_path("lib/cgi-bin" "mgl.cgi")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cgi-bin" "${CURRENT_PACKAGES_DIR}/debug/lib/cgi-bin")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/config.h" "#define MGL_INSTALL_DIR	\"${CURRENT_PACKAGES_DIR}\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/config.h" "#define MGL_FONT_PATH\t\"${CURRENT_PACKAGES_DIR}/fonts\"" "") # there is no fonts folder
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/config.h" "#define MGL_FONT_PATH\t\"${CURRENT_PACKAGES_DIR}/share/mathgl/fonts\"" "")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/dllexport.h" "#ifdef MGL_STATIC_DEFINE" "#if 0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mgl2/dllexport.h" "#ifdef MGL_STATIC_DEFINE" "#if 1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
