vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cpp-io2d/P0267_RefImpl
    REF add3c9792dcd3f08c497ae3adafb2a3b5b5fc338
    SHA512 2727342fbb31523583374ab6df6ff7542e80b4f94319cf0f293e8c085711fa10ed312b4fc4b91391112b5e27eaaae519cb4141ea9d4108ffb5b7383a043b38b8
    HEAD_REF master
    PATCHES
        fix-linux-build.patch
        Fix-FindCairo.patch
        fix-expat.patch
)

if (VCPKG_TARGET_IS_OSX)
    set(IO2D_DEFAULT_OPTION "-DIO2D_DEFAULT=COREGRAPHICS_MAC")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DIO2D_WITHOUT_SAMPLES=1
        -DIO2D_WITHOUT_TESTS=1
        -DCMAKE_INSTALL_INCLUDEDIR:STRING=include
        ${IO2D_DEFAULT_OPTION}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/io2d)

if (NOT VCPKG_TARGET_IS_OSX)
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/io2d/io2dConfig.cmake ${CURRENT_PACKAGES_DIR}/share/io2d/io2dTargets.cmake)
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/io2d/io2dConfig.cmake "
    include(CMakeFindDependencyMacro)
    find_dependency(unofficial-cairo CONFIG)
    find_dependency(unofficial-graphicsmagick CONFIG)

    include(\${CMAKE_CURRENT_LIST_DIR}/io2dTargets.cmake)
    ")
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)