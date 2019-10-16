# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CURRENT_INSTALLED_DIR     = ${VCPKG_ROOT_DIR}\installed\${TRIPLET}
#   DOWNLOADS                 = ${VCPKG_ROOT_DIR}\downloads
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   VCPKG_TOOLCHAIN           = ON OFF
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   BUILD_ARCH                = "Win32" "x64" "ARM"
#   MSBUILD_PLATFORM          = "Win32"/"x64"/${TRIPLET_SYSTEM_ARCH}
#   DEBUG_CONFIG              = "Debug Static" "Debug Dll"
#   RELEASE_CONFIG            = "Release Static"" "Release DLL"
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_LINUX
#   VCPKG_TARGET_IS_OSX
#   VCPKG_TARGET_IS_FREEBSD
#   VCPKG_TARGET_IS_ANDROID
#   VCPKG_TARGET_EXECUTABLE_SUFFIX
#   VCPKG_TARGET_STATIC_LIBRARY_SUFFIX
#   VCPKG_TARGET_SHARED_LIBRARY_SUFFIX
#
# 	See additional helpful variables in /docs/maintainers/vcpkg_common_definitions.md 


# # Specifies if the port install should fail immediately given a condition
#vcpkg_fail_port_install(MESSAGE "marble currently only supports Windows platforms" ON_TARGET "Mac")
#vcpkg_fail_port_install(MESSAGE "marble currently only supports Windows platforms" ON_TARGET "Linux")

include(vcpkg_common_functions)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://anongit.kde.org/marble
    REF 77e47155f186d03222c407d3967137d41cd33dae # should disscuss this with Marble community
   PATCHES
        md32.patch
)

set(POSTFIX d)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX="${POSTFIX}"
)


vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Include files should not be duplicated into the /debug/include directory. If this cannot be disabled in the project cmake, use   file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# /debug/share should not exist. Please reorganize any important files, then use     file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# The /lib/cmake folder should be merged with /debug/lib/cmake and moved to /share/marble/cmake.
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/marble/cmake)
file(GLOB f1  "${CURRENT_PACKAGES_DIR}/lib/cmake/*" ) 
file(GLOB f2  "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/*" ) 
file(COPY ${f2} ${f1} DESTINATION "${CURRENT_PACKAGES_DIR}/share/marble/cmake")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)

#The following dlls were found in /lib or /debug/lib. Please move them to /bin or /debug/bin, respectively.
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
file(GLOB f3  "${CURRENT_PACKAGES_DIR}/lib/plugins/designer/*.dll" ) 
file(GLOB f4  "${CURRENT_PACKAGES_DIR}/debug/lib/plugins/designer/*.dll" ) 
file(COPY ${f3} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY ${f4} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE  ${f3} ${f4} )
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/plugins" "${CURRENT_PACKAGES_DIR}/lib/plugins" )

#The software license must be available at ${CURRENT_PACKAGES_DIR}/share/marble/copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/d41cd33dae-5a253a42e2/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/marble)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/marble/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/marble/copyright)

#The following files are placed in
#E:\space\vcpkg-vs2019-x64\packages\marble_x64-windows:     E:/space/vcpkg-vs2019-x64/packages/marble_x64-windows/astro.dll
#Files cannot be present in those directories.
file(GLOB f5  "${CURRENT_PACKAGES_DIR}/*.dll" ) 
file(GLOB f6  "${CURRENT_PACKAGES_DIR}/debug/*.dll" ) 
file(GLOB f7  "${CURRENT_PACKAGES_DIR}/*.exe" ) 
file(GLOB f8  "${CURRENT_PACKAGES_DIR}/debug/*.exe" ) 
file(COPY ${f5} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
file(COPY ${f6} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
file(COPY ${f7} DESTINATION "${CURRENT_PACKAGES_DIR}/tools")

file(REMOVE  ${f6} ${f5} ${f8} ${f7} )

#There should be no empty directories in E:\space\vcpkg-vs2019-x64\packages\marble_x64-windows
#The following empty directories were found:     E:/space/vcpkg-vs2019-x64/packages/marble_x64-windows/debug/lib/plugins/designer
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/plugins/designer ${CURRENT_PACKAGES_DIR}/debug/lib/plugins/designer )


#vcpkg_fixup_cmake_targets()

# # Moves all .cmake files from /debug/share/marble/ to /share/marble/
# # See /docs/maintainers/vcpkg_fixup_cmake_targets.md for more details
# vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/marble)

# # Handle copyright
# file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/marble RENAME copyright)

# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME marble)
