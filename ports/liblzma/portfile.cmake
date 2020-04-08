vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xz-mirror/xz
    REF v5.2.5
    SHA512 686f01cfe33e2194766a856c48668c661b25eee194a443524f87ce3f866e0eb54914075b4e00185921516c5211db8cd5d2658f4b91f4a3580508656f776f468e
    HEAD_REF master
    PATCHES
        enable-uwp-builds.patch
        configure.cl.patch # Because CL is not C99 compatible
)
if(VCPKG_TARGET_IS_WINDOWS)
    if(EXISTS "${SOURCE_PATH}/m4/libtool" AND VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
        set(_file "${SOURCE_PATH}/m4/libtool")
        file(READ "${_file}" _contents)
        string(REPLACE ".dll.lib" ".lib" _contents "${_contents}")
        file(WRITE "${_file}" "${_contents}")
    endif()
endif()
vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
    --disable-xz
    --disable-xzdec
    --disable-lzmadec
    --disable-lzmainfo
    --disable-lzma-links
    --disable-scripts
    --disable-doc
    --disable-nls
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

# vcpkg_configure_cmake(
    # SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA
# )
# vcpkg_install_cmake()
#vcpkg_fixup_cmake_targets()

vcpkg_copy_pdbs()

#Move this out of the portfile
file(APPEND ${CURRENT_PACKAGES_DIR}/share/liblzma/LibLZMAConfig.cmake
"
include(\${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
find_path(LibLZMA_INCLUDE_DIR
    NAMES lzma.h
    PATH_SUFFIXES lzma
)
if(NOT LibLZMA_LIBRARY)
    find_library(LibLZMA_LIBRARY_RELEASE NAMES lzma LZMA LibLZMA PATHS \${_IMPORT_PREFIX}/lib/)
    find_library(LibLZMA_LIBRARY_DEBUG NAMES lzmad LZMAd LibLZMAd lzma LZMA LibLZMA PATHS \${_IMPORT_PREFIX}/debug/lib/)
    select_library_configurations(LibLZMA)
endif()
set(LibLZMA_INCLUDE_DIRS \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LibLZMA_LIBRARIES \${LibLZMA_LIBRARY} CACHE STRING \"\")
set(LZMA_INCLUDE_DIR \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LZMA_LIBRARY \${LibLZMA_LIBRARY} CACHE STRING \"\")
set(LZMA_INCLUDE_DIRS \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LZMA_LIBRARIES \${LibLZMA_LIBRARY} CACHE STRING \"\")
set(LIBLZMA_INCLUDE_DIRS \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LIBLZMA_LIBRARIES \${LibLZMA_LIBRARY} CACHE STRING \"\")
set(LIBLZMA_INCLUDE_DIR \${LibLZMA_INCLUDE_DIR} CACHE PATH \"\")
set(LIBLZMA_LIBRARY \${LibLZMA_LIBRARY} CACHE STRING \"\")

if(LIBLZMA_INCLUDE_DIR AND EXISTS \"\${LIBLZMA_INCLUDE_DIR}/lzma/version.h\")
    file(STRINGS \"\${LIBLZMA_INCLUDE_DIR}/lzma/version.h\" LIBLZMA_HEADER_CONTENTS REGEX \"#define LZMA_VERSION_[A-Z]+ [0-9]+\")

    string(REGEX REPLACE \".*#define LZMA_VERSION_MAJOR ([0-9]+).*\" \"\\\\1\" LIBLZMA_VERSION_MAJOR \"\${LIBLZMA_HEADER_CONTENTS}\")
    string(REGEX REPLACE \".*#define LZMA_VERSION_MINOR ([0-9]+).*\" \"\\\\1\" LIBLZMA_VERSION_MINOR \"\${LIBLZMA_HEADER_CONTENTS}\")
    string(REGEX REPLACE \".*#define LZMA_VERSION_PATCH ([0-9]+).*\" \"\\\\1\" LIBLZMA_VERSION_PATCH \"\${LIBLZMA_HEADER_CONTENTS}\")

    set(LIBLZMA_VERSION_STRING \"\${LIBLZMA_VERSION_MAJOR}.\${LIBLZMA_VERSION_MINOR}.\${LIBLZMA_VERSION_PATCH}\")
    unset(LIBLZMA_HEADER_CONTENTS)
endif()

## We're using new code known now as XZ, even library still been called LZMA
## it can be found in http://tukaani.org/xz/
## Avoid using old codebase
#if (LIBLZMA_LIBRARY)
#   include(\${CMAKE_ROOT}/Modules/CheckLibraryExists.cmake)
#   CHECK_LIBRARY_EXISTS(\${LibLZMA_LIBRARY_RELEASE} lzma_auto_decoder \"\" LIBLZMA_HAS_AUTO_DECODER)
#   CHECK_LIBRARY_EXISTS(\${LibLZMA_LIBRARY_RELEASE} lzma_easy_encoder \"\" LIBLZMA_HAS_EASY_ENCODER)
#   CHECK_LIBRARY_EXISTS(\${LibLZMA_LIBRARY_RELEASE} lzma_lzma_preset \"\" LIBLZMA_HAS_LZMA_PRESET)
#endif ()

set(LibLZMA_FOUND TRUE CACHE BOOL \"\")
set(LZMA_FOUND TRUE CACHE BOOL \"\")
set(LIBLZMA_FOUND TRUE CACHE BOOL \"\")
")

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(APPEND ${CURRENT_PACKAGES_DIR}/share/liblzma/LibLZMAConfig.cmake "add_definitions(-DLZMA_API_STATIC)") # should also be added to the lzma.h for correct VS integration 
  #define LZMA_H
  set(_file "${CURRENT_PACKAGES_DIR}/include/lzma.h")
  file(READ "${_file}" _contents)
  string(REPLACE "#define LZMA_H\n" "#define LZMA_H\n#define LZMA_API_STATIC" _contents "${_contents}")
  file(WRITE "${_file}" "${_contents}")
endif()

if (VCPKG_BUILD_TYPE STREQUAL debug)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/include)
else()
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/locale/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/liblzma)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools/)