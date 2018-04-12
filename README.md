The scipt automatically choose best settings for zram drives and their purpose using the conf files. 

Memory is fetched in MB from conf files, zram requires byte, initialiser will convert automatically
A simplified conversion rate between mem suffixes (1000)

The script is robust, a broken config should deal no harm, service will initialise with 0 drives

If zram_swap is (appropriatelly) configured, drive size will be equal to 2 * memory pool

Plausible memory usage:
Under the assumption that a configuration provides memory pool share and fixed value limits, the script will take the biggest one that would fit into pool, or maximum pool size otherwise.

# script fixes wrong configuration values
# and subsets working defaults if needed
# and converts the values to 1000's multipliers
# this way we'll 'automagically' convert mem pool to byte

TODO:
- interactive configurator
- memory prefixes (MB, GB, TB ...)