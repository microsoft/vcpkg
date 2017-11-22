include(vcpkg_common_functions)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(TARGET_ARCHITECTURE 32)
    set(FILE_HASH 99e9f05629213f99ba0b2ae088e2356842841604346a2871b05bf933a2a4712528ad1a38861f54478c16b99686ce615f97254b00c09b92b540c7afa1b0b0bb8f)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(TARGET_ARCHITECTURE 64)
    set(FILE_HASH aa699684321e779898ff09dc02163347dce355fa5d47fe673191e2323e28cc5b6554dfd51f39cc9c231ba8b07927f36e99b8489e4f7eb871ebaf6e377fc33cfc)
else()
    message(FATAL_ERROR "Error: halide does not support the ${VCPKG_TARGET_ARCHITECTURE} architecture.")
endif()

set(COMMIT_HASH 3af238615667312dcb46607752e3ae5d0ec5d713)
set(RELEASE_DATE 2017_10_30)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/halide-win-${TARGET_ARCHITECTURE}-distro-trunk-${COMMIT_HASH})
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/halide/Halide/releases/download/release_${RELEASE_DATE}/halide-win-${TARGET_ARCHITECTURE}-distro-trunk-${COMMIT_HASH}.zip"
    FILENAME "halide-win-${TARGET_ARCHITECTURE}-distro-trunk-${COMMIT_HASH}.zip"
    SHA512 ${FILE_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE} ${SOURCE_PATH})

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/halide/Halide/release_${RELEASE_DATE}/LICENSE.txt"
    FILENAME "halide-release_${RELEASE_DATE}-LICENSE.txt"
    SHA512 bf11aa011ce872bcd51fe8d350f7238ad1eceb61eb7af788a2d78a6cfdfa9095abeeb2d230ead5c5299d245d6507a7b4374e3294703c126dcdae531db5a5ba7a
)

set(SOURCE_PATH ${SOURCE_PATH}/halide)

file(
    INSTALL
        "${SOURCE_PATH}/include/Halide.h"
        "${SOURCE_PATH}/include/HalideBuffer.h"
        "${SOURCE_PATH}/include/HalideRuntime.h"
        "${SOURCE_PATH}/include/HalideRuntimeCuda.h"
        "${SOURCE_PATH}/include/HalideRuntimeHexagonHost.h"
        "${SOURCE_PATH}/include/HalideRuntimeMetal.h"
        "${SOURCE_PATH}/include/HalideRuntimeOpenCL.h"
        "${SOURCE_PATH}/include/HalideRuntimeOpenGL.h"
        "${SOURCE_PATH}/include/HalideRuntimeOpenGLCompute.h"
        "${SOURCE_PATH}/include/HalideRuntimeQurt.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

file(
    INSTALL
        "${SOURCE_PATH}/tools/halide_image_io.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

file(
    INSTALL
        "${SOURCE_PATH}/Release/Halide.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)

file(
    INSTALL
        "${SOURCE_PATH}/Debug/Halide.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(
    INSTALL
        "${SOURCE_PATH}/Release/Halide.dll"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/bin
)

file(
    INSTALL
        "${SOURCE_PATH}/Debug/Halide.dll"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/bin
)

file(INSTALL "${LICENSE}" DESTINATION ${CURRENT_PACKAGES_DIR}/share/halide RENAME copyright)
