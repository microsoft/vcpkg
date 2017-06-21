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

set(EVPP_VERSION 0.6.1)
if (EVPP_LOCAL_TEST)
    set(EVPP_HASH bfefb3f7c1f620fbca2c3d94e2e7c39aa963156a084caf39bcc348a9380f97c73c9ee965126434d71c8b14836e669d554ed98632b3bb38eb65b421fd8eff49b2)
    set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/evpp)
    vcpkg_download_distfile(ARCHIVE
        URLS "http://127.0.0.1:8000/evpp.zip"
        FILENAME "evpp-${EVPP_VERSION}.zip"
        SHA512 ${EVPP_HASH}
    )
else ()
    set(EVPP_HASH 13986f81efc7f831274cc55819980ee57d6a8729867901beafd3d31c50682de304a9552912ace1c7e0a92ee2df41a8c456b5f77f4721d622c97584b38b68cd37)
    set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/evpp-${EVPP_VERSION})
    vcpkg_download_distfile(ARCHIVE
        URLS "https://github.com/Qihoo360/evpp/archive/v${EVPP_VERSION}.zip"
        FILENAME "evpp-${EVPP_VERSION}.zip"
        SHA512 ${EVPP_HASH}
    )
endif ()

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DCMAKE_TOOLCHAIN_FILE=${VCPKG_ROOT_DIR}/scripts/buildsystems/vcpkg.cmake -DEVPP_VCPKG_BUILD=ON
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

