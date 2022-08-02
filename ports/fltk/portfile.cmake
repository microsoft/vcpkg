# FLTK has many improperly shared global variables that get duplicated into every DLL
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fltk/fltk
    REF release-1.3.8
    SHA512 197848d3b80a65cca936daf4f0b74609f0fe8332a4cd11af53385fb2aa45ad698b1e239a48732b118cd3cb189bc531711b72fb2eeeb85be887dc6c5a558fa4b3
    PATCHES
        findlibsfix.patch
        config-path.patch
        include.patch
        fix-system-link.patch
)

if (VCPKG_TARGET_ARCHITECTURE MATCHES "arm" OR VCPKG_TARGET_ARCHITECTURE MATCHES "arm64")
    set(OPTION_USE_GL "-DOPTION_USE_GL=OFF")
else()
    set(OPTION_USE_GL "-DOPTION_USE_GL=ON")
endif()

set(fluid_path_param "")
if(VCPKG_CROSSCOMPILING)
    set(fluid_path_param "-DFLUID_PATH=${CURRENT_HOST_INSTALLED_DIR}/tools/fltk/fluid${VCPKG_HOST_EXECUTABLE_SUFFIX}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLTK_BUILD_TEST=OFF
        -DOPTION_LARGE_FILE=ON
        -DOPTION_USE_THREADS=ON
        -DOPTION_USE_SYSTEM_ZLIB=ON
        -DOPTION_USE_SYSTEM_LIBPNG=ON
        -DOPTION_USE_SYSTEM_LIBJPEG=ON
        -DOPTION_BUILD_SHARED_LIBS=OFF
        -DFLTK_CONFIG_PATH=share/fltk
        ${fluid_path_param}
        ${OPTION_USE_GL}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_pdbs()

# don't install fluid
if(VCPKG_CROSSCOMPILING)
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        vcpkg_copy_tools(TOOL_NAMES fltk-config AUTO_CLEAN)
    endif()
elseif(VCPKG_TARGET_IS_OSX)
    vcpkg_copy_tools(TOOL_NAMES fluid.app fltk-config AUTO_CLEAN)
elseif(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/fltk-config" "${CURRENT_PACKAGES_DIR}/debug/bin/fltk-config")
    vcpkg_copy_tools(TOOL_NAMES fluid AUTO_CLEAN)
else()
    vcpkg_copy_tools(TOOL_NAMES fluid fltk-config AUTO_CLEAN)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/tools/fltk/fltk-config")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/fltk/fltk-config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/bin"
        "${CURRENT_PACKAGES_DIR}/bin"
    )
endif()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

foreach(FILE Fl_Export.H fl_utf8.h)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FL/${FILE}" "defined(FL_DLL)" "0")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/FL/${FILE}" "defined(FL_DLL)" "1")
    endif()
endforeach()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/fltk/UseFLTK.cmake" "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel;${SOURCE_PATH}" [[${CMAKE_CURRENT_LIST_DIR}/../../include]])

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
