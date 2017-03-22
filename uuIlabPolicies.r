# \file
# \brief iRODS policies for Yoda (changes to core.re)
# \author Ton Smeele
# \author Paul Frederiks
# \copyright Copyright (c) 2016, Utrecht university. All rights reserved
# \license GPLv3, see LICENSE
#

pep_resource_modified_post(*out) {
  on(uuinlist($pluginInstanceName, UUPRIMARYRESOURCES)) {
    *pluginInstanceName = $pluginInstanceName;
    *KVPairs = $KVPairs;
    uuReplicateAsynchronously(*KVPairs.logical_path, *pluginInstanceName, UUREPLICATIONRESOURCE);
    # The rules on metadata are run synchronously and could fail. Log errors, but continue with revisions.
    *err = errormsg(uuResourceModifiedPostResearch(*pluginInstanceName, *KVPairs), *msg);
    if (*err < 0) {
    	writeLine("serverLog", "*err: *msg");
    }
    uuResourceModifiedPostRevision(*pluginInstanceName, *KVPairs);
  }
  # see issue https://github.com/irods/irods/issues/3500 below on(true) code is a hack to avoid debug messages in irods 4.1.8
  on(true) {nop;}
}

# \brief pep_resource_rename_post
# \param[in,out] out			This is a required parameter for Dynamic PEP's in 4.1.x releases. It is not used by this rule.
pep_resource_rename_post(*out) {
  on(uuinlist($pluginInstanceName, UUPRIMARYRESOURCES)) {
    *pluginInstanceName = $pluginInstanceName;
    *KVPairs =  $KVPairs;
    uuResourceRenamePostResearch(*pluginInstanceName, *KVPairs);
  }
  # see issue https://github.com/irods/irods/issues/3500 below on(true) code is a hack to avoid debug messages in irods 4.1.8
  on(true) {nop;}
}

# \brief pep_resource_unregister_post   
# \param[in,out] out			This is a required parameter for Dynamic PEP's in 4.1.x releases. It is not used by this rule.
pep_resource_unregistered_post(*out) {
	on (uuinlist($pluginInstanceName, UUPRIMARYRESOURCES)) {
		*pluginInstanceName = $pluginInstanceName;
		*KVPairs = $KVPairs;
		uuResourceUnregisteredPostResearch(*pluginInstanceName, *KVPairs);
	}
        # see issue https://github.com/irods/irods/issues/3500 below on(true) code is a hack to avoid debug messages in irods 4.1.8
        on(true) {nop;}
}

#input null
#output ruleExecOut
