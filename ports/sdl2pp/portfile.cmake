vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libSDL2pp/libSDL2pp
    REF a02d5a81c3d4122cb578fcd1e5cd4e836878f63b # 0.16.1
    SHA512 cf08abe69b3d313d1c3f63cb138f05105453ea0d04e26daa6d85da41cb742912a37766cce1f8af1277e92a227ea75f481f07bff76f0b501fadec392b8b62336a
    HEAD_REF master
    PATCHES fix-dependencies.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sdl2-image SDL2PP_WITH_IMAGE
        sdl2-mixer SDL2PP_WITH_MIXER
        sdl2-ttf   SDL2PP_WITH_TTF
)

file(REMOVE "${SOURCE_PATH}/cmake/FindSDL2.cmake"
            "${SOURCE_PATH}/cmake/FindSDL2_image.cmake"
            "${SOURCE_PATH}/cmake/FindSDL2_mixer.cmake"
            "${SOURCE_PATH}/cmake/FindSDL2_ttf.cmake"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL2PP_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKEMODDIR=share/${PORT}
        -DSDL2PP_WITH_EXAMPLES=OFF
        -DSDL2PP_WITH_TESTS=OFF
        -DSDL2PP_STATIC=${SDL2PP_STATIC}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/FindSDL2PP.cmake" "HINTS \"${CURRENT_PACKAGES_DIR}/include\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/FindSDL2PP.cmake" "HINTS \"${CURRENT_PACKAGES_DIR}/lib\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}/FindSDL2PP.cmake" "#  SDL2PP_LIBRARIES" 
[[#  SDL2PP_LIBRARIES
include(CMakeFindDependencyMacro)
find_dependency(SDL2 CONFIG)
find_dependency(SDL2_image CONFIG)
find_dependency(SDL2_ttf CONFIG)
find_dependency(SDL2_mixer CONFIG)]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.txt")
