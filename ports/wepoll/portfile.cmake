include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "${PORT} only supports Windows.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO piscisaureus/wepoll
    REF d5f8f5f1b1be1a4ba8adb51eb4ee4de7a305a9c8
    SHA512 659b7feff7cc649464ed2738df09d1d5057fb8da3a3439e492af4d91a7cb938ce783d5bd71a32de035aaf1329ce21ef45f06559fdc65c3111fbb61f748c1d0e9
    HEAD_REF master
    PATCHES
        disable-wx-tests.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
)

vcpkg_build_cmake()

file(COPY ${SOURCE_PATH}/include/wepoll.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

set(DEBUG_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
set(RELEASE_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")

file(COPY ${DEBUG_DIR}/wepoll.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${RELEASE_DIR}/wepoll.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(COPY ${DEBUG_DIR}/wepoll.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${RELEASE_DIR}/wepoll.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)

    vcpkg_copy_pdbs()
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
