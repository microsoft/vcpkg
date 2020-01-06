vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tdlib/td
    REF v1.5.0
    SHA512 57f7dcaacd253d06852d95e210c6ecefa3d477f36d74f1f934a9affb621e99258bd631b7c3573df84812f9f44e6ceb090fbbc62e9f541c5d539fbab0ee51a222
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Td)

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(GPERF)
    get_filename_component(GPERF_PATH ${GPERF} DIRECTORY)
    vcpkg_add_to_path(${GPERF_PATH})
else()
    # gperf only have windows package in vcpkg now.
    if (NOT EXISTS /usr/bin/gperf)
        message(FATAL_ERROR "${PORT} requires gperf, these can be installed on Ubuntu systems via apt-get install gperf.")
    endif()
endif()
