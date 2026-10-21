vcpkg_download_distfile(BOOST_1_89_0_COMPAT_PATCH
    URLS https://github.com/PointCloudLibrary/pcl/commit/99333442ac63971297b4cdd05fab9d2bd2ff57a4.patch?full_index=1
    FILENAME PointCloudLibrary-pcl-boost-1-89-0-compat.patch
    SHA512 2fefaeaeda9fe423b481cddf4de85eff58418286f24f065be8610216e87d8faeb869406b72b3a7158abd22d17e25742b54f6b9eb3c81f82a1718f938bb8e0d26
)
vcpkg_download_distfile(EIGEN3_5_0_0_COMPAT_PATCH
    URLS https://github.com/PointCloudLibrary/pcl/commit/2d6929bdcd98beaa28fa8ee3a105beb566f16347.patch?full_index=1
    FILENAME PointCloudLibrary-pcl-eigen3-5-0-0-compat.patch
    SHA512 993a1f29d8dd62cee526a92f0c2bf62dca566428523166abfb74337da137d47dcf97febb9d98b2a17ee6cea331045350bfb37b221403c08214beaebb7120bf41
)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PointCloudLibrary/pcl
    REF "pcl-${VERSION}"
    SHA512 ca9e742bc24b38f31c42c9ea08e19054e18d045f487269b64a7b831dada89936445d90a5b46870d8c24c2d25b33a59df2d904fe7e51bc0b231317cdb319951e9
    HEAD_REF master
    PATCHES
        fix-check-sse.patch
        fix-numeric-literals-flag.patch
        install-layout.patch
        install-examples.patch
        fix-clang-cl.patch
        "${BOOST_1_89_0_COMPAT_PATCH}"
        "${EIGEN3_5_0_0_COMPAT_PATCH}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PCL_SHARED_LIBS)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
	set(PCL_DONT_TRY_SSE "-DPCL_ENABLE_SSE=OFF")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        apps            BUILD_apps
        cuda            WITH_CUDA
        cuda            BUILD_CUDA
        cuda            BUILD_GPU
        examples        BUILD_examples
        examples        VCPKG_LOCK_FIND_PACKAGE_cJSON
        libusb          WITH_LIBUSB
        opengl          WITH_OPENGL
        openni2         WITH_OPENNI2
        pcap            WITH_PCAP
        qt              WITH_QT
        simulation      BUILD_simulation
        surface-on-nurbs BUILD_surface_on_nurbs
        surface-on-nurbs VCPKG_LOCK_FIND_PACKAGE_ZLIB
        tools           BUILD_tools
        visualization   WITH_VTK
        visualization   BUILD_visualization
        # These 2 apps need openni1
        #apps            BUILD_apps_in_hand_scanner
        #apps            BUILD_apps_3d_rec_framework
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # PCL
        -DPCL_ALLOW_BOTH_SHARED_AND_STATIC_DEPENDENCIES=ON
        -DPCL_BUILD_WITH_BOOST_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_BUILD_WITH_FLANN_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_BUILD_WITH_QHULL_DYNAMIC_LINKING_WIN32=${PCL_SHARED_LIBS}
        -DPCL_SHARED_LIBS=${PCL_SHARED_LIBS}
        -DPCL_ENABLE_MARCHNATIVE=OFF
        ${PCL_DONT_TRY_SSE}
        -DUSE_HOMEBREW_FALLBACK=OFF
        # WITH
        -DWITH_DAVIDSDK=OFF
        -DWITH_DOCS=OFF
        -DWITH_DSSDK=OFF
        -DWITH_ENSENSO=OFF
        -DWITH_OPENNI=OFF
        -DWITH_PNG=ON
        -DWITH_QHULL=ON
        -DWITH_RSSDK=OFF
        -DWITH_RSSDK2=OFF
        # Misc
        -DVCPKG_LOCK_FIND_PACKAGE_ClangFormat=OFF
        # FEATURES
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DBUILD_apps=OFF
        -DBUILD_examples=OFF
        -DBUILD_tools=OFF
    MAYBE_UNUSED_VARIABLES
        PCL_BUILD_WITH_FLANN_DYNAMIC_LINKING_WIN32
        PCL_BUILD_WITH_QHULL_DYNAMIC_LINKING_WIN32
)

if(NOT EXISTS "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/vtk.pc")
    file(REMOVE "${CURRENT_PACKAGE_DIR}/lib/pkgconfig/pcl_gpu_kinfu_large_scale.pc" "${CURRENT_PACKAGE_DIR}/debug/lib/pkgconfig/pcl_gpu_kinfu_large_scale.pc")
endif()

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

if (WITH_OPENNI2)
    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB PCL_PKGCONFIG_DBGS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/*.pc")
        foreach (PCL_PKGCONFIG IN LISTS PCL_PKGCONFIG_DBGS)
            file(READ "${PCL_PKGCONFIG}" PCL_PC_DBG)
            if (PCL_PC_DBG MATCHES "libopenni2")
                string(REPLACE "libopenni2" "" PCL_PC_DBG "${PCL_PC_DBG}")
                string(REPLACE "Libs: " "Libs: -lKinect10 -lOpenNI2 " PCL_PC_DBG "${PCL_PC_DBG}")
                file(WRITE "${PCL_PKGCONFIG}" "${PCL_PC_DBG}")
            endif()
        endforeach()
    endif()
    if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB PCL_PKGCONFIG_RELS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/*.pc")
        foreach (PCL_PKGCONFIG IN LISTS PCL_PKGCONFIG_RELS)
            file(READ "${PCL_PKGCONFIG}" PCL_PC_REL)
            if (PCL_PC_REL MATCHES "libopenni2")
                string(REPLACE "libopenni2" "" PCL_PC_REL "${PCL_PC_REL}")
                string(REPLACE "Libs: " "Libs: -lKinect10 -lOpenNI2 " PCL_PC_REL "${PCL_PC_REL}")
                file(WRITE "${PCL_PKGCONFIG}" "${PCL_PC_REL}")
            endif()
        endforeach()
    endif()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(BUILD_tools OR BUILD_apps OR BUILD_examples)
    file(GLOB tool_names
        LIST_DIRECTORIES false
        RELATIVE "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}"
    )
    if(VCPKG_TARGET_EXECUTABLE_SUFFIX)
        string(REPLACE "." "[.]" suffix "${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        list(TRANSFORM tool_names REPLACE "${suffix}\$" "")
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${tool_names} AUTO_CLEAN)
endif()

# pcl_apps.dll is only build for release but not used at all since BUILD_apps_3d_rec_framework is OFF.
# Because it is not copied to the tool folder and there is no debug variant, we get an post build check error.
# Since the lib is not needed. Delete it:
file(REMOVE "${CURRENT_PACKAGES_DIR}/bin/pcl_apps.dll" "${CURRENT_PACKAGES_DIR}/bin/pcl_apps.pdb"
            "${CURRENT_PACKAGES_DIR}/lib/pcl_apps.lib" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/pcl_apps.pc")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
