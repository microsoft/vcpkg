vcpkg_fail_port_install(ON_TARGET "osx")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
<<<<<<< HEAD
    REPO simon987/mupdf
    REF  e8e4cd42074cfe7e399b029ce475eed8b6d46159# simon987/release
    SHA512 ea196078bdc6fff0f83b66938c0713bac5c1b86c5cafbcce04af3c103c532667d312cdb7b16d210d46371894fca1ff88a7cc950148dba6315bb6f0faeb1e55ce
    HEAD_REF release
=======
    REPO ArtifexSoftware/mupdf
    REF ea5799e01730c4aa15cddd1023700e4f7b78cc27 # 1.18.0
    SHA512 4904565e900970939f93bf4326df86851e699699c8e49df7abdbedf6ba3e9d26b74691710b2019d04bba2dea11c7880fe4418b643866128828e388500aa666c2
    HEAD_REF master
>>>>>>> Update libmupdf to 1.18.0
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

file(COPY ${SOURCE_PATH}/include/mupdf DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
