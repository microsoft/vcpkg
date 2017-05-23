include(vcpkg_common_functions)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-win32-build-1.11.7.zip"
        FILENAME "hwloc-win32-build-1.11.7.zip"
        SHA512 c474f2400b207bbad3da94d201d03eb711df6a87aacb8429c489591ed47393eb499d99da5737a22d0745194296db11bf9e8ebbabd4bf2ecfd2d2878a773195d8
    )
    set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hwloc-win32-build-1.11.7)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    vcpkg_download_distfile(ARCHIVE
        URLS "https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-win64-build-1.11.7.zip"
        FILENAME "hwloc-win64-build-1.11.7.zip"
        SHA512 1373107f75f372fa519a7c3f686fbb6ff89e14c3750e1d64755c768daf77a01a1d962b5e7ecadc65f9917b56f45193e637db3958a0bede08cfe2dd983a335d9b
    )
    set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/hwloc-win64-build-1.11.7)
else()
    message(FATAL_ERROR "HWLOC is not available for download for the platform: ${VCPKG_TARGET_ARCHITECTURE}")
endif()
vcpkg_extract_source_archive(${ARCHIVE})

message(STATUS "Installing")

# copy include files
file(COPY ${SOURCE_PATH}/include/hwloc.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${SOURCE_PATH}/include/hwloc DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# copy binaries
file(COPY ${SOURCE_PATH}/bin/libhwloc-5.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/lib/libhwloc.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

file(COPY ${SOURCE_PATH}/bin/libhwloc-5.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(COPY ${SOURCE_PATH}/lib/libhwloc.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

message(STATUS "Installing done")

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/hwloc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hwloc/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/hwloc/copyright)

set(VCPKG_POLICY_ALLOW_OBSOLETE_MSVCRT enabled)
