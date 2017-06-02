# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)

set(EVPP_LOCAL_TEST OFF)

set(EVPP_VERSION 0.5.0)
if (EVPP_LOCAL_TEST)
    set(EVPP_HASH c8e25c82a14788231a08fafb44b062cf57fd20e66437f3051d290d96b259aba47e4ac34916e04163b9d25383b1c7ba43f36880f4759390cbd25f776da6dc0738)
    set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/evpp)
    vcpkg_download_distfile(ARCHIVE
        URLS "http://127.0.0.1:8000/evpp.zip"
        FILENAME "evpp-${EVPP_VERSION}.zip"
        SHA512 ${EVPP_HASH}
    )
else ()
    set(EVPP_HASH fce8ebfec8b22b137f827a886f9ef658d70e060cef3950600ac42136d87cdd9357d78897348ed1d1c112c5e04350626fb218b02cba190a2c2a6fb81136eb2d7d)
    set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/evpp-${EVPP_VERSION})
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/Qihoo360/evpp/archive/v${EVPP_VERSION}.zip"
        FILENAME "evpp-${EVPP_VERSION}.zip"
        SHA512 ${EVPP_HASH}
    )
endif ()

message(STATUS "Begin to extract files ...")
vcpkg_extract_source_archive(${ARCHIVE})

message(STATUS "Building evpp project ...")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_TOOLCHAIN_FILE=D:/git/vcpkg/scripts/buildsystems/vcpkg.cmake -DEVPP_VCPKG_BUILD=ON
)

vcpkg_install_cmake()
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/evpp)

#remove duplicated files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# remove not used cmake files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share )
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake )
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake )

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/evpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/evpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/evpp/copyright)

message(STATUS "Installing done")
