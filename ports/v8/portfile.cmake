
set(pkgver "8.3.110.13")

set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} 0)

get_filename_component(GIT_PATH ${GIT} DIRECTORY)
vcpkg_find_acquire_program(PYTHON2)
get_filename_component(PYTHON2_PATH ${PYTHON2} DIRECTORY)
vcpkg_find_acquire_program(GN)
get_filename_component(GN_PATH ${GN} DIRECTORY)
vcpkg_find_acquire_program(NINJA)
get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)

vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/bin")
vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}/debug/bin")
vcpkg_add_to_path(PREPEND "${GIT_PATH}")
vcpkg_add_to_path(PREPEND "${PYTHON2_PATH}")
vcpkg_add_to_path(PREPEND "${GN_PATH}")
vcpkg_add_to_path(PREPEND "${NINJA_PATH}")
if(WIN32)
  vcpkg_acquire_msys(MSYS_ROOT PACKAGES pkg-config)
  vcpkg_add_to_path("${MSYS_ROOT}/usr/bin")
endif()

set(VCPKG_KEEP_ENV_VARS PATH;DEPOT_TOOLS_WIN_TOOLCHAIN)

function(v8_fetch)
  set(oneValueArgs DESTINATION URL REF SOURCE)
  set(multipleValuesArgs PATCHES)
  cmake_parse_arguments(V8 "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

  if(NOT DEFINED V8_DESTINATION)
    message(FATAL_ERROR "DESTINATION must be specified.")
  endif()

  if(NOT DEFINED V8_URL)
    message(FATAL_ERROR "The git url must be specified")
  endif()

  if(NOT DEFINED V8_REF)
    message(FATAL_ERROR "The git ref must be specified.")
  endif()

  if(EXISTS ${V8_SOURCE}/${V8_DESTINATION})
        vcpkg_execute_required_process(
                COMMAND ${GIT} reset --hard
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
  else()
        vcpkg_execute_required_process(
                COMMAND ${GIT} clone --depth 1 ${V8_URL} ${V8_DESTINATION}
                WORKING_DIRECTORY ${V8_SOURCE}
                LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
                COMMAND ${GIT} fetch --depth 1 origin ${V8_REF}
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
                COMMAND ${GIT} checkout FETCH_HEAD
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
  endif()
  foreach(PATCH ${V8_PATCHES})
        vcpkg_execute_required_process(
                        COMMAND ${GIT} apply ${PATCH}
                        WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                        LOGNAME build-${TARGET_TRIPLET})
  endforeach()
endfunction()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/v8/v8.git
    REF 90904eb48b16b32f7edbf1f8a92ece561d05e738
    PATCHES ${CURRENT_PORT_DIR}/v8.patch ${CURRENT_PORT_DIR}/3f8dc4b.patch
)

message(STATUS "Fetching submodules")
v8_fetch(
        DESTINATION build
        URL https://chromium.googlesource.com/chromium/src/build.git
        REF 26e9d485d01d6e0eb9dadd21df767a63494c8fea
        SOURCE ${SOURCE_PATH}
        PATCHES ${CURRENT_PORT_DIR}/build.patch)
v8_fetch(
        DESTINATION third_party/zlib
        URL https://chromium.googlesource.com/chromium/src/third_party/zlib.git
        REF 156be8c52f80cde343088b4a69a80579101b6e67
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION base/trace_event/common
        URL https://chromium.googlesource.com/chromium/src/base/trace_event/common.git
        REF dab187b372fc17e51f5b9fad8201813d0aed5129
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/googletest/src
        URL https://chromium.googlesource.com/external/github.com/google/googletest.git
        REF 10b1902d893ea8cc43c69541d70868f91af3646b
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/jinja2
        URL https://chromium.googlesource.com/chromium/src/third_party/jinja2.git
        REF b41863e42637544c2941b574c7877d3e1f663e25
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/markupsafe
        URL https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git
        REF 8f45f5cfa0009d2a70589bcda0349b8cb2b72783
        SOURCE ${SOURCE_PATH})

vcpkg_execute_required_process(
        COMMAND ${PYTHON2} build/util/lastchange.py -o build/util/LASTCHANGE
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}
)

file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party/icu")
configure_file(${CURRENT_PORT_DIR}/zlib.gn ${SOURCE_PATH}/third_party/zlib/BUILD.gn COPYONLY)
configure_file(${CURRENT_PORT_DIR}/icu.gn ${SOURCE_PATH}/third_party/icu/BUILD.gn COPYONLY)

if(UNIX)
    set(UNIX_CURRENT_INSTALLED_DIR ${CURRENT_INSTALLED_DIR})
    set(LIBS "-ldl -lpthread")
    set(REQUIRES ", gmodule-2.0, gobject-2.0, gthread-2.0")
elseif(WIN32)
    execute_process(COMMAND cygpath "${CURRENT_INSTALLED_DIR}" OUTPUT_VARIABLE UNIX_CURRENT_INSTALLED_DIR)
    string(STRIP ${UNIX_CURRENT_INSTALLED_DIR} UNIX_CURRENT_INSTALLED_DIR)
    set(LIBS "-lWinmm -lDbgHelp")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(is_component_build true)
    set(v8_monolithic false)
    set(v8_use_external_startup_data true)
    set(targets :v8_libbase :v8_libplatform :v8)
else()
    set(is_component_build false)
    set(v8_monolithic true)
    set(v8_use_external_startup_data false)
    set(targets :v8_monolith)
endif()

message(STATUS "Generating v8 build files. Please wait...")

vcpkg_configure_gn(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS "is_component_build=${is_component_build} target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\" v8_monolithic=${v8_monolithic} v8_use_external_startup_data=${v8_use_external_startup_data} use_sysroot=false is_clang=false use_custom_libcxx=false v8_enable_verify_heap=false icu_use_data_file=false" 
    OPTIONS_DEBUG "is_debug=true enable_iterator_debugging=true pkg_config_libdir=\"${UNIX_CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig\""
    OPTIONS_RELEASE "is_debug=false enable_iterator_debugging=false pkg_config_libdir=\"${UNIX_CURRENT_INSTALLED_DIR}/lib/pkgconfig\""
)

message(STATUS "Building v8. Please wait...")

vcpkg_install_gn(
    SOURCE_PATH ${SOURCE_PATH}
    TARGETS ${targets}
)

set(CFLAGS "-DV8_COMPRESS_POINTERS")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CFLAGS "${CFLAGS} -DV8_31BIT_SMIS_ON_64BIT_ARCH")
endif()
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PREFIX ${CURRENT_PACKAGES_DIR})
    configure_file(${CURRENT_PORT_DIR}/v8.pc.in ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/v8_libbase.pc.in ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_libbase.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/v8_libplatform.pc.in ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_libplatform.pc @ONLY)
    set(PREFIX ${CURRENT_PACKAGES_DIR}/debug)
    configure_file(${CURRENT_PORT_DIR}/v8.pc.in ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/v8_libbase.pc.in ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_libbase.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/v8_libplatform.pc.in ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_libplatform.pc @ONLY)
else()
    set(PREFIX ${CURRENT_PACKAGES_DIR})
    configure_file(${CURRENT_PORT_DIR}/v8_monolith.pc.in ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_monolith.pc @ONLY)
    set(PREFIX ${CURRENT_PACKAGES_DIR}/debug)
    configure_file(${CURRENT_PORT_DIR}/v8_monolith.pc.in ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_monolith.pc @ONLY)
endif()

vcpkg_copy_pdbs()

# v8 libraries are listed as SYSTEM_LIBRARIES because the pc files reference each other.
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m dl pthread Winmm DbgHelp v8_libbase v8_libplatform v8)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
