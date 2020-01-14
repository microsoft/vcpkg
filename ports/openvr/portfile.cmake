include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/openvr
    REF cdaf2b330c8df58986391b253cd8f04328139823
    SHA512 4ed4e7760d45b2b456e2e8b3b59eb394784225c1fade1fffae87110a5f29bcfc2585fcc6f05e220f064982d67101d0d1a76017f071f4d2f65663795d691fc523
    HEAD_REF master
)

set(VCPKG_LIBRARY_LINKAGE dynamic)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCH_PATH "win64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ARCH_PATH "win32")
else()
    message(FATAL_ERROR "Package only supports x64 and x86 windows.")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME)
    message(FATAL_ERROR "Package only supports windows desktop.")
endif()

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/lib
    ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(COPY ${SOURCE_PATH}/lib/${ARCH_PATH}/openvr_api.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/lib/${ARCH_PATH}/openvr_api.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY
    ${SOURCE_PATH}/bin/${ARCH_PATH}/openvr_api.dll
    ${SOURCE_PATH}/bin/${ARCH_PATH}/openvr_api.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(COPY
    ${SOURCE_PATH}/bin/${ARCH_PATH}/openvr_api.dll
    ${SOURCE_PATH}/bin/${ARCH_PATH}/openvr_api.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(COPY ${SOURCE_PATH}/headers DESTINATION ${CURRENT_PACKAGES_DIR})
file(RENAME ${CURRENT_PACKAGES_DIR}/headers ${CURRENT_PACKAGES_DIR}/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openvr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openvr/LICENSE ${CURRENT_PACKAGES_DIR}/share/openvr/copyright)
