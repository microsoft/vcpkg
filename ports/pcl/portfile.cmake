vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PointCloudLibrary/pcl
    REF d98313133b014553ab1b1b5b112f9aade837d55c # pcl-1.11.1
    SHA512 4d60f34d4fbf0a4b4caf9cc4391af471ebd260b3bbac106d45e5ff38448894ea4dc82d5320c2e395c537a4414eb13c6a6a0eb6c13e4e1cc1d831d4bf24067966
    HEAD_REF master
    PATCHES
        pcl_utils.patch
        pcl_config.patch
        use_flann_targets.patch
        boost-1.70.patch
        fix-link-libpng.patch
        remove-broken-targets.patch
        fix-check-sse.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/Modules/FindFLANN.cmake)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PCL_SHARED_LIBS)

if ("cuda" IN_LIST FEATURES AND VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
    message(FATAL_ERROR "Feature cuda only supports 64-bit compilation.")
endif()

if ("tools" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(FATAL_ERROR "Feature tools only supports dynamic build")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    openni2     WITH_OPENNI2
    qt          WITH_QT
    pcap        WITH_PCAP
    cuda        WITH_CUDA
    cuda        BUILD_CUDA
    cuda        BUILD_GPU
    tools       BUILD_tools
    opengl      WITH_OPENGL
    vtk         WITH_VTK
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        # BUILD
        -DBUILD_surface_on_nurbs=ON
        # PCL
        -DPCL_BUILD_WITH_BOOST_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_BUILD_WITH_FLANN_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_BUILD_WITH_QHULL_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_SHARED_LIBS=${PCL_SHARED_LIBS}
        # WITH
        -DWITH_LIBUSB=OFF
        -DWITH_PNG=ON
        -DWITH_QHULL=ON
        # FEATURES
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if("tools" IN_LIST FEATURES) 
    file(GLOB EXEFILES_RELEASE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(GLOB EXEFILES_DEBUG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(COPY ${EXEFILES_RELEASE} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/pcl)
    file(REMOVE ${EXEFILES_RELEASE} ${EXEFILES_DEBUG})
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/pcl)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
