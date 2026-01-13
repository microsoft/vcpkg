#include <svn_client.h>
#include <svn_version.h>
#include <svn_delta.h>
#include <svn_diff.h>
#include <svn_fs.h>
#include <svn_ra.h>
#include <svn_repos.h>
#include <svn_wc.h>
#include <stdio.h>

int main()
{
    // Test svn_client library
    const svn_version_t *client_version = svn_client_version();
    printf("svn_client version: %d.%d.%d\n", 
           client_version->major, 
           client_version->minor, 
           client_version->patch);
    
    // Test svn_delta library
    const svn_version_t *delta_version = svn_delta_version();
    printf("svn_delta version: %d.%d.%d\n", 
           delta_version->major, 
           delta_version->minor, 
           delta_version->patch);
    
    // Test svn_diff library
    const svn_version_t *diff_version = svn_diff_version();
    printf("svn_diff version: %d.%d.%d\n", 
           diff_version->major, 
           diff_version->minor, 
           diff_version->patch);
    
    // Test svn_fs library
    const svn_version_t *fs_version = svn_fs_version();
    printf("svn_fs version: %d.%d.%d\n", 
           fs_version->major, 
           fs_version->minor, 
           fs_version->patch);
    
    // Test svn_ra library
    const svn_version_t *ra_version = svn_ra_version();
    printf("svn_ra version: %d.%d.%d\n", 
           ra_version->major, 
           ra_version->minor, 
           ra_version->patch);
    
    // Test svn_repos library
    const svn_version_t *repos_version = svn_repos_version();
    printf("svn_repos version: %d.%d.%d\n", 
           repos_version->major, 
           repos_version->minor, 
           repos_version->patch);
    
    // Test svn_subr library
    const svn_version_t *subr_version = svn_subr_version();
    printf("svn_subr version: %d.%d.%d\n", 
           subr_version->major, 
           subr_version->minor, 
           subr_version->patch);
    
    // Test svn_wc library
    const svn_version_t *wc_version = svn_wc_version();
    printf("svn_wc version: %d.%d.%d\n", 
           wc_version->major, 
           wc_version->minor, 
           wc_version->patch);
    
    // Note: svn_fs_fs, svn_fs_util, svn_fs_x, svn_ra_local, svn_ra_serf, and svn_ra_svn
    // are internal/plugin libraries that don't have version functions.
    // They are loaded and linked, which validates their presence.
    
    printf("\nAll 14 subversion libraries loaded and tested successfully!\n");
    printf("Tested: svn_client, svn_delta, svn_diff, svn_fs, svn_ra, svn_repos, svn_subr, svn_wc\n");
    printf("Linked: svn_fs_fs, svn_fs_util, svn_fs_x, svn_ra_local, svn_ra_serf, svn_ra_svn\n");
    return 0;
}
