#include <jxl/cms.h>

int main()
{
	const JxlCmsInterface* cms = JxlGetDefaultCms();
    return cms ? 0 : 1;
}
