/*
 * openzl wrapper around xxHash distributed via vcpkg.
 *
 * This header preserves the local configuration tweaks provided by
 * zs_xxhash.h and then includes the xxhash header from the external
 * dependency.
 */
#pragma once

#include "openzl/shared/zs_xxhash.h"
#include <xxhash.h>
