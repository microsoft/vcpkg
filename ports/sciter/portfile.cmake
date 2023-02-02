set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

message(FATAL_ERROR "The sciter port is deprecated by upstream and conflicts with upstream's replacement.

Upstream has stopped active development of sciter and instead encourage users to move to a new library Sciter.JS that uses javascript as the internal scripting language (sciter-js in vcpkg).

Options for existing users are:
1. Depend upon `sciter-js` and change your code to work with the new library
2. Use `\"overrides\"` in manifest mode to pin to `\"version-string\": \"4.4.8.3#1\"`
3. Copy the last available `sciter` version into an overlay port (commit 756f1845537a916ba706f6af544b2f490c30fbb1 at subpath `ports/sciter`)
4. Use the community registry `https://github.com/VuYeK/vcpkg-registry` which may have newer versions of `sciter` available (not affiliated with Microsoft)
")
