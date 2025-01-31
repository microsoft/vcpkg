// This shim header file is a workaround for vcpkg-unfriendly inclusion of libraries in Adobe XMP Toolkit SDK.
// It avoids the need to patch multiple files.
// If/when Adobe XMP Toolkit SDK become more package manager friendly, this header file should be removed.

#include "${CURRENT_INSTALLED_DIR}/${TRIPLET}/include/zlib.h"