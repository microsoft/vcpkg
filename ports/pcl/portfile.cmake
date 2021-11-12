vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PointCloudLibrary/pcl
    REF f36a69a5e89953708990c4669317f989d532cf08 # pcl-1.12.0
    SHA512 dbbd0adbb08949ddef2789e0021b6ca9727be33c7193d0bb135c61def09a42ed6a71333f06b6fad407010ecb4b73c19f087f7520386b92a008e90c254eafe422
    HEAD_REF master
    PATCHES
        add-gcc-version-check.patch
        fix-check-sse.patch
        fix-find-qhull.patch
        fix-numeric-literals-flag.patch
        pcl_config.patch
        pcl_utils.patch
        remove-broken-targets.patch
        fix-cmake_find_library_suffixes.patch
        fix-pkgconfig.patch
        fix-find-libusb.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/Modules/FindQhull.cmake"
            "${SOURCE_PATH}/cmake/Modules/Findlibusb.cmake"
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PCL_SHARED_LIBS)

if ("cuda" IN_LIST FEATURES AND VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "Feature cuda only supports 64-bit compilation.")
endif()

if ("tools" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Feature tools only supports dynamic build")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openni2 WITH_OPENNI2
        qt      WITH_QT
        pcap    WITH_PCAP
        cuda    WITH_CUDA
        cuda    BUILD_CUDA
        cuda    BUILD_GPU
        tools   BUILD_tools
        opengl  WITH_OPENGL
        vtk     WITH_VTK
        libusb  WITH_LIBUSB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # BUILD
        -DBUILD_surface_on_nurbs=ON
        # PCL
        -DPCL_BUILD_WITH_BOOST_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_BUILD_WITH_FLANN_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_BUILD_WITH_QHULL_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_SHARED_LIBS=${PCL_SHARED_LIBS}
        # WITH
        -DWITH_PNG=ON
        -DWITH_QHULL=ON
        # FEATURES
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        PCL_BUILD_WITH_FLANN_DYNAMIC_LINKING_WIN32
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

if (WITH_OPENNI2)
    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(READ "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/pcl_io-1.12.pc" PCL_IO_PC_DBG)
        string(REPLACE "libopenni2" "" PCL_IO_PC_DBG "${PCL_IO_PC_DBG}")
        string(REPLACE "Libs: " "Libs: -lKinect10 -lOpenNI2 " PCL_IO_PC_DBG "${PCL_IO_PC_DBG}")
        file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/pcl_io-1.12.pc" "${PCL_IO_PC_DBG}")
    endif()
    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(READ "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/pcl_io-1.12.pc" PCL_IO_PC_REL)
        string(REPLACE "libopenni2" "" PCL_IO_PC_REL "${PCL_IO_PC_REL}")
        string(REPLACE "Libs: " "Libs: -lKinect10 -lOpenNI2 " PCL_IO_PC_REL "${PCL_IO_PC_REL}")
        file(WRITE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/pcl_io-1.12.pc" "${PCL_IO_PC_REL}")
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if("tools" IN_LIST FEATURES) 
    file(GLOB EXEFILES_RELEASE "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    file(GLOB EXEFILES_DEBUG "${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    file(COPY ${EXEFILES_RELEASE} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/pcl")
    file(REMOVE ${EXEFILES_RELEASE} ${EXEFILES_DEBUG})
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/pcl")
endif()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
