vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-ares/c-ares
    REF cares-1_17_1
    SHA512 e2a2a40118b128755571274d0cfe7cc822bc18392616378c6dd5f73f210571d7e5005a40ba0763658bdae7f2c7aadb324b2888ad8b4dcb54ad47dfaf97c2ebfc
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(CARES_STATIC 1)
    set(CARES_SHARED 0)
else()
    set(CARES_STATIC 0)
    set(CARES_SHARED 1)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCARES_STATIC=${CARES_STATIC}
        -DCARES_SHARED=${CARES_SHARED}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/c-ares)

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
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
