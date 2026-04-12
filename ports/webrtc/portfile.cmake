vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(WEBRTC_TARGET_IS_LINUX FALSE)
set(WEBRTC_TARGET_IS_MACOS FALSE)
set(WEBRTC_TARGET_IS_WINDOWS FALSE)
if(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE MATCHES "^(arm64|x64)$")
    set(WEBRTC_TARGET_IS_LINUX TRUE)
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE MATCHES "^(arm64|x64)$")
    set(WEBRTC_TARGET_IS_MACOS TRUE)
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "^(arm64|x86|x64)$")
    set(WEBRTC_TARGET_IS_WINDOWS TRUE)
else()
    message(FATAL_ERROR "webrtc currently supports only x64-linux, arm64-linux, arm64-osx, x64-osx, arm64-windows, x86-windows, and x64-windows.")
endif()

set(WEBRTC_PATCHES
    webrtc-0001-disable-perfetto-when-off.patch
    webrtc-0002-export-enable-media-with-defaults.patch
    webrtc-0003-fix-rtp-config-optional.patch
    webrtc-0004-use-upstream-rnnoise.patch
    webrtc-0005-use-external-openssl.patch
    webrtc-0006-make-dav1d-decoder-deps-conditional.patch
    webrtc-0007-fix-rtp-packet-info-eq-for-msvc.patch
    webrtc-0008-fix-audio-device-core-win-goto-scope.patch
    webrtc-0009-fix-avx2-intrinsics-for-msvc.patch
    webrtc-0010-disable-arm-denormal-disabler-for-msvc.patch
    webrtc-0011-make-linux-audio-backends-optional.patch
)

set(BUILD_PATCHES
    build-0001-drop-module-deps-from-toolchain-invocations.patch
    build-0002-fix-apple-arflags-usage.patch
    build-0003-disable-fno-lifetime-dse.patch
    build-0004-disable-sanitize-c-array-bounds.patch
    build-0005-disable-sanitize-return.patch
    build-0006-skip-local-vs-debugger-copy.patch
    build-0007-fix-windows-pdb-commands.patch
    build-0008-disable-crel-on-linux-arm64.patch
)

set(RNNOISE_PATCHES
    rnnoise-0001-fix-neon-reinterpret-for-msvc.patch
)

set(WEBRTC_SOURCE_URL "https://webrtc.googlesource.com/src")
set(WEBRTC_SOURCE_REF "aa217206b9ce8b929dc56d112d670a5931ef8cc1")

include("${CMAKE_CURRENT_LIST_DIR}/webrtc-functions.cmake")

declare_webrtc_repo(build
    DESTINATION "build"
    URL "https://chromium.googlesource.com/chromium/src/build"
    REF "f123ee3617656ae843bd7f68f173c651fe2ec4bf"
    PATCHES_VAR BUILD_PATCHES
)
declare_webrtc_repo(buildtools
    DESTINATION "buildtools"
    URL "https://chromium.googlesource.com/chromium/src/buildtools"
    REF "95ed44cf5f06dbb5861030b91c9db9ccb4316762"
)
declare_webrtc_repo(rnnoise
    DESTINATION "third_party/rnnoise"
    URL "https://github.com/xiph/rnnoise.git"
    REF "c9137adac37fe21ede831f8a0aa31c17560c01e7"
    PATCHES_VAR RNNOISE_PATCHES
)

