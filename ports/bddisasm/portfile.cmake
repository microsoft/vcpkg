vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ianichitei/bddisasm
    REF 237e6ffb3e1e0b15639078efefb0f2b85ae04ee6
    SHA512 0bc15d3efd4ee740342d194da659b5238ffcf744fe95203aba692b4fd05aa730f9fec362a6772c526914f23000ceafb85f8a8bada7b7a9dd24f83308f51a1fd4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS -DBDD_INCLUDE_TOOL=OFF
)

vcpkg_install_cmake()

file(INSTALL
    ${CURRENT_PORT_DIR}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/bddisasm TARGET_PATH share/bddisasm)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
