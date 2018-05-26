# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SDL2_IMAGE_VERSION "2.0.2")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2_image-${SDL2_IMAGE_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-${SDL2_IMAGE_VERSION}.zip"
    FILENAME "SDL2_image-${SDL2_IMAGE_VERSION}.zip"
    SHA512 bf143bdbd3cb7cfad61b8dcc35950584304deac802bad6c0c8144e914401a5ddef01f674d2dc1214371d0f371f76e87a45873e2655947e8e1da83fb44d8285f4
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/FindWEBP.cmake DESTINATION ${SOURCE_PATH}/cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    # OPTIONS
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2-image)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/sdl2-image/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/sdl2-image/copyright)

vcpkg_copy_pdbs()