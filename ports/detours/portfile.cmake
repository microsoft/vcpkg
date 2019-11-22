include(vcpkg_common_functions)
find_program(NMAKE nmake)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/Detours
    REF v4.0.1
    SHA512 0a9c21b8222329add2de190d2e94d99195dfa55de5a914b75d380ffe0fb787b12e016d0723ca821001af0168fd1643ffd2455298bf3de5fdc155b3393a3ccc87
    HEAD_REF master
    PATCHES 
        find-jmp-bounds-arm64.patch
)

set(ENV{DETOURS_TARGET_PROCESSOR} "${VCPKG_TARGET_ARCHITECTURE}")

vcpkg_execute_required_process(
    COMMAND ${NMAKE}
    WORKING_DIRECTORY ${SOURCE_PATH}/src
    LOGNAME build-${TARGET_TRIPLET}
)

# Detours does not differentiate between Release and Debug builds, use the same binaries for both.
file(INSTALL ${SOURCE_PATH}/lib.${VCPKG_TARGET_ARCHITECTURE}/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/lib.${VCPKG_TARGET_ARCHITECTURE}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
