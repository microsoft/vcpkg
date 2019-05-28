include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/openvr
    REF 957d0017b73ea7ef1be5cccccff7bbe9575e852e
    SHA512 b6fa6321a03981c558e3efc25101e83df2b9743be39dfebb1aec1bb2dffff8b2b064f4332d88007a3f746ce16b37da4500f17b45166622ed358e9493f953dc32
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
