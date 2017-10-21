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
    vcpkg_extract_source_archive(${ARCHIVE})
else ()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Qihoo360/evpp
        REF v${EVPP_VERSION}
        SHA512 08226fe9853c1984f6554ede8f79a5767eec1d12ff2ff7172eef6f715ac7ea3f495b2336876823842408bd92b0ad99c9a3d506c07fc0add369f5cfa777f0406a
        HEAD_REF master
    )
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DEVPP_VCPKG_BUILD=ON
)

vcpkg_install_cmake()

# remove duplicated include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/evpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/evpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/evpp/copyright)