declare_webrtc_generated_external(third_party_root PHASE pre_absl)
declare_webrtc_generated_external(testing PHASE pre_absl)
declare_webrtc_generated_external(tools PHASE pre_absl)
declare_webrtc_generated_external(libsrtp LIB_ROOT_VAR LIBSRTP_LIB_ROOT)
declare_webrtc_generated_external(libyuv LIB_ROOT_VAR LIBYUV_LIB_ROOT)
declare_webrtc_generated_external(libvpx LIB_ROOT_VAR LIBVPX_LIB_ROOT)
declare_webrtc_generated_external(opus LIB_ROOT_VAR OPUS_LIB_ROOT)
declare_webrtc_generated_external(libaom LIB_ROOT_VAR LIBAOM_LIB_ROOT)
declare_webrtc_generated_external(jsoncpp LIB_ROOT_VAR JSONCPP_LIB_ROOT)
declare_webrtc_generated_external(pffft LIB_ROOT_VAR PFFFT_LIB_ROOT)
declare_webrtc_generated_external(alsa)
declare_webrtc_generated_external(pulseaudio)
declare_webrtc_generated_external(rnnoise)
declare_webrtc_generated_external(dav1d)
declare_webrtc_generated_external(llvm-libc)
declare_webrtc_generated_external(protobuf)
declare_webrtc_generated_external(googletest)
declare_webrtc_generated_external(catapult)
declare_webrtc_generated_external(nasm TOOL_PATH_VAR WEBRTC_NASM_PROGRAM)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "${WEBRTC_SOURCE_URL}"
    REF "${WEBRTC_SOURCE_REF}"
    PATCHES ${WEBRTC_PATCHES}
)

fetch_declared_webrtc_repos("${SOURCE_PATH}")

if(WEBRTC_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string(
        "${SOURCE_PATH}/build/config/win/BUILD.gn"
        "      # Desktop Windows: static CRT.\n      configs = [ \":static_crt\" ]\n"
        "      # Vcpkg's x64-windows triplet expects the dynamic CRT for consumers.\n      configs = [ \":dynamic_crt\" ]\n"
    )
endif()

file(REMOVE_RECURSE "${SOURCE_PATH}/testing" "${SOURCE_PATH}/tools")

vcpkg_download_distfile(
    WEBRTC_RNNOISE_MODEL_PATH
    URLS https://media.xiph.org/rnnoise/models/rnnoise_data-0a8755f8e2d834eff6a54714ecc7d75f9932e845df35f8b59bc52a7cfe6e8b37.tar.gz
    FILENAME rnnoise_data-0a8755f8e2d834eff6a54714ecc7d75f9932e845df35f8b59bc52a7cfe6e8b37.tar.gz
    SHA512 b327d2fc5095be9ed66c5246a86b1a1ce180e9de875c4e5e8778f975560d1f035da40a8686dc1c3fd91c8e709be65d2638eccaa9f866b6f3d85f8d0d16bd2184
)

vcpkg_extract_archive(
    ARCHIVE "${WEBRTC_RNNOISE_MODEL_PATH}"
    DESTINATION "${SOURCE_PATH}/third_party/rnnoise/modeldata"
)
file(COPY "${SOURCE_PATH}/third_party/rnnoise/modeldata/src/rnnoise_data.c" DESTINATION "${SOURCE_PATH}/third_party/rnnoise/src/")
file(COPY "${SOURCE_PATH}/third_party/rnnoise/modeldata/src/rnnoise_data.h" DESTINATION "${SOURCE_PATH}/third_party/rnnoise/src/")

vcpkg_find_acquire_program(PYTHON3)
vcpkg_replace_string("${SOURCE_PATH}/.gn" "script_executable = \"python3\"" "script_executable = \"${PYTHON3}\"")
file(WRITE "${SOURCE_PATH}/build/config/gclient_args.gni" "# Generated for local vcpkg webrtc port\ngenerate_location_tags = true\n")
if(WEBRTC_TARGET_IS_WINDOWS OR WEBRTC_TARGET_IS_LINUX)
    set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} 0)
    if(WEBRTC_TARGET_IS_WINDOWS)
        file(MAKE_DIRECTORY "${SOURCE_PATH}/build/util")
        file(WRITE "${SOURCE_PATH}/build/util/LASTCHANGE.committime" "0\n")
    endif()
    file(MAKE_DIRECTORY "${SOURCE_PATH}/third_party/compiler-rt")
    file(WRITE "${SOURCE_PATH}/third_party/compiler-rt/BUILD.gn" "group(\"atomic\") {}\n")
endif()
set(WEBRTC_ABSL_EXPORTS "${CURRENT_BUILDTREES_DIR}/webrtc-absl-targets.cmake")

