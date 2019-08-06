include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(HDF5_USE_STATIC_LIBRARIES ON)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/netcdf-cxx4-4.3.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Unidata/netcdf-cxx4
    REF v4.3.0
    SHA512 8e77333c979513721209e6b3fde31c298e18a45d7ea08123056e8120469eb8c4024d71289fab2b9182ee19ee7b6ad22bd133525bef048a497ede4aa2e9017465
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
