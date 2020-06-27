vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tinyfiledialogs
    REF v3.6.3
    FILENAME "frozen_versions/tinyfiledialogs-3.6.3.zip"
    SHA512 42C3BD34B0287CF2477F9EDE049BEA29A9306304E8FAB7740065957D3737F4041899F26F29A0693E801CB0A7B63844509F86441262303FF0A4030A431FFAC648
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/include/tinyfiledialogs/tinyfiledialogs.h _contents)
string(SUBSTRING "${_contents}" 0 1024 _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "${_contents}")
