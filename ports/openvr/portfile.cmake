vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/openvr
    REF "v${VERSION}"
    SHA512 95e7263e4a03a58c9f6b7efc586a963578fd6c468ce9cd73d2e4caa9fff3a0f63f94e6e69234bc220a49e8a9341c19b8144449116466f9476e0e9cc1ca36e403
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
