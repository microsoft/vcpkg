vcpkg_fail_port_install(ON_TARGET "linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mixxxdj/hss1394
    REF af76a3e19f9cdceca502bf20bfd216e040e2eddb
    SHA512 bb32a39738ddfc3791562391ef639c61c72fb17e1fa2b037a8179e5b6ca1d5bbd6cedb5c5e650282816e6cee0944dca26d5dcdf39d0244056d3db1fd4938bd30
    HEAD_REF main
)

if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(HSS1394_OPTIONS -DBUILD_SHARED_LIBS=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${HSS1394_OPTIONS}
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/hss1394 RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
