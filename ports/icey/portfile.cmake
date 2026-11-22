vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nilstate/icey
    REF "${VERSION}"
    SHA512 9f722a15d47189864a1877a5a4aa45fd6aaeb34b655ec4f8eeef33dcfe79c19b8e412a5c7bcef59e987c1a6356f6ed21c8d60716737cd3eef4024778881bf978
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ffmpeg   WITH_FFMPEG
        opencv   WITH_OPENCV
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_SYSTEM_DEPS=ON
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
        -DBUILD_APPLICATIONS=OFF
        -DBUILD_FUZZERS=OFF
        -DBUILD_BENCHMARKS=OFF
        -DBUILD_ALPHA=OFF
        -DWITH_LIBDATACHANNEL=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=TRUE
        -DVCPKG_LOCK_FIND_PACKAGE_minizip=ON
        -DENABLE_NATIVE_ARCH=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/icey)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(icey_pc_requires "libllhttp minizip openssl")
    if(NOT VCPKG_TARGET_IS_APPLE)
        string(PREPEND icey_pc_requires "libuv-static ")
    endif()
    if("ffmpeg" IN_LIST FEATURES)
        string(APPEND icey_pc_requires " libavcodec libavformat libavutil libswscale libswresample libavdevice libavfilter")
    endif()

    set(icey_pc_libs)
    if(VCPKG_TARGET_IS_WINDOWS)
        set(icey_pc_libs
            -ladvapi32 -liphlpapi -lpsapi -lshell32 -lws2_32 -ldsound -lwinmm -lstrmiids
            -lmf -lmfplat -lmfreadwrite -lmfuuid -lole32
        )
    elseif(VCPKG_TARGET_IS_APPLE)
        set(icey_pc_libs
            # libuv-static.pc uses GNU -l: syntax, which the Apple linker does not support.
            -luv -lpthread -lm
            -framework CoreAudio -framework CoreFoundation -framework Foundation
            -framework AVFoundation -framework CoreMedia
        )
    endif()
    list(JOIN icey_pc_libs " " icey_pc_libs)

    set(icey_pc_files)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        list(APPEND icey_pc_files "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/icey.pc")
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        list(APPEND icey_pc_files "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/icey.pc")
    endif()
    foreach(icey_pc IN LISTS icey_pc_files)
        vcpkg_replace_string("${icey_pc}" "Requires:" "Requires.private: ${icey_pc_requires}\nRequires:")
        if(icey_pc_libs)
            file(APPEND "${icey_pc}" "Libs.private: ${icey_pc_libs}\n")
        endif()
        if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_OHOS OR VCPKG_TARGET_IS_MINGW)
            # Upstream lists modules alphabetically, not in dependency order.
            vcpkg_replace_string("${icey_pc}" "Libs: -L\${libdir}" "Libs: -L\${libdir} -Wl,--start-group")
            vcpkg_replace_string("${icey_pc}" "(Libs:[^\r\n]*)" "\\1 -Wl,--end-group" REGEX)
        endif()
    endforeach()
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
