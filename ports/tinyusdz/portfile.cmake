if(VCPKG_TARGET_IS_EMSCRIPTEN)
    message(FATAL_ERROR "tinyusdz is not supported on Emscripten")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lighttransport/tinyusdz
    REF v0.9.1
    SHA512 26093ec107e1440be1e896ba3da8e0d9196c968455332d1d6961cbe458a26cce86d18f4b22279b5775a5e029e491306346aa4796517fac7e30a6ba1ff84d2e71
    HEAD_REF dev
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTINYUSDZ_BUILD_TESTS=OFF
        -DTINYUSDZ_BUILD_EXAMPLES=OFF
        -DTINYUSDZ_BUILD_BENCHMARKS=OFF
        -DTINYUSDZ_WITH_OPENSUBDIV=OFF
        -DTINYUSDZ_WITH_EXR=OFF
        -DTINYUSDZ_WITH_AUDIO=OFF
        -DTINYUSDZ_WITH_USDMTLX=OFF
        -DTINYUSDZ_WITH_PXR_COMPAT_API=OFF
        -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_build()

file(COPY "${SOURCE_PATH}/src/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/tinyusdz"
    FILES_MATCHING
    PATTERN "*.hh"
    PATTERN "*.h"
    PATTERN "*.hpp"
    PATTERN "*.inc"
)

# Release lib
if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB TINYUSDZ_LIB_REL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.lib"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/*.lib"
    )
    set(TINYUSDZ_LIB_FILENAME "tinyusdz_static.lib")
else()
    file(GLOB TINYUSDZ_LIB_REL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/lib/*.a"
    )
    set(TINYUSDZ_LIB_FILENAME "libtinyusdz_static.a")
endif()
file(COPY ${TINYUSDZ_LIB_REL} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

# Debug lib
if(VCPKG_TARGET_IS_WINDOWS)
    file(GLOB TINYUSDZ_LIB_DBG
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.lib"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/*.lib"
    )
else()
    file(GLOB TINYUSDZ_LIB_DBG
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/*.a"
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/lib/*.a"
    )
endif()
if(TINYUSDZ_LIB_DBG)
    file(COPY ${TINYUSDZ_LIB_DBG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Expose include dir as a variable — same pattern as stb/tinygltf
file(WRITE "${CURRENT_PACKAGES_DIR}/share/tinyusdz/tinyusdzConfig.cmake" "
get_filename_component(_TINYUSDZ_PREFIX \"\${CMAKE_CURRENT_LIST_DIR}/../..\" ABSOLUTE)
set(TINYUSDZ_INCLUDE_DIR \"\${_TINYUSDZ_PREFIX}/include/tinyusdz\")

add_library(tinyusdz::tinyusdz_static STATIC IMPORTED)
set_target_properties(tinyusdz::tinyusdz_static PROPERTIES
    IMPORTED_LOCATION \"\${_TINYUSDZ_PREFIX}/lib/${TINYUSDZ_LIB_FILENAME}\"
    IMPORTED_LOCATION_DEBUG \"\${_TINYUSDZ_PREFIX}/debug/lib/${TINYUSDZ_LIB_FILENAME}\"
    INTERFACE_INCLUDE_DIRECTORIES \"\${_TINYUSDZ_PREFIX}/include/tinyusdz\"
)
")