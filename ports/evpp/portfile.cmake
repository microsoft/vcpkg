include(vcpkg_common_functions)

set(EVPP_LOCAL_TEST OFF)

set(EVPP_VERSION 0.7.0)
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
        SHA512 ddcef8d2af6b3c46473d755c0f0994d63d56240ea85d6b44ceb6b77724c3c56bbf1156f7188e270fb5f9f36f25bfc2f96669d7249a34c921922671e3fe267e88
        HEAD_REF master
    )
    file(REMOVE_RECURSE ${SOURCE_PATH}/3rdparty/rapidjson ${SOURCE_PATH}/3rdparty/concurrentqueue)

    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES ${CMAKE_CURRENT_LIST_DIR}/fix-rapidjson-1-1.patch
    )
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DEVPP_VCPKG_BUILD=ON
)

vcpkg_install_cmake()

# remove duplicated include files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/evpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/evpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/evpp/copyright)

