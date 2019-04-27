include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stevenlovegrove/Pangolin
    REF v0.5
    SHA512 7ebeec108f33f1aa8b1ad08e3ca128a837b22d33e3fc580021f981784043b023a1bf563bbfa8b51d46863db770b336d24fc84ee3d836b85e0da1848281b2a5b2
    HEAD_REF master
	PATCHES 
        deprecated_constants.patch # Change from upstream pangolin to address build failures from latest ffmpeg library
        fix-includepath-error.patch # include path has one more ../
)

file(REMOVE ${SOURCE_PATH}/CMakeModules/FindGLEW.cmake)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" MSVC_USE_STATIC_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
        -DBUILD_EXTERN_GLEW=OFF
        -DBUILD_EXTERN_LIBPNG=OFF
        -DBUILD_EXTERN_LIBJPEG=OFF
        -DMSVC_USE_STATIC_CRT=${MSVC_USE_STATIC_CRT}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/Pangolin")

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(GLOB EXE ${CURRENT_PACKAGES_DIR}/lib/*.dll)
    file(COPY ${EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(REMOVE ${EXE})

    file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/lib/*.dll)
    file(COPY ${DEBUG_EXE} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE ${DEBUG_EXE})

    file(READ ${CURRENT_PACKAGES_DIR}/share/pangolin/PangolinTargets-debug.cmake PANGOLIN_TARGETS)
    string(REPLACE "lib/pangolin.dll" "bin/pangolin.dll" PANGOLIN_TARGETS "${PANGOLIN_TARGETS}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/pangolin/PangolinTargets-debug.cmake "${PANGOLIN_TARGETS}")

    file(READ ${CURRENT_PACKAGES_DIR}/share/pangolin/PangolinTargets-release.cmake PANGOLIN_TARGETS)
    string(REPLACE "lib/pangolin.dll" "bin/pangolin.dll" PANGOLIN_TARGETS "${PANGOLIN_TARGETS}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/pangolin/PangolinTargets-release.cmake "${PANGOLIN_TARGETS}")
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy missing header file
file(COPY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/src/include/pangolin/pangolin_export.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/pangolin)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENCE DESTINATION ${CURRENT_PACKAGES_DIR}/share/Pangolin/)
file(COPY ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/Pangolin/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/Pangolin/LICENCE ${CURRENT_PACKAGES_DIR}/share/Pangolin/copyright)
