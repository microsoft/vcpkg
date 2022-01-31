vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artyom-beilis/cppcms
    REF b72b19915794d1af63c9a9e9bea58e20a4ad93d4
    SHA512 e99d34d14fbde22be725ac2c0bec069fb584e45c66767af75efaf454ca61a7a5e57434bf86109f910884c72202b8cf98fe16505e7d3d30d9218abd4d8b27d5df
)

vcpkg_find_acquire_program(PYTHON2)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPYTHON=${PYTHON2} # Switch to python3 on the next update
        -DUSE_WINDOWS6_API=ON
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB EXE_DEBUG_FILES ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${EXE_DEBUG_FILES})
file(GLOB EXE_FILES ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(REMOVE ${EXE_FILES})

file(INSTALL ${SOURCE_PATH}/MIT.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
