include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SignalR-Client-Cpp-1.0.0-beta1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/aspnet/SignalR-Client-Cpp/archive/1.0.0-beta1.tar.gz"
    FILENAME "SignalR-Client-Cpp-1.0.0-beta1.tar.gz"
    SHA512 e0090415aa724087dbe2a317a4642d6359b134e00e836ea70c71bc9186dc8d6bba097666711ab18d9b0a390e1e5f59be2f55279b6859ac20d558b901bf5fe2f2
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
		${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	OPTIONS_DEBUG
		-DCPPREST_SO=${CURRENT_INSTALLED_DIR}/debug/lib/cpprest_2_9.lib
	OPTIONS_RELEASE
		-DCPPREST_SO=${CURRENT_INSTALLED_DIR}/lib/cpprest_2_9.lib
    OPTIONS
		-DCPPREST_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DDISABLE_TESTS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# copy license
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/signalrclient)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/signalrclient/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/signalrclient/copyright)