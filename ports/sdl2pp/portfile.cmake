vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libSDL2pp/libSDL2pp
    REF ${VERSION}
    SHA512 3682281432ce9dec0dbc7c786496564c906db9933138e1f2b881f93b5602a7170e06e67e87d35a9e5944ef80f6e13b9835e33209c52869f0ea2bc224f639a749
    HEAD_REF master
    PATCHES
        fix-dependencies.patch
        fix-usage.patch
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.txt")
