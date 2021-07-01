if(EXISTS "${CURRENT_INSTALLED_DIR}/share/mozjpeg/copyright")
    message(FATAL_ERROR "Can't build ${PORT} if mozjpeg is installed. Please remove mozjpeg:${TARGET_TRIPLET}, and try to install ${PORT}:${TARGET_TRIPLET} again.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libjpeg-turbo/libjpeg-turbo
    REF c23672ce52ae53bd846b555439aa0a070b6d2c07 # 2.1.0
    SHA512 ae6b442252e4560c3387b4660539973ecc32ddc9425b6cbd5a1dd46e375f01cbdff956a944932f0279b5633c05121716cc6839ca3fe41703c99c9bb4424f2415
    HEAD_REF master
    PATCHES
        add-options-for-exes-docs-headers.patch
        #workaround for vcpkg bug see #5697 on github for more information
        workaround_cmake_system_processor.patch
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR (VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore"))
    set(LIBJPEGTURBO_SIMD -DWITH_SIMD=OFF)
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
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_STATIC=${ENABLE_STATIC}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DENABLE_EXECUTABLES=OFF
        -DINSTALL_DOCS=OFF
        -DWITH_CRT_DLL=${WITH_CRT_DLL}
        ${FEATURE_OPTIONS}
        ${LIBJPEGTURBO_SIMD}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Rename libraries for static builds
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/jpeg.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/lib/turbojpeg.lib")
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-static.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/jpegd.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg-static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpegd.lib")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
else(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/jpeg.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/jpegd.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpeg.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/turbojpegd.lib")
    endif()
endif()

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libjpeg.pc")
if(EXISTS "${_file}" AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${_file}" "-ljpeg" "-ljpegd")
endif() 

vcpkg_fixup_pkgconfig()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libjpeg-turbo TARGET_PATH share/${PORT})

# Fix library names
file(GLOB CONFIG_FILES "${CURRENT_PACKAGES_DIR}/share/${PORT}/libjpeg-turboTargets-*.cmake")
foreach(f ${CONFIG_FILES})
    file(READ ${f} _contents)
    string(REPLACE "/debug/lib/jpeg-static.lib" "/debug/lib/jpegd.lib" _contents "${_contents}")
    string(REPLACE "/debug/lib/jpeg.lib" "/debug/lib/jpegd.lib" _contents "${_contents}")
    string(REPLACE "/lib/jpeg-static.lib" "/lib/jpeg.lib" _contents "${_contents}")
    string(REPLACE "/debug/lib/turbojpeg-static.lib" "/debug/lib/turbojpegd.lib" _contents "${_contents}")
    string(REPLACE "/debug/lib/turbojpeg.lib" "/debug/lib/turbojpegd.lib" _contents "${_contents}")
    string(REPLACE "/lib/turbojpeg-static.lib" "/lib/turbojpeg.lib" _contents "${_contents}")
    file(WRITE ${f} "${_contents}")
endforeach()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/share/man")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/jpeg")

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()
