# \file
# \brief iRODS policies for Yoda (changes to core.re)
# \author Ton Smeele
# \copyright Copyright (c) 2016, Utrecht university. All rights reserved
# \license GPLv3, see LICENSE
#

pep_resource_modified_post(*out) {
   *sourceResource = $pluginInstanceName;
   if (*sourceResource == 'irodsResc') {
      uuReplicateAsynchronously($KVPairs.logical_path, *sourceResource, 'irodsRescRepl');
   }
}


#input null
#output ruleExecOut
