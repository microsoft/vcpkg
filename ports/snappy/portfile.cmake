include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/snappy
    REF 1.1.4
    SHA512 873f655713611f4bdfc13ab2a6d09245681f427fbd4f6a7a880a49b8c526875dbdd623e203905450268f542be24a2dc9dae50e6acc1516af1d2ffff3f96553da
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/SnappyConfig.cmake.in DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/config.h.in DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH})

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/share/snappy/SnappyTargets-debug.cmake  ${CURRENT_PACKAGES_DIR}/share/snappy/SnappyTargets-debug.cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/snappy-1.1.4/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/snappy)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/snappy/COPYING ${CURRENT_PACKAGES_DIR}/share/snappy/copyright)
