if (VCPKG_TARGET_IS_WINDOWS)
    set(EXEC_ENV "Windows")
else ()
    set(EXEC_ENV "${VCPKG_CMAKE_SYSTEM_NAME}")
endif ()

if (NOT EXEC_ENV STREQUAL "Linux")
    message(FATAL_ERROR "Intel(R) Multi-Buffer Crypto for IPsec Library currently only supports Linux/Windows platforms")
    message(STATUS "Well, it is not true, but I didnt manage to get it working on Windows")
endif ()

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    message(FATAL_ERROR "Intel(R) Multi-Buffer Crypto for IPsec Library currently only supports x64 architecture")
elseif (NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif ()

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO intel/intel-ipsec-mb
        REF bde82c8737edc04d80549f0a68225ede7e5cefd #v1.1
        SHA512 f41dcde88b062e8ec2327987c6d36cd4f74a5e4fea386cc1ef8364f1dc432a2db02ca7d3312c0471b443cf93e815af6d74a4819c249afd6777aa91693b2546e5
        HEAD_REF master
)

vcpkg_find_acquire_program(NASM)

exec_program(${NASM}
             ARGS -v
             OUTPUT_VARIABLE NASM_OUTPUT
             )
string(REGEX REPLACE "NASM version ([0-9]+\\.[0-9]+\\.[0-9]+).*" "\\1"
       NASM_VERSION
       ${NASM_OUTPUT})
if (NASM_VERSION VERSION_LESS 2.13.03)
    message(FATAL_ERROR "NASM version 2.13.03 (or newer) is required to build this package")
endif ()

get_filename_component(NASM_PATH ${NASM} DIRECTORY)
set(ENV{PATH} " $ENV{PATH};${NASM_PATH} ")

vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
    OPTIONS
        -DSOURCE_PATH="${SOURCE_PATH}"
        -DEXEC_ENV=${VCPKG_CMAKE_SYSTEM_NAME}
        -DLIBRARY_LINKAGE=${VCPKG_LIBRARY_LINKAGE}
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/Release/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/Debug/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
file(INSTALL "${SOURCE_PATH}/Release/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/intel-ipsecConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
