vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/openvr
    REF "v${VERSION}"
    SHA512 add58746e4ee55ca78c0132bfc1b8d649dc0ea49d57bbffd3707bf6cbca66f387980e3f4508ae027b25bc560ec54e02269f245e8c41b85c2f03226670048833e
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(ARCH_PATH "win64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(ARCH_PATH "win32")
    else()
        message(FATAL_ERROR "Package only supports x64 and x86 Windows.")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(ARCH_PATH "linux64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(ARCH_PATH "linux32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(ARCH_PATH "linuxarm64")
    else()
        message(FATAL_ERROR "Package only supports x64, x86 and arm64 Linux.")
    endif()
else()
    message(FATAL_ERROR "Package only supports Windows and Linux.")
endif()

file(COPY ${SOURCE_PATH}/lib/${ARCH_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${SOURCE_PATH}/lib/${ARCH_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

file(COPY ${SOURCE_PATH}/bin/${ARCH_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(COPY ${SOURCE_PATH}/bin/${ARCH_PATH}/ DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)

file(INSTALL ${SOURCE_PATH}/headers DESTINATION ${CURRENT_PACKAGES_DIR} RENAME include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
