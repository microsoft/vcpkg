include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/openvr
    REF 02bc73b9bcfe9cc2d2802bd5fdc91f724de8ef10
    SHA512 5b0b954b09570dcf72f0340d6bcc0a5ba9e754babf33aaee35c9d45ce08f5256643692705b014b8c94b098b554e7882a837cf6a2c25e946e6bc69ba3b9db0ede
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
