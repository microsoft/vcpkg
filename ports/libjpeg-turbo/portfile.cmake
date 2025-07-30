if(EXISTS "${CURRENT_INSTALLED_DIR}/share/mozjpeg/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if mozjpeg is installed. Please remove mozjpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()
if(EXISTS "${CURRENT_INSTALLED_DIR}/share/ijg-libjpeg/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if ijg-libjpeg is installed. Please remove ijg-libjpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libjpeg-turbo/libjpeg-turbo
    REF "${VERSION}"
    SHA512 4937b63a27818cdb5087091b2d78837f7f385fd6b4d3e3fcaf4d9ad2944fed4a00020dcacb33e9c2fd4b0f9d9851fb4051ed3da86f606aca5167357262a73e89
    HEAD_REF master
    PATCHES
        add-options-for-exes-docs-headers.patch
        # workaround for vcpkg bug see #5697 on github for more information
        workaround_cmake_system_processor.patch
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=OFF)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR (VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore"))
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=ON -DNEON_INTRINSICS=ON)
else()
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=ON)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    set(ENV{PATH} "$ENV{PATH};${NASM_EXE_PATH}")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(ENV{_CL_} "-DNO_GETENV -DNO_PUTENV")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" WITH_CRT_DLL)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jpeg7 WITH_JPEG7
        jpeg8 WITH_JPEG8
        tools ENABLE_EXECUTABLES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DINSTALL_DOCS=OFF
        -DWITH_CRT_DLL=${WITH_CRT_DLL}
        ${FEATURE_OPTIONS}
        ${LIBJPEGTURBO_SIMD}
    OPTIONS_DEBUG
        -DENABLE_EXECUTABLES=OFF
        -DINSTALL_HEADERS=OFF
    MAYBE_UNUSED_VARIABLES
        WITH_CRT_DLL
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(ENABLE_EXECUTABLES)
    vcpkg_copy_tools(
        TOOL_NAMES cjpeg djpeg jpegtran rdjpgcom wrjpgcom
        AUTO_CLEAN
    )
    vcpkg_clean_executables_in_bin(
        FILE_NAMES tjbench
    )
endif()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libjpeg-turbo)

# Rename libraries for static builds
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/jpeg.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/turbojpeg.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-static.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg.lib")
    endif()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")

    if (EXISTS "${CURRENT_PACKAGES_DIR}/share/${PORT}/libjpeg-turboTargets-debug.cmake")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/libjpeg-turboTargets-debug.cmake"
            "jpeg-static${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "jpeg${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" IGNORE_UNCHANGED)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/libjpeg-turboTargets-debug.cmake"
            "turbojpeg-static${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "turbojpeg${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" IGNORE_UNCHANGED)
    endif()
    if (EXISTS "${CURRENT_PACKAGES_DIR}/share/${PORT}/libjpeg-turboTargets-release.cmake")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/libjpeg-turboTargets-release.cmake"
            "jpeg-static${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "jpeg${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" IGNORE_UNCHANGED)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/libjpeg-turboTargets-release.cmake"
            "turbojpeg-static${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" "turbojpeg${VCPKG_TARGET_STATIC_LIBRARY_SUFFIX}" IGNORE_UNCHANGED)
    endif()
endif()

file(REMOVE_RECURSE
     "${CURRENT_PACKAGES_DIR}/debug/share"
     "${CURRENT_PACKAGES_DIR}/debug/include"
     "${CURRENT_PACKAGES_DIR}/share/man")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/jpeg")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
