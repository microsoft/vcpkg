# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pcl-pcl-1.8.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.0.zip"
    FILENAME "pcl-1.8.0.zip"
    SHA512 932f7e2101707003712e53d9310c6ba8304b8d325997a71a45d052c329cd9465f1d390c6c53a11bcb01d65e808c7701452ea06f116a0bd779d8098fdf3246ca8
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/config.patch"
            "${CMAKE_CURRENT_LIST_DIR}/config_install.patch"
            "${CMAKE_CURRENT_LIST_DIR}/find_flann.patch"
            "${CMAKE_CURRENT_LIST_DIR}/find_qhull.patch"
            "${CMAKE_CURRENT_LIST_DIR}/find_openni2.patch"
            # Fix for PCL 1.8.0
            "${CMAKE_CURRENT_LIST_DIR}/1635.patch"
            "${CMAKE_CURRENT_LIST_DIR}/1788.patch"
            "${CMAKE_CURRENT_LIST_DIR}/1823.patch"
            "${CMAKE_CURRENT_LIST_DIR}/1830.patch"
            "${CMAKE_CURRENT_LIST_DIR}/1855.patch"
            "${CMAKE_CURRENT_LIST_DIR}/1856.patch"
)

if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(CRT_LINKAGE ON)
elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CRT_LINKAGE OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    #PREFER_NINJA
    OPTIONS
        # BUILD
        -DBUILD_surface_on_nurbs=ON
        -DBUILD_tools=OFF
        # PCL
        -DPCL_BUILD_WITH_BOOST_DYNAMIC_LINKING_WIN32=${CRT_LINKAGE}
        -DPCL_SHARED_LIBS=${CRT_LINKAGE}
        # WITH
        -DWITH_CUDA=OFF
        -DWITH_LIBUSB=OFF
        -DWITH_OPENNI2=ON
        -DWITH_PCAP=OFF
        -DWITH_PNG=OFF
        -DWITH_QHULL=ON
        -DWITH_QT=OFF
        -DWITH_VTK=ON
)

vcpkg_install_cmake()

file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/pcl_2d_release.dll ${CURRENT_PACKAGES_DIR}/debug/bin/pcl_2d_debug.dll)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pcl/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/pcl/copyright)
