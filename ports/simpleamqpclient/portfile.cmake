vcpkg_fail_port_install(ON_LIBRARY_LINKAGE "static")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alanxz/SimpleAmqpClient
    REF eefabcdb25b6adf841dcc226abfdce94c27a4446 #version 2.4 commit on 2019.4.19
    SHA512 3f4fe7c20e0e557af03a98a5489efe5ebd65e8331dca4305eef9c9be0c8f728be18bef3973baeae401be4f321fdd6372f53b83e79d685d48bd8c918b6a9c907a
    HEAD_REF master
    PATCHES
        Fix-FindLibrabbitmq.patch
        Fix-BuildError.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
