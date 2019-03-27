include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(HDF5_USE_STATIC_LIBRARIES ON)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/netcdf-cxx4-4.3.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-cxx4
    REF v4.3.0
    SHA512 c0ae933446c5bb019ab90c097787cefe15a0161b6b768e0251e9e0b21c92ca8d42d98babcbe07b81b8db08cd1e9fba7befb853611a76debfdfba0aee4fb4b0bc
    HEAD_REF master
    PATCHES
        install-destination.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DNCXX_ENABLE_TESTS=OFF
        -DCMAKE_INSTALL_CMAKECONFIGDIR=share/netCDFCxx
        -DHDF5_USE_STATIC_LIBRARIES=${HDF5_USE_STATIC_LIBRARIES}
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/netcdf-cxx4)
file(
    RENAME
        ${CURRENT_PACKAGES_DIR}/share/netcdf-cxx4/COPYRIGHT
        ${CURRENT_PACKAGES_DIR}/share/netcdf-cxx4/copyright
)
