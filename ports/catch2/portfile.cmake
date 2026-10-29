if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO catchorg/Catch2
    REF v${VERSION}
    SHA512 a6b0f1d1bd9178382f06de9773b31e3efdcdfb20fc3b65b23d9675e0838da6f64c417a75e062bda918dd28781e5d11a78e7130cef2394e676c7bc2da9e49106b
    HEAD_REF devel
    PATCHES
        fix-install-path.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS OPTIONS
    FEATURES
        thread-safe-assertions CATCH_CONFIG_THREAD_SAFE_ASSERTIONS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        -DCATCH_INSTALL_DOCS=OFF
        -DCMAKE_CXX_STANDARD=17
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Catch2)
vcpkg_fixup_pkgconfig()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/catch2-with-main.pc" [["-L${libdir}"]] [["-L${libdir}/manual-link"]])
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/catch2-with-main.pc" [["-L${libdir}"]] [["-L${libdir}/manual-link"]])
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# We remove these folders because they are empty and cause warnings on the library installation
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/benchmark/internal")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/catch2/generators/internal")

file(WRITE "${CURRENT_PACKAGES_DIR}/include/catch.hpp" "#include <catch2/catch_all.hpp>")

vcpkg_download_distfile(CMAKE_LICENSE
    URLS "https://raw.githubusercontent.com/Kitware/CMake/af7ecc8c294d153b0120813776e1fa11c5bfe4a1/LICENSE.rst"
    FILENAME "cmake-license-af7ecc8c294d153b0120813776e1fa11c5bfe4a1.rst"
    SHA512 87a33d2a87dc68aac424b56089c6a41176f5db49c7192fa34b4311212a609db8b52554a0857fea19dcb96a6296087b146cecb675c1653ffaf95a48a0678658fb
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt" "${CMAKE_LICENSE}")
