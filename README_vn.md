# Vcpkg: Tổng quan

[English](README.md)
[中文总览](README_zh_CN.md)
[Español](README_es.md)
[한국어](README_ko_KR.md)
[Français](README_fr.md)

Vcpkg giúp bạn quản lý các thư viện C và C++ trên Windows, Linux và MacOS.
Phần mềm này và hệ sinh thái của nó vẫn đang không ngừng phát triển, và chúng tôi luôn trân trọng những đóng góp của bạn!

Nếu bạn chưa từng sử dụng vcpkg trước đây, hoặc nếu bạn đang tìm hiểu cách để sử dụng vcpkg, xin hãy xem phần [Bắt Đầu](#bắt-đầu) cho hướng dẫn cài đặt vcpkg.

Để xem mô tả ngắn về những lệnh khả thi, khi bạn đã cài đặt vcpkg, bạn có thể chạy `vcpkg help`, hoặc `vcpkg help [command]` cho những lệnh nhất định.

* GitHub: Các port ở [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg), phần mềm ở [https://github.com/microsoft/vcpkg-tool](https://github.com/microsoft/vcpkg-tool)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), kênh #vcpkg
* Discord: [\#include \<C++\>](https://www.includecpp.org), kênh #🌏vcpkg
* Docs: [Tài liệu](https://learn.microsoft.com/vcpkg)

# Mục Lục

- [Vcpkg: Tổng quan](#vcpkg-tổng-quan)
- [Mục Lục](#mục-lục)
- [Bắt Đầu](#bắt-đầu)
  - [Bắt Đầu Nhanh: Windows](#bắt-đầu-nhanh-windows)
  - [Bắt Đầu Nhanh: Unix](#bắt-đầu-nhanh-unix)
  - [Cài đặt Developer Tools cho Linux](#cài-đặt-developer-tools-cho-linux)
  - [Cài đặt Developer Tools cho macOS](#cài-đặt-developer-tools-cho-macos)
  - [Sử dụng vcpkg với CMake](#sử-dụng-vcpkg-với-cmake)
    - [Visual Studio Code với Công cụ CMake](#visual-studio-code-với-công-cụ-cmake)
    - [Vcpkg với Visual Studio CMake Projects](#vcpkg-với-visual-studio-cmake-projects)
    - [Vcpkg với CLion](#vcpkg-với-clion)
    - [Vcpkg dưới dạng Submodule](#vcpkg-dưới-dạng-submodule)
- [Gợi ý/Tự động điền](#gợi-ýtự-động-điền)
- [Các ví dụ](#các-ví-dụ)
- [Đóng Góp](#đóng-góp)
- [Giấy Phép](#giấy-phép)
- [Bảo Mật](#bảo-mật)
- [Thu Thập Dữ Liệu](#thu-thập-dữ-liệu)

# Bắt Đầu
Đầu tiên, hãy làm theo hướng dẫn cài đặt cho [Windows](#bắt-đầu-nhanh-windows), hoặc [macOS và Linux](#bắt-đầu-nhanh-unix), tùy theo hệ điều hành mà bạn đang sử dụng.

Ngoài ra, hãy xem [Cài đặt và Sử dụng Packages][getting-started:using-a-package].
Nếu một thư viện bạn cần hiện đang chưa có trong vcpkg, bạn có thể [mở một issue trên GitHub repo][contributing:submit-issue] nơi mà đội ngũ vcpkg và cộng đồng có thể thấy và có khả năng thêm port đó vào vcpkg.

Sau khi bạn đã cài đặt vcpkg, bạn có thể muốn thêm [tự động điền](#gợi-ýtự-động-điền) vào shell của bạn.

## Bắt Đầu Nhanh: Windows

Yêu cầu:
- Windows 7 trở lên
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 2015 Update 3 trở lên với gói ngôn ngữ Tiếng Anh

Đầu tiên, tải và khởi động vcpkg; nó có thể được cài đặt bất kỳ đâu, nhưng
chúng tôi khuyến cáo sử dụng vcpkg như một submoudle cho các project CMake,
và cài đặt nó toàn máy cho các project Visual Studio.
Chúng tôi gợi ý cài ở những nơi như `C:\src\vcpkg` hoặc `C:\dev\vcpkg`,
bởi vì nếu cài những nơi khác bạn có thể gặp các lỗi đường dẫn đối với
hệ thống build của một vài port.

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Để cài đặt các thư viện cho project của bạn, hãy chạy:

```cmd
> .\vcpkg\vcpkg install [packages to install]
```

Lưu ý: Lệnh này sẽ mặc định cài đặt phiên bản x86 của thư viện, để cài x64 hãy chạy:

```cmd
> .\vcpkg\vcpkg install [package name]:x64-windows
```

Hoặc

```cmd
> .\vcpkg\vcpkg install [packages to install] --triplet=x64-windows
```

Bạn cũng có thể tìm kiếm các thư viện bạn cần với lệnh `search`:

```cmd
> .\vcpkg\vcpkg search [search term]
```

Để sử dụng vcpkg với Visual Studio,
hãy chạy lệnh sau (có thể yêu cầu quyền administrator):

```cmd
> .\vcpkg\vcpkg integrate install
```

Sau khi xong, bạn có thể tạo một project mới (trừ CMake), hoặc mở một project có sẵn.
Tất cả các thư viện sẽ ngay lập tức có sẵn để được `#include` và sử dụng
trong project của bạn mà không cần cấu hình gì thêm.

Nếu bạn đang sử dụng CMake với Visual Studio,
hãy tiếp tục [ở đây](#vcpkg-với-visual-studio-cmake-projects).

Để sử dụng vcpkg với CMake bên ngoài một IDE,
bạn có thể sử dụng file toolchain:

```cmd
> cmake -B [build directory] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [build directory]
```

Với CMake, bạn vẫn sẽ cần thêm `find_package` và những lệnh khác để sử dụng thư viện.
Hãy xem [phần CMake](#sử-dụng-vcpkg-với-cmake) để biết thêm,
bao gồm việc sử dụng CMake với một IDE.

## Bắt Đầu Nhanh: Unix

Yêu cầu cho Linux:
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

Yêu cầu cho macOS:
- [Apple Developer Tools][getting-started:macos-dev-tools]

Đầu tiên, tải và khởi động vcpkg; nó có thể được cài đặt bất kỳ đâu, nhưng
chúng tôi khuyến cáo sử dụng vcpkg như một submoudle cho các project CMake.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Để cài đặt các thư viện cho project của bạn, hãy chạy:

```sh
$ ./vcpkg/vcpkg install [packages to install]
```

Bạn cũng có thể tìm kiếm các thư viện bạn cần với lệnh `search`:

```sh
$ ./vcpkg/vcpkg search [search term]
```

Để sử dụng vcpkg với CMake, bạn có thể sử dụng file toolchain:

```sh
$ cmake -B [build directory] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
$ cmake --build [build directory]
```

Với CMake, bạn vẫn sẽ cần thêm `find_package` và những lệnh khác để sử dụng thư viện.
Hãy xem [phần CMake](#sử-dụng-vcpkg-với-cmake) để biết thêm
về các tốt nhất để sử dụng vcpkg với CMake,
và Công cụ CMake cho VSCode.

## Cài đặt Developer Tools cho Linux

Dưới nhiều phiên bản Linux, có các package sau đây bạn sẽ cần phải cài đặt:

- Debian, Ubuntu, popOS, và các phiên bản khác dựa trên Debian:

```sh
$ sudo apt-get update
$ sudo apt-get install build-essential tar curl zip unzip
```

- CentOS

```sh
$ sudo yum install centos-release-scl
$ sudo yum install devtoolset-7
$ scl enable devtoolset-7 bash
```

Cho bất kỳ phiên bản nào khác, hãy chắc chắn rằng bạn cài đặt g++ 6 trở lên.
Nếu bạn muốn thêm hướng dẫn cho phiên bản của bạn,
[xin hãy mở một PR][contributing:submit-pr]!

## Cài đặt Developer Tools cho macOS

Trên macOS, thứ duy nhất bạn cần làm là chạy lệnh sau đây trong terminal:

```sh
$ xcode-select --install
```

Sau đó làm theo hướng dẫn trong cửa sổ được mở ra.

Sau đó bạn sẽ có thể khởi động vcpkg theo hướng dẫn ở [bắt đầu nhanh](#bắt-đầu-nhanh-unix)

## Sử dụng vcpkg với CMake

### Visual Studio Code với Công cụ CMake

Thêm phần sau đây vào file `settings.json` trong workspace của bạn
sẽ làm cho Công cụ CMake tự động sử dụng vcpkg cho các thư viện
của bạn:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Vcpkg với Visual Studio CMake Projects

Mở CMake Settings Editor, dưới phần `CMake toolchain file`,
thêm đường dẫn tới file vcpkg toolchain:

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### Vcpkg với CLion

Mở Toolchains settings
(File > Settings on Windows and Linux, CLion > Preferences on macOS),
và đi tới phần CMake settings (Build, Execution, Deployment > CMake).
Sau đó, trong `CMake options`, thên dòng sau đây:

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

Bạn phải thêm dòng này vào mỗi profile khác nhau.

### Vcpkg dưới dạng Submodule

Khi sử dụng vcpkg như một submodule cho project của bạn,
bạn có thể thêm dòng sau đây vào file CMakeLists.txt trước dòng `project()` đầu tiên,
thay vì phải sự dụng lệnh `CMAKE_TOOLCHAIN_FILE`.

```cmake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file")
```

Cách này vẫn hỗ trợ những người không dùng vcpkg,
bằng cách trực tiếp thêm `CMAKE_TOOLCHAIN_FILE`,
nhưng nó sẽ khiến việc cấu hình-build trở nên dễ dàng hơn.

[getting-started:using-a-package]: https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #cài-đặt-developer-tools-cho-linux
[getting-started:macos-dev-tools]: #cài-đặt-developer-tools-cho-macos
[getting-started:macos-brew]: #installing-gcc-on-macos
[getting-started:macos-gcc]: #installing-gcc-on-macos
[getting-started:visual-studio]: https://visualstudio.microsoft.com/

# Gợi ý/Tự động điền

`vcpkg` hỗ trợ tự động điền các lệnh, tên package, và các
cài đặt trong lẫn powershell và bash.
Để bật tự động điền trong shell của bạn, hãy chạy:

```pwsh
> .\vcpkg integrate powershell
```

Hoặc

```sh
$ ./vcpkg integrate bash # or zsh
```

tùy theo shell mà bạn sử dụng, rồi khởi động lại console.

# Các ví dụ

Hãy xem [tài liệu](https://learn.microsoft.com/vcpkg) cho các hướng dẫn chi tiết,
bao gồm [cài đặt và sử dụng một package](https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages),
[thêm package mới từ file zip](https://learn.microsoft.com/vcpkg/examples/packaging-zipfiles),
và [thêm package mới từ GitHub repo](https://learn.microsoft.com/vcpkg/examples/packaging-github-repos).

Tài liệu của chúng tôi hiện đang có sẵn tại website https://vcpkg.io/. Chúng tôi rất trân trọng
bất kỳ phản hồi nào của các bạn! Bạn có thể tạo một issue trong https://github.com/vcpkg/vcpkg.github.io/issues.

Xem [video demo](https://www.youtube.com/watch?v=y41WFKbQFTw) dài 4 phút.

# Đóng Góp

Vcpkg là một dự án mã nguồn mở, và được xây dụng từ sự đóng góp của các bạn.
Sau đây là các cách mà bạn có thể đóng góp:

* [Tạo Issues][contributing:submit-issue] về vcpkg hoặc các package.
* [Sửa lỗi và Thêm các package mới][contributing:submit-pr]

Xin hãy xem chi tiết trong [Hướng dẫn Đóng góp](CONTRIBUTING.md).

Dự án này áp dụng [Bộ Quy tắc Ứng xử Mã Nguồn Mở của Microsoft][contributing:coc].
Các thông tin thêm, hãy xem [Quy tắc Ứng xử FAQ][contributing:coc-faq]
hoặc gửi mail cho chúng tôi tại [opencode@microsoft.com](mailto:opencode@microsoft.com)
với các câu hỏi hoặc bình luận.

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# Giấy Phép

Mã nguồn trong repository này được cấp phép theo [Giấy phép MIT](LICENSE.txt). Các thư viện
cung cấp bởi các port được cấp phép theo các điều khoản của tác giả gốc. Khi khả thi, vcpkg
đặt (các) giấy phép liên quan tại `installed/<triplet>/share/<port>/copyright`.

# Bảo Mật

Hầu hết các port đều build các thư viện liên quan sử dụng các hệ thống build gốc được khuyến cáo
bởi tác giả gốc của các thư viện đó, và tải mã nguồn và công cụ build từ nguồn chính thức của họ.
Để sử dụng dưới tường lửa, các quyền truy cập nhất định sẽ dựa vào port nào đang được cài đặt.
Nếu bạn buộc phải cài đặt trong một môi trường "cách ly không khí", xin hãy cân nhắc việc cài đặt
một lần trong môi trường không "cách ly không khí", để tạo [asset cache](https://learn.microsoft.com/vcpkg/users/assetcaching) được chia sẻ với môi trường "cách ly không khí" kia.

# Thu Thập Dữ Liệu

vcpkg thu thập dữ liệu trong lúc sử dụng để giúp chúng tôi cải thiện trải nghiệm của bạn.
Dữ liệu thu thập được bởi Microsoft là ẩn danh.
Bạn có thể tùy chọn không thu thập dữ liệu bằng cách
- chạy bootstrap-vcpkg với lệnh -disableMetrics
- chạy vcpkg với lệnh --disable-metrics
- thêm VCPKG_DISABLE_METRICS vào biến môi trường

Đọc thêm về việc thu thập dữ liệu của vcpkg tại [https://learn.microsoft.com/vcpkg/about/privacy](https://learn.microsoft.com/vcpkg/about/privacy).
