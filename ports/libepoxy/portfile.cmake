if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anholt/libepoxy
    REF 1.4.2
    SHA512 b94e1fe749c63a82f38369ff62b7d0d8cf1c55884159f030dc2919c17daf5811dd71cfd6a663edb38df66ff4ca53120a6a53501568cc8a582f08d4ae82fe9d89
    HEAD_REF master)

# ensure python is on path - not for meson but some source generation scripts
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_PATH}")

vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH})
vcpkg_install_meson()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libepoxy)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libepoxy/COPYING ${CURRENT_PACKAGES_DIR}/share/libepoxy/copyright)
