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
    SHA512 5956bc1646b99baac6eb1652c4d72e96af874337158672155ba144f131de8a4fd19291a58335a92fcaaa2fc818682f93ff4230af0f815efb8b49f7d2a162e9b0
    HEAD_REF master
    PATCHES
        android.diff
)
file(GLOB vendored_stb RELATIVE "${SOURCE_PATH}/src/external" "${SOURCE_PATH}/src/external/stb_*")
foreach(header IN LISTS vendored_stb)
    file(WRITE "${SOURCE_PATH}/src/external/${header}" "#include <${header}>\n")
endforeach()
# Undo https://github.com/raysan5/raylib/pull/3403
file(WRITE "${SOURCE_PATH}/src/external/stb_image_resize2.h" "#include <stb_image_resize.h>\n#define stbir_resize_uint8_linear stbir_resize_uint8\n#define stbir_pixel_layout int\n")
# For stb
string(APPEND VCPKG_C_FLAGS " -I${CURRENT_INSTALLED_DIR}/include")
string(APPEND VCPKG_CXX_FLAGS " -I${CURRENT_INSTALLED_DIR}/include")

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
        use-audio USE_AUDIO
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_POLICY_DEFAULT_CMP0072=NEW # Prefer GLVND
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
