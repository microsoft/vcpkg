
set(pkgver "8.6.395.17")

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

function(checkout_in_path PATH URL REF SHA512)
    if(EXISTS "${PATH}")
        file(GLOB FILES "${PATH}")
        list(LENGTH FILES COUNT)
        if(COUNT GREATER 0)
            return()
        endif()
        file(REMOVE_RECURSE "${PATH}")
    endif()

    vcpkg_from_git(
        OUT_SOURCE_PATH DEP_SOURCE_PATH
        URL "${URL}"
        REF "${REF}"
        SHA512 "${SHA512}"
        PATCHES "${ARGN}"
    )
    get_filename_component(PATH_DIR ${PATH} DIRECTORY)
    file(MAKE_DIRECTORY "${PATH_DIR}")
    file(RENAME "${DEP_SOURCE_PATH}" "${PATH}")
    file(REMOVE_RECURSE "${DEP_SOURCE_PATH}")
endfunction()

function(v8_fetch)
  set(oneValueArgs DESTINATION URL REF SOURCE SHA512)
  set(multipleValuesArgs PATCHES)
  cmake_parse_arguments(V8 "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

  if(NOT DEFINED V8_DESTINATION)
    message(FATAL_ERROR "DESTINATION must be specified.")
  endif()

  if(NOT DEFINED V8_URL)
    message(FATAL_ERROR "The git url must be specified")
  endif()

  if(NOT DEFINED V8_SHA512)
    message(FATAL_ERROR "The sha512 of the git archive must be specified")
  endif()

  if(NOT DEFINED V8_REF)
    message(FATAL_ERROR "The git ref must be specified.")
  endif()

  file(REMOVE_RECURSE ${V8_SOURCE}/${V8_DESTINATION})
  checkout_in_path(
    "${V8_SOURCE}/${V8_DESTINATION}"
    "${V8_URL}"
    "${V8_REF}"
    "${V8_SHA512}"
    ${V8_PATCHES}
  )
endfunction()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://chromium.googlesource.com/v8/v8.git
    REF 7565e93eb72cea4268028fc20186d415c22b1cff
    SHA512 4ebd6ffc91fd64b05de308199cbd73f57d96fd9bd7d4323fb5ff949b878e146c4e10730c9c0d0e091f93b02b129928d481821e425fd21059f18f2e0cf83f1b96
    PATCHES ${CURRENT_PORT_DIR}/v8.patch
)

message(STATUS "Fetching submodules")
v8_fetch(
        DESTINATION build
        URL https://chromium.googlesource.com/chromium/src/build.git
        REF b6be94885f567b15bcb0961298b32cdb737ae2d6
        SHA512 7563ea2e7ab364ba56b664a1bd6c0f404ff7e16e26f12fa6264b986e3404d244bd70c789aa5c09677c193274105f68626bf10574f89569f411cb8503773cba4e
        SOURCE ${SOURCE_PATH}
        PATCHES ${CURRENT_PORT_DIR}/build.patch)
