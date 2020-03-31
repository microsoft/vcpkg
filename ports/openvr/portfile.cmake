include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/openvr
    REF 26fa19eb86ab3c589af2bdbc77449d61a8ff799b # v1.10.30
    SHA512 821e113c6a847a244cd138869b5c8192c67054e6b8d39c0764d4e88f7a839146e9d9ec1f189cd5566f8954ad07ee0c86cbf8d353806c9bceb0f0a45def1a0ca2
    HEAD_REF master
)

set(VCPKG_LIBRARY_LINKAGE dynamic)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(ARCH_PATH "win64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(ARCH_PATH "win32")
    else()
        message(FATAL_ERROR "Package only supports x64 and x86 Windows.")
    endif()
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(ARCH_PATH "linux64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(ARCH_PATH "linux32")
    else()
        message(FATAL_ERROR "Package only supports x64 and x86 Linux.")
    endif()
else()
    message(FATAL_ERROR "Package only supports Windows and Linux.")
endif()

file(COPY ${SOURCE_PATH}/lib/${ARCH_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/lib/${ARCH_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/bin/${ARCH_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/bin/${ARCH_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(COPY ${SOURCE_PATH}/headers DESTINATION ${CURRENT_PACKAGES_DIR})
file(RENAME ${CURRENT_PACKAGES_DIR}/headers ${CURRENT_PACKAGES_DIR}/include)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openvr)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/openvr/LICENSE ${CURRENT_PACKAGES_DIR}/share/openvr/copyright)
