include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-ares/c-ares
    REF 40eb41f522eb9a86f9397352f10d1e63c89f2c54
    SHA512 901d7da97098f79d13ae8d72c85936bd15fbd6b65399c247462ad5367ac85ff32c90325998c21364f959e1bde2c8b7dbc9d9d7524ea34e6bc48dfb3854c199e1
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

file(GLOB RELEASE_EXE_FILES "${CURRENT_PACKAGES_DIR}/bin/*.exe")
file(REMOVE ${RELEASE_EXE_FILES})
file(GLOB DEBUG_EXE_FILES "${CURRENT_PACKAGES_DIR}/debug/bin/*.exe")
file(REMOVE ${DEBUG_EXE_FILES})

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/c-ares)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/c-ares/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/c-ares/copyright)
