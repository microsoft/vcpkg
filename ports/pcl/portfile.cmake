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
        fix-pkgconfig.patch # Remove this patch in the next update
        fix-namespace-cub.patch # Remove this patch in the next update
        fix-error-C3052.patch # Remove this patch in the next update
        fix-find-libusb.patch
        install-examples.patch
        no-absolute.patch
        Workaround-ICE-in-release.patch
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
        openni2         WITH_OPENNI2
        qt              WITH_QT
        pcap            WITH_PCAP
        cuda            WITH_CUDA
        cuda            BUILD_CUDA
        cuda            BUILD_GPU
        tools           BUILD_tools
        opengl          WITH_OPENGL
        libusb          WITH_LIBUSB
        visualization   WITH_VTK
        visualization   BUILD_visualization
        examples        BUILD_examples
        apps            BUILD_apps
        # These 2 apps need openni1
        #apps            BUILD_apps_in_hand_scanner
        #apps            BUILD_apps_3d_rec_framework
        simulation      BUILD_simulation
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
        -DWITH_OPENNI=OFF
        -DWITH_ENSENSO=OFF
        -DWITH_DAVIDSDK=OFF
        -DWITH_DSSDK=OFF
        -DWITH_RSSDK=OFF
        -DWITH_RSSDK2=OFF
        -DWITH_OPENMP=OFF
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
    file(GLOB EXEFILES_RELEASE "${CURRENT_PACKAGES_DIR}/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    file(GLOB EXEFILES_DEBUG "${CURRENT_PACKAGES_DIR}/debug/bin/*${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    file(COPY ${EXEFILES_RELEASE} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/pcl")
    file(REMOVE ${EXEFILES_RELEASE} ${EXEFILES_DEBUG})
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/pcl")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
