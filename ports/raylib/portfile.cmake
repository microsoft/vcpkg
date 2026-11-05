if(VCPKG_TARGET_IS_LINUX)
    message(
    "raylib currently requires the following libraries from the system package manager:
    libgl1-mesa-dev
    libx11-dev
    libxcursor-dev
    libxinerama-dev
    libxrandr-dev
These can be installed on Ubuntu systems via sudo apt install libgl1-mesa-dev libx11-dev libxcursor-dev libxinerama-dev libxrandr-dev"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO raysan5/raylib
    REF "${VERSION}"
    SHA512 706fdef061ed8412ec241f9e49f1badf57dd73ef9d7fadbd6612a78f1c42f03c8ab03251fb91d0523bfee757fcf8932b8bafc274c6bc42f0bfc4c17304af1ef0
    HEAD_REF master
    PATCHES
        android.diff
        # Once the next version of cgltf is released, this patch will no longer be necessary.
        fix-cgltf.patch
        fix-static-dependencies.patch
)
file(GLOB vendored_headers RELATIVE "${SOURCE_PATH}/src/external"
    "${SOURCE_PATH}/src/external/cgltf.h"
    # Do not use dirent from vcpkg: It is a different implementation which has
    # 'include <windows.h>', leading to duplicate and conflicting definitions.
    #"${SOURCE_PATH}/src/external/dirent.h"
    "${SOURCE_PATH}/src/external/nanosvg*.h"
    "${SOURCE_PATH}/src/external/qoi.h"
    "${SOURCE_PATH}/src/external/s*fl.h"  # from mmx
    "${SOURCE_PATH}/src/external/stb_*"
)
file(GLOB vendored_audio_headers RELATIVE "${SOURCE_PATH}/src/external"
    "${SOURCE_PATH}/src/external/dr_*.h"
    "${SOURCE_PATH}/src/external/miniaudio.h"
)
set(optional_vendored_headers
    "stb_image_resize2.h"  # not yet in vcpkg
)
foreach(header IN LISTS vendored_headers vendored_audio_headers)
    unset(vcpkg_file)
    find_file(vcpkg_file NAMES "${header}" PATHS "${CURRENT_INSTALLED_DIR}/include" PATH_SUFFIXES mmx nanosvg NO_DEFAULT_PATH NO_CACHE)
    if(header IN_LIST vendored_audio_headers AND NOT "audio" IN_LIST FEATURES)
        message(STATUS "Emptying '${header}' (audio disabled)")
        file(WRITE "${SOURCE_PATH}/src/external/${vcpkg_file}" "# audio disabled")
    elseif(vcpkg_file)
        message(STATUS "De-vendoring '${header}'")
        file(COPY "${vcpkg_file}" DESTINATION "${SOURCE_PATH}/src/external")
    elseif(header IN_LIST optional_vendored_headers)
        message(STATUS "Not de-vendoring '${header}' (absent in vcpkg)")
    else()
        message(FATAL_ERROR "No replacement for vendored '${header}'")
    endif()
endforeach()

set(PLATFORM_OPTIONS "")
if(VCPKG_TARGET_IS_ANDROID)
    list(APPEND PLATFORM_OPTIONS -DPLATFORM=Android -DUSE_EXTERNAL_GLFW=OFF)
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    list(APPEND PLATFORM_OPTIONS -DPLATFORM=Web -DUSE_EXTERNAL_GLFW=OFF)
else()
    list(APPEND PLATFORM_OPTIONS -DPLATFORM=Desktop -DUSE_EXTERNAL_GLFW=ON)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        audio SUPPORT_MODULE_RAUDIO
        audio USE_AUDIO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_POLICY_DEFAULT_CMP0072=NEW # Prefer GLVND
        -DCUSTOMIZE_BUILD=ON
        ${PLATFORM_OPTIONS}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/raylib.h" "defined(USE_LIBTYPE_SHARED)" "1")
endif()

set(copyright_files
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/src/external/glad.h"
    "${SOURCE_PATH}/src/external/glad_gles2.h"
    "${SOURCE_PATH}/src/external/m3d.h"
    "${SOURCE_PATH}/src/external/par_shapes.h"
    "${SOURCE_PATH}/src/external/rltexgpu.h"
    "${SOURCE_PATH}/src/external/rprand.h"
    "${SOURCE_PATH}/src/external/tinyobj_loader_c.h"
    "${SOURCE_PATH}/src/external/vox_loader.h"
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND copyright_files "${SOURCE_PATH}/src/external/dirent.h")
endif()
if("audio" IN_LIST FEATURES)
    list(APPEND copyright_files
        "${SOURCE_PATH}/src/external/jar_mod.h"
        "${SOURCE_PATH}/src/external/jar_xm.h"
        "${SOURCE_PATH}/src/external/qoa.h"
        "${SOURCE_PATH}/src/external/qoaplay.c"
    )
endif()
vcpkg_install_copyright(FILE_LIST ${copyright_files})
