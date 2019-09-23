include(vcpkg_common_functions)

vcpkg_download_distfile(
  ARCHIVE
  URLS
  "https://downloads.sourceforge.net/project/sigslot/sigslot/1.0.0/sigslot-1-0-0.tar.gz"
  FILENAME
  "sigslot-1-0-0.tar.gz"
  SHA512
  3f16f94a653e49934ec1d695eac02234d15b203f42e9fa88723ee582a84670a645a89e5b87afe2378fa7a9eaef054049255bf3bd531ab1d6825a042641ba8906
  )

vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR})

file(INSTALL ${CURRENT_BUILDTREES_DIR}/sigslot/sigslot.h
     DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(INSTALL ${CURRENT_PORT_DIR}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/sigslot
     RENAME copyright)
