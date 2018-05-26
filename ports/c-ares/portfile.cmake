if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "c-ares does not currently support UWP.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-ares/c-ares
    REF cares-1_14_0
    SHA512 3ae7938648aec2fae651667bef02139f7eef2e7cd425cc310b7e3d56f409646f6170d37a3c9269aa654bfb1ced0a52b89fe49be9023edf8ff57efd0efaf59052
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
