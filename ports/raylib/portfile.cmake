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
    SHA512 503483a5436e189ad67533dc6c90be592283b84fbd57c86ab457dd1507b1dd11c897767ea9efa83affaf236f2711ec59e56658cf6fcad582a790a5fdc01b5ace
    HEAD_REF master
    PATCHES
        android.diff
        fix-link-path.patch
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
