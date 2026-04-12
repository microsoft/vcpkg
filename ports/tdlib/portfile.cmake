vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tdlib/td
    REF f06b0bac65278b03d26414c096080e7bfecfef52
    HEAD_REF master
    SHA512 91967a24eee9f1491b780ce72a1323aa99e228c10ecd588979e325d57417c6897eeebf375c609c99b2fd0d6137bcb950628a30f5cfc2e6838fb14d2803d02b7a
    PATCHES
        fix-pc.patch
)

vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/gperf")

# When cross-compiling (e.g. x64-android from x64-linux), TDLib's build system
# refuses to build any of its host-native code-generator executables
# (generate_mime_types_gperf, generate_common, generate_mtproto, generate_json,
# tl-parser) because CMAKE_CROSSCOMPILING is TRUE for the target build.
#
# Those generators write their output directly back into the source tree:
#   tdutils/generate/auto/  – MIME-type ↔ extension lookup tables (.cpp)
#   td/generate/auto/td/    – TL API bindings (.cpp / .h)
#
# Without the generated files the cross-compile fails immediately with
# "no such file or directory" for the missing .cpp sources.
#
# TDLib documents a two-step cross-compilation workflow:
#   1. Native build: cmake --build . --target prepare_cross_compiling
#      → generates all auto/*.cpp and auto/*.h into the source tree
#   2. Cross build: regular cmake configure + install
#
# Both the MIME-type files and the TL API files are covered by the
# prepare_cross_compiling target, so this single native step is sufficient.
if(VCPKG_CROSSCOMPILING)
    message(STATUS "[tdlib] Cross-compiling detected – running native source-generation step")

    set(_tdlib_gen_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-native-gen")
    file(MAKE_DIRECTORY "${_tdlib_gen_dir}")

    # Configure a plain (non-cross) build whose only job is to materialise
    # all generated sources.  We intentionally pass no toolchain file so CMake
    # picks up the host system compiler.
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}"
            "-S${SOURCE_PATH}"
            "-B${_tdlib_gen_dir}"
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DTDUTILS_MIME_TYPE=ON"
            "-DTDUTILS_USE_EXTERNAL_DEPENDENCIES=OFF"
            "-DTD_GENERATE_SOURCE_FILES=ON"
            "-DTD_ENABLE_JNI=OFF"
            "-DTD_ENABLE_DOTNET=OFF"
            "-DTD_E2E_ONLY=OFF"
            "-DTD_INSTALL_SHARED_LIBRARIES=OFF"
            "-DTD_INSTALL_STATIC_LIBRARIES=OFF"
            "-DBUILD_TESTING=OFF"
        WORKING_DIRECTORY "${_tdlib_gen_dir}"
        LOGNAME "configure-native-gen-${TARGET_TRIPLET}"
    )

    # prepare_cross_compiling depends on tdmime_auto, tl_generate_mtproto,
    # tl_generate_common and tl_generate_json – building it materialises every
    # auto-generated .cpp / .h file that the cross-compile build needs.
    vcpkg_execute_required_process(
        COMMAND "${CMAKE_COMMAND}" --build "${_tdlib_gen_dir}"
                --target prepare_cross_compiling
        WORKING_DIRECTORY "${_tdlib_gen_dir}"
        LOGNAME "build-native-gen-${TARGET_TRIPLET}"
    )

    unset(_tdlib_gen_dir)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DTD_INSTALL_SHARED_LIBRARIES=OFF
        -DTD_INSTALL_STATIC_LIBRARIES=ON
        -DTD_ENABLE_JNI=${VCPKG_TARGET_IS_ANDROID}
        -DTD_ENABLE_DOTNET=OFF
        -DTD_GENERATE_SOURCE_FILES=OFF
        -DTD_E2E_ONLY=OFF
        -DTD_ENABLE_LTO=${CMAKE_HOST_WIN32}
        -DTD_ENABLE_MULTI_PROCESSOR_COMPILATION=${VCPKG_DETECTED_MSVC}
        -DBUILD_TESTING=OFF
    MAYBE_UNUSED_VARIABLES
        TD_ENABLE_MULTI_PROCESSOR_COMPILATION
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/Td")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
