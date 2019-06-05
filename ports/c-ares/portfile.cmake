if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "c-ares does not currently support UWP.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-ares/c-ares
    REF 9f1fdbf5dd633f81352fac0d6bc0d0c4d45be459
    SHA512 2bb3696e839e37c6f2be4b979ae6d0eab2914d6f0ca043f688e3bb3071d2348cb64424049f019c16bc05d472dd61d5071e865edd229dce023a50f556a1961766
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

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/c-ares)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/c-ares/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/c-ares/copyright)