function(generate_external_dep source_path dep_name include_root lib_root build_config)
    set(options)
    set(oneValueArgs TOOL_PATH)
    cmake_parse_arguments(PARSE_ARGV 5 ARG "${options}" "${oneValueArgs}" "")
    set(GENERATE_EXTERNAL_DEP_COMMAND
        "${PYTHON3}" "${CMAKE_CURRENT_LIST_DIR}/generate_external_third_party.py"
        --source-root "${source_path}"
        --dep "${dep_name}"
        --include-root "${include_root}"
        --lib-root "${lib_root}"
    )
    if(DEFINED ARG_TOOL_PATH AND NOT ARG_TOOL_PATH STREQUAL "")
        list(APPEND GENERATE_EXTERNAL_DEP_COMMAND --tool-path "${ARG_TOOL_PATH}")
    endif()
    vcpkg_execute_required_process(
        COMMAND ${GENERATE_EXTERNAL_DEP_COMMAND}
        WORKING_DIRECTORY "${source_path}"
        LOGNAME "generate-${TARGET_TRIPLET}-external-${dep_name}-${build_config}"
    )
endfunction()

function(set_webrtc_build_config build_config)
    if("${build_config}" STREQUAL "debug")
        set(BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg" PARENT_SCOPE)
        set(BUILD_DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" PARENT_SCOPE)
        set(IS_DEBUG "true" PARENT_SCOPE)
        set(SYMBOL_LEVEL "2" PARENT_SCOPE)
        set(ABSL_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
        set(LIBYUV_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
        set(SSL_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
        set(LIBVPX_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
        set(OPUS_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
        set(LIBSRTP_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
        set(LIBAOM_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
        set(JSONCPP_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
        set(PFFFT_LIB_ROOT "${CURRENT_INSTALLED_DIR}/debug/lib" PARENT_SCOPE)
    else()
        set(BUILD_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel" PARENT_SCOPE)
        set(BUILD_DESTINATION "${CURRENT_PACKAGES_DIR}/lib" PARENT_SCOPE)
        set(IS_DEBUG "false" PARENT_SCOPE)
        set(SYMBOL_LEVEL "0" PARENT_SCOPE)
        set(ABSL_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
        set(LIBYUV_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
        set(SSL_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
        set(LIBVPX_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
        set(OPUS_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
        set(LIBSRTP_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
        set(LIBAOM_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
        set(JSONCPP_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
        set(PFFFT_LIB_ROOT "${CURRENT_INSTALLED_DIR}/lib" PARENT_SCOPE)
    endif()
endfunction()

function(setup_webrtc_windows_toolchain build_config)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    if("${build_config}" STREQUAL "debug")
        set(WEBRTC_EXTRA_CFLAGS_C "${VCPKG_COMBINED_C_FLAGS_DEBUG}" PARENT_SCOPE)
        set(WEBRTC_EXTRA_CFLAGS_CC "${VCPKG_COMBINED_CXX_FLAGS_DEBUG}" PARENT_SCOPE)
        set(WEBRTC_EXTRA_LDFLAGS "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_DEBUG}" PARENT_SCOPE)
        set(WEBRTC_EXTRA_ARFLAGS "${VCPKG_COMBINED_STATIC_LINKER_FLAGS_DEBUG}" PARENT_SCOPE)
    else()
        set(WEBRTC_EXTRA_CFLAGS_C "${VCPKG_COMBINED_C_FLAGS_RELEASE}" PARENT_SCOPE)
        set(WEBRTC_EXTRA_CFLAGS_CC "${VCPKG_COMBINED_CXX_FLAGS_RELEASE}" PARENT_SCOPE)
        set(WEBRTC_EXTRA_LDFLAGS "${VCPKG_COMBINED_SHARED_LINKER_FLAGS_RELEASE}" PARENT_SCOPE)
        set(WEBRTC_EXTRA_ARFLAGS "${VCPKG_COMBINED_STATIC_LINKER_FLAGS_RELEASE}" PARENT_SCOPE)
    endif()
endfunction()

function(setup_webrtc_host_xcode_toolchain)
    find_program(XCRUN NAMES xcrun REQUIRED)
    foreach(XCODE_TOOL IN ITEMS clang clang++ ar nm strip install_name_tool libtool)
        execute_process(
            COMMAND "${XCRUN}" --find "${XCODE_TOOL}"
            OUTPUT_VARIABLE WEBRTC_${XCODE_TOOL}_PROGRAM
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE WEBRTC_${XCODE_TOOL}_RESULT
        )
        if(NOT WEBRTC_${XCODE_TOOL}_RESULT EQUAL 0 OR WEBRTC_${XCODE_TOOL}_PROGRAM STREQUAL "")
            message(FATAL_ERROR "Failed to locate '${XCODE_TOOL}' via xcrun.")
        endif()
    endforeach()

    execute_process(
        COMMAND "${WEBRTC_clang_PROGRAM}" -print-resource-dir
        OUTPUT_VARIABLE WEBRTC_CLANG_RESOURCE_DIR
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE WEBRTC_CLANG_RESOURCE_RESULT
    )
    if(NOT WEBRTC_CLANG_RESOURCE_RESULT EQUAL 0 OR WEBRTC_CLANG_RESOURCE_DIR STREQUAL "")
        message(FATAL_ERROR "Failed to query clang resource dir from '${WEBRTC_clang_PROGRAM}'.")
    endif()

    get_filename_component(WEBRTC_CLANG_VERSION "${WEBRTC_CLANG_RESOURCE_DIR}" NAME)
    if(WEBRTC_CLANG_VERSION STREQUAL "")
        message(FATAL_ERROR "Failed to derive clang version from resource dir '${WEBRTC_CLANG_RESOURCE_DIR}'.")
    endif()

    execute_process(
        COMMAND "${XCRUN}" --show-sdk-path
        OUTPUT_VARIABLE WEBRTC_MAC_SDK_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
        RESULT_VARIABLE WEBRTC_MAC_SDK_RESULT
    )
    if(NOT WEBRTC_MAC_SDK_RESULT EQUAL 0 OR WEBRTC_MAC_SDK_PATH STREQUAL "")
        message(FATAL_ERROR "Failed to locate macOS SDK via xcrun.")
    endif()

    set(XCODE_HOST_ROOT "${CURRENT_BUILDTREES_DIR}/xcode-host" PARENT_SCOPE)
    set(XCODE_HOST_BIN_DIR "${CURRENT_BUILDTREES_DIR}/xcode-host/bin" PARENT_SCOPE)
    set(XCODE_HOST_LIB_CLANG_DIR "${CURRENT_BUILDTREES_DIR}/xcode-host/lib/clang" PARENT_SCOPE)
    set(HOST_CLANG_RESOURCE_DIR "${WEBRTC_CLANG_RESOURCE_DIR}" PARENT_SCOPE)
    foreach(XCODE_TOOL IN ITEMS clang clang++ ar nm strip install_name_tool libtool)
        set(WEBRTC_${XCODE_TOOL}_PROGRAM "${WEBRTC_${XCODE_TOOL}_PROGRAM}" PARENT_SCOPE)
    endforeach()
    set(WEBRTC_CLANG_BASE_PATH "${CURRENT_BUILDTREES_DIR}/xcode-host" PARENT_SCOPE)
    set(WEBRTC_CLANG_VERSION "${WEBRTC_CLANG_VERSION}" PARENT_SCOPE)
    set(WEBRTC_MAC_SDK_PATH "${WEBRTC_MAC_SDK_PATH}" PARENT_SCOPE)
endfunction()

set(GN "${CURRENT_HOST_INSTALLED_DIR}/tools/gn/gn${VCPKG_HOST_EXECUTABLE_SUFFIX}")
set(NINJA "${CURRENT_HOST_INSTALLED_DIR}/tools/ninja/ninja${VCPKG_HOST_EXECUTABLE_SUFFIX}")
if(WEBRTC_TARGET_IS_MACOS)
    setup_webrtc_host_xcode_toolchain()
    file(MAKE_DIRECTORY "${XCODE_HOST_BIN_DIR}" "${XCODE_HOST_LIB_CLANG_DIR}")
    file(REMOVE
        "${XCODE_HOST_BIN_DIR}/clang"
        "${XCODE_HOST_BIN_DIR}/clang++"
        "${XCODE_HOST_BIN_DIR}/llvm-ar"
        "${XCODE_HOST_BIN_DIR}/llvm-nm"
        "${XCODE_HOST_BIN_DIR}/llvm-strip"
        "${XCODE_HOST_BIN_DIR}/llvm-install-name-tool"
        "${XCODE_HOST_BIN_DIR}/libtool"
    )
    file(CREATE_LINK "${WEBRTC_clang_PROGRAM}" "${XCODE_HOST_BIN_DIR}/clang" SYMBOLIC)
    file(CREATE_LINK "${WEBRTC_clang++_PROGRAM}" "${XCODE_HOST_BIN_DIR}/clang++" SYMBOLIC)
    string(CONFIGURE [=[
#!/bin/bash
exec "@PYTHON3@" - "$@" <<'PY'
import pathlib
import shlex
import subprocess
import sys

args = []
for arg in sys.argv[1:]:
    if arg.startswith("@"):
        rsp_path = pathlib.Path(arg[1:])
        rsp_text = rsp_path.read_text()
        args.extend(shlex.split(rsp_text))
    else:
        args.append(arg)

sys.exit(subprocess.call([r"@WEBRTC_ar_PROGRAM@", *args]))
PY
]=] WEBRTC_LLVM_AR_WRAPPER @ONLY)
    file(WRITE "${XCODE_HOST_BIN_DIR}/llvm-ar" "${WEBRTC_LLVM_AR_WRAPPER}")
    file(CHMOD "${XCODE_HOST_BIN_DIR}/llvm-ar" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
    file(CREATE_LINK "${WEBRTC_nm_PROGRAM}" "${XCODE_HOST_BIN_DIR}/llvm-nm" SYMBOLIC)
    file(CREATE_LINK "${WEBRTC_strip_PROGRAM}" "${XCODE_HOST_BIN_DIR}/llvm-strip" SYMBOLIC)
    file(CREATE_LINK "${WEBRTC_install_name_tool_PROGRAM}" "${XCODE_HOST_BIN_DIR}/llvm-install-name-tool" SYMBOLIC)
    file(CREATE_LINK "${WEBRTC_libtool_PROGRAM}" "${XCODE_HOST_BIN_DIR}/libtool" SYMBOLIC)
    file(CREATE_LINK "${HOST_CLANG_RESOURCE_DIR}" "${XCODE_HOST_LIB_CLANG_DIR}/${WEBRTC_CLANG_VERSION}" SYMBOLIC)
endif()

vcpkg_find_acquire_program(NASM)
set(WEBRTC_NASM_PROGRAM "${NASM}")

if(NOT EXISTS "${GN}")
    message(FATAL_ERROR "Missing bundled GN binary: ${GN}")
endif()

if(NOT EXISTS "${NINJA}")
    message(FATAL_ERROR "Missing bundled Ninja binary: ${NINJA}")
endif()

foreach(BUILD_CONFIG IN ITEMS debug release)
    set_webrtc_build_config("${BUILD_CONFIG}")
    if(WEBRTC_TARGET_IS_WINDOWS)
        setup_webrtc_windows_toolchain("${BUILD_CONFIG}")
    endif()

    generate_declared_webrtc_externals("${SOURCE_PATH}" "${BUILD_CONFIG}" pre_absl)
    file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/abseil-cpp")
    vcpkg_execute_required_process(
        COMMAND
            "${PYTHON3}" "${CMAKE_CURRENT_LIST_DIR}/generate_external_absl.py"
            --manifest "${CMAKE_CURRENT_LIST_DIR}/absl-labels.txt"
            --output "${SOURCE_PATH}/third_party/abseil-cpp"
            --include-root "${CURRENT_INSTALLED_DIR}/include"
            --lib-root "${ABSL_LIB_ROOT}"
            --cmake-absl-targets "${CURRENT_INSTALLED_DIR}/share/absl/abslTargets.cmake"
            --cmake-output "${WEBRTC_ABSL_EXPORTS}"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "generate-${TARGET_TRIPLET}-external-absl-${BUILD_CONFIG}"
    )
    generate_declared_webrtc_externals("${SOURCE_PATH}" "${BUILD_CONFIG}" post_absl)

    set(WEBRTC_GN_ARGS
        "clang_use_chrome_plugins=false"
        "init_stack_vars=false"
        "use_sysroot=false"
        "use_custom_libcxx=false"
        "use_custom_libcxx_for_host=false"
        "use_clang_modules=false"
        "use_siso=false"
        "use_remoteexec=false"
        "is_debug=${IS_DEBUG}"
        "is_component_build=false"
        "symbol_level=${SYMBOL_LEVEL}"
        "treat_warnings_as_errors=false"
        "rtc_build_examples=false"
        "rtc_build_tools=false"
        "rtc_include_tests=false"
        "rtc_enable_protobuf=false"
        "rtc_build_ssl=false"
        "rtc_ssl_root=\"${CURRENT_INSTALLED_DIR}/include\""
        "rtc_ssl_lib_path=\"${SSL_LIB_ROOT}\""
        "libsrtp_build_boringssl=false"
        "libsrtp_ssl_root=\"${CURRENT_INSTALLED_DIR}/include\""
        "use_system_libjpeg=true"
        "use_libjpeg_turbo=false"
        "rtc_build_libvpx=true"
        "rtc_build_opus=true"
        "rtc_include_dav1d_in_internal_decoder_factory=false"
        "rtc_use_pipewire=false"
        "rtc_use_x11=false"
        "use_glib=false"
        "enable_rust=false"
        "enable_rust_cxx=false"
        "rtc_use_h264=false"
    )
    if(WEBRTC_TARGET_IS_LINUX)
        if("alsa" IN_LIST FEATURES)
            list(APPEND WEBRTC_GN_ARGS "rtc_include_alsa_audio=true")
        else()
            list(APPEND WEBRTC_GN_ARGS "rtc_include_alsa_audio=false")
        endif()
        if("pulseaudio" IN_LIST FEATURES)
            list(APPEND WEBRTC_GN_ARGS "rtc_include_pulse_audio=true")
        else()
            list(APPEND WEBRTC_GN_ARGS "rtc_include_pulse_audio=false")
        endif()
        list(APPEND WEBRTC_GN_ARGS
            "target_os=\"linux\""
            "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\""
            "custom_toolchain=\"//build/toolchain/linux:${VCPKG_TARGET_ARCHITECTURE}\""
            "is_clang=false"
            "use_lld=false"
        )
    elseif(WEBRTC_TARGET_IS_MACOS)
        list(APPEND WEBRTC_GN_ARGS
            "target_os=\"mac\""
            "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\""
            "custom_toolchain=\"//build/toolchain/mac:clang_${VCPKG_TARGET_ARCHITECTURE}\""
            "host_toolchain=\"//build/toolchain/mac:clang_${VCPKG_TARGET_ARCHITECTURE}\""
            "is_clang=true"
            "clang_base_path=\"${WEBRTC_CLANG_BASE_PATH}\""
            "clang_version=\"${WEBRTC_CLANG_VERSION}\""
            "mac_sdk_path=\"${WEBRTC_MAC_SDK_PATH}\""
        )
    elseif(WEBRTC_TARGET_IS_WINDOWS)
        list(APPEND WEBRTC_GN_ARGS
            "target_os=\"win\""
            "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\""
            "is_clang=false"
            "use_lld=false"
            "extra_cflags_c=\"${WEBRTC_EXTRA_CFLAGS_C}\""
            "extra_cflags_cc=\"${WEBRTC_EXTRA_CFLAGS_CC}\""
            "extra_ldflags=\"${WEBRTC_EXTRA_LDFLAGS}\""
            "extra_arflags=\"${WEBRTC_EXTRA_ARFLAGS}\""
        )
    endif()
    string(JOIN " " GN_ARGS ${WEBRTC_GN_ARGS})

    vcpkg_execute_required_process(
        COMMAND "${GN}" gen "${BUILD_DIR}" "--args=${GN_ARGS}"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "generate-${TARGET_TRIPLET}-${BUILD_CONFIG}"
    )

    vcpkg_execute_required_process(
        COMMAND "${NINJA}" -C "${BUILD_DIR}" webrtc
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "build-${TARGET_TRIPLET}-${BUILD_CONFIG}"
    )

    if(WEBRTC_TARGET_IS_WINDOWS)
        file(INSTALL "${BUILD_DIR}/obj/webrtc.lib" DESTINATION "${BUILD_DESTINATION}")
    else()
        file(INSTALL "${BUILD_DIR}/obj/libwebrtc.a" DESTINATION "${BUILD_DESTINATION}")
    endif()
endforeach()

set(WEBRTC_LINUX_INTERFACE_DEFINITIONS "USE_AURA=1;USE_OZONE=1;USE_UDEV;WEBRTC_LINUX;WEBRTC_POSIX")
if(VCPKG_TARGET_IS_LINUX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    string(PREPEND WEBRTC_LINUX_INTERFACE_DEFINITIONS "LIBYUV_DISABLE_NEON;WEBRTC_ENABLE_AVX2;")
endif()

set(WEBRTC_COMMON_INTERFACE_COMPILE_DEFINITIONS
    CHROMIUM
    DYNAMIC_ANNOTATIONS_ENABLED=1
    LIBYUV_DISABLE_SVE
    LIBYUV_DISABLE_SME
    LIBYUV_DISABLE_LSX
    LIBYUV_DISABLE_LASX
    PROTOBUF_ENABLE_DEBUG_LOGGING_MAY_LEAK_PII=0
    RTC_DAV1D_IN_INTERNAL_DECODER_FACTORY
    RTC_ENABLE_VP9
    WEBRTC_DEPRECATE_PLAN_B
    WEBRTC_ENCODER_PSNR_STATS
    WEBRTC_HAVE_SCTP
    WEBRTC_INCLUDE_INTERNAL_AUDIO_DEVICE
    WEBRTC_NON_STATIC_TRACE_EVENT_HANDLERS=0
    WEBRTC_STRICT_FIELD_TRIALS=0
)
set(WEBRTC_INTERFACE_COMPILE_DEFINITIONS ${WEBRTC_COMMON_INTERFACE_COMPILE_DEFINITIONS})
set(WEBRTC_INTERFACE_LINK_OPTIONS)

if(VCPKG_TARGET_IS_LINUX)
    list(APPEND WEBRTC_INTERFACE_COMPILE_DEFINITIONS ${WEBRTC_LINUX_INTERFACE_DEFINITIONS})
elseif(VCPKG_TARGET_IS_OSX)
    list(APPEND WEBRTC_INTERFACE_COMPILE_DEFINITIONS
        WEBRTC_MAC
        WEBRTC_POSIX
    )
    list(APPEND WEBRTC_INTERFACE_LINK_OPTIONS
        "SHELL:-framework AudioToolbox"
        "SHELL:-framework CoreAudio"
        "SHELL:-framework CoreFoundation"
        "SHELL:-framework Foundation"
        "SHELL:-framework AppKit"
        "SHELL:-framework ApplicationServices"
    )
elseif(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND WEBRTC_INTERFACE_COMPILE_DEFINITIONS
        NOMINMAX
        UNICODE
        WIN32
        WIN32_LEAN_AND_MEAN
        WEBRTC_WIN
    )
endif()

foreach(HEADER_ROOT IN ITEMS
    api
    common_video
    logging
    media
    modules
    p2p
    rtc_base
    system_wrappers
)
    file(INSTALL
        DIRECTORY "${SOURCE_PATH}/${HEADER_ROOT}/"
        DESTINATION "${CURRENT_PACKAGES_DIR}/include/${HEADER_ROOT}"
        FILES_MATCHING
            PATTERN "*.h"
            PATTERN "*.hpp"
            PATTERN "*.inc"
    )
endforeach()

file(STRINGS "${CMAKE_CURRENT_LIST_DIR}/package-remove-paths.txt" PACKAGE_REMOVE_PATHS ENCODING UTF-8)
foreach(REMOVE_PATH IN LISTS PACKAGE_REMOVE_PATHS)
    if(REMOVE_PATH MATCHES "^[ \t]*#" OR REMOVE_PATH STREQUAL "")
        continue()
    endif()
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/${REMOVE_PATH}")
endforeach()

file(REMOVE "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg_abi_info.txt")

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-webrtcConfig.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-webrtc/unofficial-webrtcConfig.cmake"
    @ONLY
)
file(INSTALL "${WEBRTC_ABSL_EXPORTS}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-webrtc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
