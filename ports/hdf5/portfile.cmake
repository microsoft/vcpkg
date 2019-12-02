if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "${PORT} does not currently support UWP")
endif()

include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.5/src/CMake-hdf5-1.10.5.tar.gz"
    FILENAME "CMake-hdf5-1.10.5.tar.gz"
    SHA512 a25ea28d7a511f9184d97b5b8cd4c6d52dcdcad2bffd670e24a1c9a6f98b03108014a853553fa2b00d4be7523128b5fd6a4454545e3b17ff8c66fea16a09e962
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF hdf5
    PATCHES
        hdf5_config.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES # <- Keyword FEATURES is required because INVERTED_FEATURES are being used
     parallel     HDF5_ENABLE_PARALLEL
     tools        HDF5_BUILD_TOOLS
     cpp          HDF5_BUILD_CPP_LIB
     szip         HDF5_ENABLE_SZIP_SUPPORT
     zlib         HDF5_ENABLE_Z_LIB_SUPPORT
     fortran      HDF5_BUILD_FORTRAN
#   INVERTED_FEATURES
#     tbb   ROCKSDB_IGNORE_PACKAGE_TBB
)

file(REMOVE ${SOURCE_PATH}/config/cmake_ext_mod/FindSZIP.cmake)#Outdated; does not find debug szip

if(FEATURES MATCHES "tools" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND FEATURE_OPTIONS -DBUILD_STATIC_EXECS=ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/hdf5-1.10.5
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DHDF5_BUILD_EXAMPLES=OFF
        -DHDF5_ENABLE_SZIP_ENCODING=${HDF5_ENABLE_SZIP_SUPPORT}
        -DHDF5_INSTALL_DATA_DIR=share/hdf5/data
        -DHDF5_INSTALL_CMAKE_DIR=share
)

vcpkg_install_cmake(${COMPONENT})
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/hdf5/data/COPYING ${CURRENT_PACKAGES_DIR}/share/hdf5/copyright)
configure_file(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake ${CURRENT_PACKAGES_DIR}/share/hdf5/vcpkg-cmake-wrapper.cmake @ONLY)

file(READ "${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-config.cmake" contents)
string(REPLACE [[${HDF5_PACKAGE_NAME}_TOOLS_DIR "${PACKAGE_PREFIX_DIR}/bin"]] [[${HDF5_PACKAGE_NAME}_TOOLS_DIR "${PACKAGE_PREFIX_DIR}/tools/hdf5"]] contents ${contents})
file(WRITE "${CURRENT_PACKAGES_DIR}/share/hdf5/hdf5-config.cmake" ${contents})

if(FEATURES MATCHES "tools")
    if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/bin)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic") # waiting for single build PR to get merged
            set(DEBUG_SHARED_BINS 
                ${CURRENT_PACKAGES_DIR}/debug/bin/h5copy-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/debug/bin/h5diff-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/debug/bin/h5dump-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/debug/bin/h5ls-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/debug/bin/h5repack-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/debug/bin/h5stat-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX})
        else()
            set(DEBUG_SHARED_BINS )
        endif()
        file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/gif2h5${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h52gif${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5clear${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5copy${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5debug${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5diff${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5dump${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5format_convert${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5import${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5jam${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5ls${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5mkgrp${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5repack${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5repart${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5stat${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5unjam${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${CURRENT_PACKAGES_DIR}/debug/bin/h5watch${VCPKG_TARGET_EXECUTABLE_SUFFIX}
            ${DEBUG_SHARED_BINS})
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic") # waiting for single build PR to get merged
        set(RELEASE_SHARED_BINS
                ${CURRENT_PACKAGES_DIR}/bin/h5copy-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/bin/h5diff-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/bin/h5dump-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/bin/h5ls-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/bin/h5repack-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX}
                ${CURRENT_PACKAGES_DIR}/bin/h5stat-shared${VCPKG_TARGET_EXECUTABLE_SUFFIX})
    else()
        set(RELEASE_SHARED_BINS )
    endif()
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/gif2h5${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h52gif${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5clear${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5copy${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5debug${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5diff${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5dump${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5format_convert${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5import${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5jam${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5ls${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5mkgrp${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5repack${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5repart${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5stat${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5unjam${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5watch${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${RELEASE_SHARED_BINS}
        DESTINATION  ${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/gif2h5${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h52gif${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5clear${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5copy${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5debug${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5diff${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5dump${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5format_convert${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5import${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5jam${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5ls${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5mkgrp${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5repack${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5repart${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5stat${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5unjam${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${CURRENT_PACKAGES_DIR}/bin/h5watch${VCPKG_TARGET_EXECUTABLE_SUFFIX}
        ${RELEASE_SHARED_BINS}
        )
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
endif()

#Linux build create additional scripts here. I dont know what they are doing so I am deleting them and hope for the best
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()