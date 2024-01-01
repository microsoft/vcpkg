vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tzvetkoff/hashids.c
    REF 11ea51510ba968438eb9b1bc3f8c9981be731521 # v1.2.1
    SHA512 a6c066ff6544502f1c0ed55afcf994e6ed52b207e428de58992ec9e3ffef1e6fdb4439f2565e7cb039065403f497fcf8e95a8e3b9843e4f0b9bef22853816270
    HEAD_REF master
    PATCHES
        hashids.patch
)

set(EXTRA_OPTS "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # $LIBS is an environment variable that vcpkg already pre-populated with some libraries. 
    # We need to re-purpose it when passing LIBS option to make to avoid overriding the vcpkg's own list.  
    list(APPEND EXTRA_OPTS "LIBS=-lgetopt \$LIBS")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${EXTRA_OPTS}
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/hashids" RENAME copyright)
