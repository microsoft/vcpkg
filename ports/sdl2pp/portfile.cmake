vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libSDL2pp/libSDL2pp
    REF "${VERSION}"
    SHA512 655412c93df5e6207064a07328785add4e7700a656295f03f0f2df4898ce62bd259340de28bf2a79db4fce765d2000ce6a43312dbe524f2b2b909a2dbf324859
    HEAD_REF master
    PATCHES fix-dependencies.patch
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
file(INSTALL "${SOURCE_PATH}/COPYING.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)