include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(TARGET_ARCHITECTURE 32)
    set(FILE_HASH 4de27307f3355c318f21497a5b8641d215dbfbe2beb55472b9108e96aa9190300a5a8559f0c5e2788b56103f8284807e293ca362dee22adba62ae0f3b021766f)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(TARGET_ARCHITECTURE 64)
    set(FILE_HASH a751c263335cbef725554b9a9b7b71811c0872d97109af5339124cb1db291a6f7e0bfb712f19982829477bf4fa2ad3c70ca5353b73697d1984504257b0894798)
else()
    message(FATAL_ERROR "Error: halide does not support the ${VCPKG_TARGET_ARCHITECTURE} architecture.")
endif()

set(COMMIT_HASH 46d8e9e0cdae456489f1eddfd6d829956fc3c843)
set(RELEASE_DATE 2018_02_15)

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