v8_fetch(
        DESTINATION third_party/zlib
        URL https://chromium.googlesource.com/chromium/src/third_party/zlib.git
        REF 156be8c52f80cde343088b4a69a80579101b6e67
        SHA512 38f15d6c38024d103e73d3fb7dffbf24fa0cf149516fd2834c31c46c1b731287a82f3f85a6f233307ad05944c654c4b12a83ac954d44bb8f7953d3e17e1a16a3
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION base/trace_event/common
        URL https://chromium.googlesource.com/chromium/src/base/trace_event/common.git
        REF dab187b372fc17e51f5b9fad8201813d0aed5129
        SHA512 93a9347cbd0eaab21caca396ce905a5806e39d6a135f595def2e738ee288df31b09807d6d8580cfb877c281c9cfc9a89e3c2859ecbc7a5b5fec929e5da478f21
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/googletest/src
        URL https://chromium.googlesource.com/external/github.com/google/googletest.git
        REF 10b1902d893ea8cc43c69541d70868f91af3646b
        SHA512 be3d76c080bef84cddece83cae613cde28cf452022ffda379ae64b4223a2e15cf01841ecaab5888f430f2ec97253416ffb726752d7e80add6701f074f07407de
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/jinja2
        URL https://chromium.googlesource.com/chromium/src/third_party/jinja2.git
        REF b41863e42637544c2941b574c7877d3e1f663e25
        SHA512 c2fac744a3b946ade10c0c40af5a543c30f49fa98e43a54015313689663bd69ae8f771de5e88f3dcdfd6cdd48c3808ab6309351d22ff76a77f676a9128ac4aec
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/markupsafe
        URL https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git
        REF 8f45f5cfa0009d2a70589bcda0349b8cb2b72783
        SHA512 d6ef15eda2914e41c70391ab147f1e20eb6b66c893fa2b0d422dd9d4e9903da8e7d5cbe1461f4d814a3c0dd68c6930ef3165652d8d86bcd489c82a9d3aeaef22
        SOURCE ${SOURCE_PATH})

file(WRITE "${SOURCE_PATH}/build/util/LASTCHANGE" "LASTCHANGE=0")
file(WRITE "${SOURCE_PATH}/build/util/LASTCHANGE.committime" "0")

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

vcpkg_configure_gn(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS "is_component_build=${is_component_build} target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\" v8_monolithic=${v8_monolithic} v8_use_external_startup_data=${v8_use_external_startup_data} use_sysroot=false is_clang=false use_custom_libcxx=false v8_enable_verify_heap=false icu_use_data_file=false" 
    OPTIONS_DEBUG "is_debug=true enable_iterator_debugging=true pkg_config_libdir=\"${UNIX_CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig\""
    OPTIONS_RELEASE "is_debug=false enable_iterator_debugging=false pkg_config_libdir=\"${UNIX_CURRENT_INSTALLED_DIR}/lib/pkgconfig\""
)

vcpkg_install_gn(
    SOURCE_PATH ${SOURCE_PATH}
    TARGETS ${targets}
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(CFLAGS "-DV8_COMPRESS_POINTERS -DV8_31BIT_SMIS_ON_64BIT_ARCH")
endif()

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include FILES_MATCHING PATTERN "*.h")

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(PREFIX ${CURRENT_PACKAGES_DIR})
    configure_file(${CURRENT_PORT_DIR}/v8.pc.in ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/v8_libbase.pc.in ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_libbase.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/v8_libplatform.pc.in ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_libplatform.pc @ONLY)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/snapshot_blob.bin DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

    set(PREFIX ${CURRENT_PACKAGES_DIR}/debug)
    configure_file(${CURRENT_PORT_DIR}/v8.pc.in ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/v8_libbase.pc.in ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_libbase.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/v8_libplatform.pc.in ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_libplatform.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/V8Config-shared.cmake ${CURRENT_PACKAGES_DIR}/share/v8/V8Config.cmake @ONLY)
    file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/snapshot_blob.bin DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    set(PREFIX ${CURRENT_PACKAGES_DIR})
    configure_file(${CURRENT_PORT_DIR}/v8_monolith.pc.in ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/v8_monolith.pc @ONLY)
    set(PREFIX ${CURRENT_PACKAGES_DIR}/debug)
    configure_file(${CURRENT_PORT_DIR}/v8_monolith.pc.in ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/v8_monolith.pc @ONLY)
    configure_file(${CURRENT_PORT_DIR}/V8Config-static.cmake ${CURRENT_PACKAGES_DIR}/share/v8/V8Config.cmake @ONLY)
endif()


vcpkg_copy_pdbs()

# v8 libraries are listed as SYSTEM_LIBRARIES because the pc files reference each other.
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m dl pthread Winmm DbgHelp v8_libbase v8_libplatform v8)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
