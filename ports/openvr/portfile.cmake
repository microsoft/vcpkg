vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ValveSoftware/openvr
    REF 4c85abcb7f7f1f02adaf3812018c99fc593bc341 # v1.16.8
    SHA512 366e553e6c9caa2bf884caf41b29a7ae6bdad165aeb56ea469625dc963bd91fd8423e753d07a28f8b6a69eed3939ba5a5e4fb0f84b52074bf6279b510e66f793
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

file(INSTALL ${SOURCE_PATH}/headers DESTINATION ${CURRENT_PACKAGES_DIR} RENAME include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
