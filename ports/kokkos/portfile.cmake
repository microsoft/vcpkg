vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  kokkos/kokkos
    REF 61d7db55fceac3318c987a291f77b844fd94c165
    SHA512 eb3b93732653d502598632a1bdf8c678164b170d75891d6c5a98f50d98953abe4c76944189ec57215db1426096d55ca78fd06cd32b313282f892f4158e3ebf69
    HEAD_REF master
)


if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKokkos_ENABLE_TESTS=OFF
        #-DKokkos_ENABLE_THREADS=ON # uses gcc attribute
        #-DKokkos_ENABLE_HWLOC=ON # also some compile problem.
        # Kokkos_ENABLE_HPX
)

#TODO: CMake options:
# https://kokkos.github.io/kokkos-core-wiki/keywords.html
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Kokkos PACKAGE_NAME Kokkos)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/Copyright.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME "copyright")

