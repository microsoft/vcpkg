# VENDORED DEPENDENCIES! 
# TODO: Should be replaced in the future with VCPKG internal versions
# add_subdirectory(thirdparty/diy)
# add_subdirectory(thirdparty/lodepng)
# if(VTKm_ENABLE_LOGGING)
  # add_subdirectory(thirdparty/loguru)
# endif()
# add_subdirectory(thirdparty/optionparser)
# add_subdirectory(thirdparty/taotuple)
# add_subdirectory(thirdparty/lcl)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO diatomic/diy
    REF 3b31e3e9ab12b648cfc332cf8dffc9cc6c34c02b
    SHA512 55e1d0c30727f34b4c40624733f8a83e113328bf509d759595a8e1e76b2744b329b0185b978d40781b3ab6ed5aa8998bb18a5e0e006ede325a93fac7745380d5
    HEAD_REF master
    PATCHES install.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "mpi"          mpi
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS 
    ${OPTIONS}
    ${FEATURE_OPTIONS}
    -Dbuild_examples=OFF
    -Dbuild_tests=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/diy")


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
