IF (NOT VCPKG_CMAKE_SYSTEM_NAME OR NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    MESSAGE(FATAL_ERROR "Intel spdk currently only supports Linux/BSD platforms")
ENDIF ()

VCPKG_FROM_GITHUB(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spdk/spdk
    REF "v${VERSION}"
    SHA512 c683136593661fddae6e849a1496e6664ad74e89661f6ec6ad82e653d8fc5bb64496d5d9fb263c1a05c868c1ecd1cc869d48c52895423aebab5df7a161197199
    HEAD_REF master
)

FIND_PATH(NUMA_INCLUDE_DIR NAME numa.h
    PATHS ENV NUMA_ROOT
    HINTS "$ENV{HOME}/local/include" /opt/local/include /usr/local/include /usr/include
)
IF (NOT NUMA_INCLUDE_DIR)
    MESSAGE(FATAL_ERROR "Numa library not found.\nTry: 'sudo yum install numactl numactl-devel' (or sudo apt-get install libnuma1 libnuma-dev)")
ENDIF ()

vcpkg_cmake_configure(
    SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
    OPTIONS
        "-DSOURCE_PATH=${SOURCE_PATH}"
)

vcpkg_cmake_install()

FILE(INSTALL "${SOURCE_PATH}/Release/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
FILE(INSTALL "${SOURCE_PATH}/Debug/lib/" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
FILE(INSTALL "${SOURCE_PATH}/include/spdk" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")
FILE(INSTALL "${SOURCE_PATH}/scripts/setup.sh" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/scripts")
FILE(INSTALL "${SOURCE_PATH}/scripts/common.sh" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/scripts")
FILE(INSTALL "${SOURCE_PATH}/include/spdk/pci_ids.h" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/include/spdk")
FILE(INSTALL "${CMAKE_CURRENT_LIST_DIR}/spdkConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
FILE(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
FILE(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
