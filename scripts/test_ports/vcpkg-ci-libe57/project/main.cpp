#include <e57/E57Simple.h>

int main() {
    int astmMajor = 0;
    int astmMinor = 0;
    e57::ustring libraryId;
	
	e57::E57Utilities utils;
    utils.getVersions(astmMajor, astmMinor, libraryId);
	
	e57::Reader reader("");
    return 0;
}
