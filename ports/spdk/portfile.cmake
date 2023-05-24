IF (NOT VCPKG_CMAKE_SYSTEM_NAME OR NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    MESSAGE(FATAL_ERROR "Intel spdk currently only supports Linux/BSD platforms")
ENDIF ()

VCPKG_FROM_GITHUB(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spdk/spdk
    REF v19.01.1
    SHA512 cb2c085e1a5d370df60599aaeb6302f8252626342a9e0644018df8c769f406304591680f905572848390c3139e640496f96e3b4fc67469c56eb9a5329aee4b24
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
