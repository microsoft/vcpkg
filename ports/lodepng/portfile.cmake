if (EXISTS ${CURRENT_INSTALLED_DIR}/share/lodepng-c/copyright)
    message(FATAL_ERROR "${PORT} conflict with lodepng-c, please remove lodepng-c before install ${PORT}.")
endif()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lvandeve/lodepng
    REF 8c6a9e30576f07bf470ad6f09458a2dcd7a6a84a
    SHA512 2e0abc063be45dc04a070656260e9a2b9fa1172433cdd7d4988f0afc11751ad28aa802350598ef0e2b27c2c011fd9d9f7ab7f267b0bfcdf28f9f708b888c4411
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
configure_file("${SOURCE_PATH}/lodepng.cpp" "${SOURCE_PATH}/lodepng.c" COPYONLY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()
vcpkg_cmake_config_fixup(PACKAGE_NAME lodepng-c)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
