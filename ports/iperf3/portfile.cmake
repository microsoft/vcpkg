vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO esnet/iperf
    REF "${VERSION}"
    SHA512 468bbb040e8dc43c664854c823b7d79d9836da774a53f080fdd2258c836874247ca1f876dff490021e0ad3d38a00f972ffeea10eb149fb1fc75bf18e8fd9e974
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_install_make()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

set(IPERF_INCLUDE_DIR ${CURRENT_PACKAGES_DIR}/include)
set(IPERF_LIB_DIR ${CURRENT_PACKAGES_DIR}/lib)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/iperf/iperfConfig.cmake
"set(IPERF_INCLUDE_DIR \"${IPERF_INCLUDE_DIR}\")
set(IPERF_LIB_DIR \"${IPERF_LIB_DIR}\")
include_directories(\${IPERF_INCLUDE_DIR})
link_directories(\${IPERF_LIB_DIR})"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")