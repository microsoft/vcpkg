#include <qsysinfo.h>
#include <qstring.h>
#include <cstdio>
int main(int argc, char** argv) {
	auto buildABI = QSysInfo::buildAbi().toStdString();
	fprintf(stdout, "%s\n", buildABI.c_str());
	printf("%d\n", QSysInfo::windowsVersion());
	return 0;
}