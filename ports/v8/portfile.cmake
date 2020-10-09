
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
    SHA512 3e506ee73bab6d21c8004c97a350a6bc9c685bd8f0e3ee937962767af1b3f3bb7cf6effa937618ca9033bf23e366691a7b97ff7f37c9b8e0e962b93a999cf156
    PATCHES ${CURRENT_PORT_DIR}/v8.patch ${CURRENT_PORT_DIR}/3f8dc4b.patch
)

checkout_in_path(
  "${SOURCE_PATH}/build"
  "https://chromium.googlesource.com/chromium/src/build.git"
  "26e9d485d01d6e0eb9dadd21df767a63494c8fea"
  "8e7593cbc0b02fb29ebc435504c2231d4ea2feb2549369e4066e5e7015e5a4568da098c096a6251bb42d6ad1f6ff785e9fa65239f4ebc53bc69fc25321441338"
  "build.patch"
)
checkout_in_path(
    ${SOURCE_PATH}/third_party/zlib
    https://chromium.googlesource.com/chromium/src/third_party/zlib.git
    156be8c52f80cde343088b4a69a80579101b6e67
    34ec2f1fd12b9fa729f39857af7719d4813bd492eee494744dd63e1209ba7c3c54819f0c17d727fe190ade888362b6c737ff26b9aed6d11333e20f85c51f9658
)
checkout_in_path(
    ${SOURCE_PATH}/base/trace_event/common
    https://chromium.googlesource.com/chromium/src/base/trace_event/common.git
    dab187b372fc17e51f5b9fad8201813d0aed5129
    17e761223152176eff23684b15c1708e13603418c0ae95cd0cbff902d149e9643e3c3692f368b061fa9d68036250c20433862302c276472c632bb8a5cb866aee
)
checkout_in_path(
    ${SOURCE_PATH}/third_party/googletest/src
    https://chromium.googlesource.com/external/github.com/google/googletest.git
    10b1902d893ea8cc43c69541d70868f91af3646b
    28dab959ed95ff53948e8aec64aed3248394bec89a78fc096d1f3898af57f140995ddaf0a01ea0510cc99be6c6401f29481b5f29af5103c655a4e7430ab061bb
)
checkout_in_path(
    ${SOURCE_PATH}/third_party/jinja2
    https://chromium.googlesource.com/chromium/src/third_party/jinja2.git
    b41863e42637544c2941b574c7877d3e1f663e25
    d9997654756c1bae53cd60d8275b9333ed759f8f820e09e8d2632d7c0f96cfa02ca8a32b3a545ea660ee0083127fca0ceb2698c87e2d2f1dbdb7001517f473e2
)
checkout_in_path(
    ${SOURCE_PATH}/third_party/markupsafe
    https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git
    8f45f5cfa0009d2a70589bcda0349b8cb2b72783
    9bc7bcf5b25ef5e793e5cebdf132dd0e6a1e8ac54c7401d8b821ddbe533babbf19d719636b7f74abb30a7a9f94e7d5680b4490f7ec84ca54f6e3d67327362ceb
)

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
