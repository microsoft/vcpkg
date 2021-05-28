vcpkg_fail_port_install(ON_ARCH "arm" "arm64" ON_TARGET "UWP")

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "${PORT} only supports Windows.")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/Microsoft.XAudio2.Redist/1.2.6"
    FILENAME "xaudio2redist.1.2.6.zip"
    SHA512 f9b0bacb5787e0239cbf1ffed8e1e8896aa32f69755b084995b2fd1bfe4d49a876d9a69e26469e8779a461e8ff74dc9d5ea86e1ff045dfe2770dfb08b8ba16c3
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH PACKAGE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(GLOB HEADER_FILES ${PACKAGE_PATH}/build/native/include/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

file(COPY ${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)

file(COPY ${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
file(COPY ${PACKAGE_PATH}/build/native/release/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist_md.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${PACKAGE_PATH}/build/native/debug/lib/${VCPKG_TARGET_ARCHITECTURE}/xapobaseredist_md.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)

file(COPY ${PACKAGE_PATH}/build/native/release/bin/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.dll DESTINATION ${CURRENT_PACKAGES_DIR}/bin/)
file(COPY ${PACKAGE_PATH}/build/native/debug/bin/${VCPKG_TARGET_ARCHITECTURE}/xaudio2_9redist.dll DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin/)

file(INSTALL ${PACKAGE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
