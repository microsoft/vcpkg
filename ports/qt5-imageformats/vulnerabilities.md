# Vulnerabilities 

This documents lists the known vulnerabilities for the port `qt5-imageformats` and any countermeasures that were taken. 

Please assume that the port is affected by all known vulnerabilities of `qt5-imageformats` that are not listed herein.

## CVE-2023-4863

This port is unaffected by CVE-2023-4863, provided that is is compiled with the current version of `libwebp` from `vcpkg`.

According to [a security advisory from Qt](https://www.qt.io/blog/two-qt-security-advisorys-gdi-font-engine-webp-image-format), `qt5-imageformats` is affected by CVE-2023-4863 through its dependency on `libwebp`. The advisory states the following.

> Solution: As a workaround, update the WebP library manually to 1.3.2 and rebuild the imageformat plugin. Alternatively, apply the corresponding patch or update to Qt 5.15.16, Qt 6.2.10, Qt 6.5.3, Qt 6.6.0

The version of `libwebp` that ships with `vcpkg` is at least 1.3.2 and, hence, unaffected. 

An affected copy of `libwebp` that ships with `qt5-imageformats` is removed before the build. Hence, there is no need to apply the patch provided by Qt.
