include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-ares/c-ares
    REF cares-1_13_0
    SHA512 0ee8a45772c64701d0e860cd84925cef8938a319b3004e02e86af900cbd9e07609940bc474a46bf4252b9b7e3815e1951de8f0eb16718074ec1d39c2105a2abe
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(CARES_STATIC ON)
    set(CARES_SHARED OFF)
else()
    set(CARES_STATIC OFF)
    set(CARES_SHARED ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCARES_STATIC=${CARES_STATIC}
        -DCARES_SHARED=${CARES_SHARED}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/c-ares")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(GLOB EXE_FILES
        "${CURRENT_PACKAGES_DIR}/bin/*.exe"
        "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe"
    )
    if (EXE_FILES)
        file(REMOVE ${EXE_FILES})
    endif()
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/c-ares)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/c-ares/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/c-ares/copyright)
