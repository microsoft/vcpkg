include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/kemoticons
    REF v5.51.0
    SHA512 565582544d3016ac0206508212b74b2fae2ad68877901550b24fcc576112e11a5d6526b2d5193ac12cd91b93f69b422f674d83feca2ac6580a62465c6c8c8981
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DBUILD_HTML_DOCS=OFF
            -DBUILD_MAN_DOCS=OFF
            -DBUILD_QTHELP_DOCS=OFF
            -DBUILD_TESTING=OFF
            -DKDE_INSTALL_PLUGINDIR=plugins
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/KF5Emoticons)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data/kservices5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data/kservices5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/data/kservicetypes5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/data/kservicetypes5)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/kf5emoticons RENAME copyright)
