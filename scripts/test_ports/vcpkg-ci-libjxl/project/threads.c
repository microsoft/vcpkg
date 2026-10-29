#include <jxl/thread_parallel_runner.h>

int main()
{
	const size_t concurrency = JxlThreadParallelRunnerDefaultNumWorkerThreads();
	return (int)concurrency;
}
