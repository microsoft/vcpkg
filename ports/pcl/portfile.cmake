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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PointCloudLibrary/pcl
    REF pcl-1.8.1rc2
    SHA512 e5bf069f0eacfaf068b37cb0d17bed65a83dddc30c0eaa2ef70bbc534ab1cfc690e581913cd39df6246ba73b5f76fb229d90e0c5b4971744f341f7d2abb57229
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/config.patch"
            "${CMAKE_CURRENT_LIST_DIR}/config_install.patch"
            "${CMAKE_CURRENT_LIST_DIR}/find_flann.patch"
            "${CMAKE_CURRENT_LIST_DIR}/find_qhull.patch"
            "${CMAKE_CURRENT_LIST_DIR}/find_openni2.patch"
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
        -DPCL_BUILD_WITH_FLANN_DYNAMIC_LINKING_WIN32=${CRT_LINKAGE}
        -DPCL_SHARED_LIBS=${CRT_LINKAGE}
        # WITH
        -DWITH_CUDA=OFF
        -DWITH_LIBUSB=OFF
        -DWITH_OPENNI2=ON
        -DWITH_PCAP=OFF
        -DWITH_PNG=OFF
        -DWITH_QHULL=ON
        -DWITH_QT=ON
        -DWITH_VTK=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/pcl)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pcl/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/pcl/copyright)
