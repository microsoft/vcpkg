# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/nvidia-texture-tools-2.1.0)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/castano/nvidia-texture-tools/archive/2.1.0.tar.gz"
    FILENAME "2.1.0.tar.gz"
    SHA512 6c5c9588af57023fc384de080cbe5c5ccd8707d04a9533384c606efd09730d780cb21bcf2d3576102a3facd2f281cacb2625958d74575e71550fd98da92e38b6
)
vcpkg_extract_source_archive(${ARCHIVE})

if (TRIPLET_SYSTEM_ARCH MATCHES "x86")
    set(MSBUILD_PLATFORM "Win32")
else ()
    set(MSBUILD_PLATFORM ${TRIPLET_SYSTEM_ARCH})
endif()

vcpkg_build_msbuild(PROJECT_PATH "${SOURCE_PATH}/project/vc12/nvtt.sln"
                    PLATFORM ${MSBUILD_PLATFORM}
                    OPTIONS "/p:PlatformToolset=v140")
vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies("${SOURCE_PATH}/project/vc12/Release.${MSBUILD_PLATFORM}/bin")
file(GLOB HEADERS "${SOURCE_PATH}/project/vc12/Release.${MSBUILD_PLATFORM}/include/nvtt/*")
file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include/nvtt)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nvidia-texture-tools)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nvidia-texture-tools/LICENSE ${CURRENT_PACKAGES_DIR}/share/nvidia-texture-tools/copyright)
