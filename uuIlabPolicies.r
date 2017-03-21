# \file
# \brief iRODS policies for Yoda (changes to core.re)
# \author Ton Smeele
# \author Paul Frederiks
# \copyright Copyright (c) 2016, Utrecht university. All rights reserved
# \license GPLv3, see LICENSE
#

pep_resource_modified_post(*out) {
   *sourceResource = $pluginInstanceName;
   if (*sourceResource == 'irodsResc') {
      uuReplicateAsynchronously($KVPairs.logical_path, *sourceResource, 'irodsRescRepl');
   }
}

# \brief pep_resource_modified_post  	Policy to import metadata when a IIMETADATAXMLNAME file appears. This
#					dynamic PEP was chosen because it works the same no matter if the file is
#					created on the web disk or by a rule invoked in the portal. Also works in case the file is moved.
# \param[in,out] out	This is a required argument for Dynamic PEP's in the 4.1.x releases. It is unused.
pep_resource_modified_post(*out) {
	on (uuinlist($pluginInstanceName, UUILABMAINRESOURCES) && ($KVPairs.logical_path like regex "^/" ++ $KVPairs.client_user_zone ++ "/home/" ++ IIGROUPPREFIX ++ "[^/]+(/.\*)\*/" ++ IIMETADATAXMLNAME ++ "$")) {
		writeLine("serverLog", "pep_resource_modified_post:\n \$KVPairs = $KVPairs\n\$pluginInstanceName = $pluginInstanceName\n \$status = $status\n \*out = *out");
		iiMetadataXmlModifiedPost($KVPairs.logical_path, $KVPairs.client_user_zone);
	}
}

# \brief pep_resource_modified_post 	Create revisions on file modifications
# \description				This policy should trigger whenever a new file is added or modified
#					in the workspace of a Research team. This should be done asynchronously
# \param[in,out] out	This is a required argument for Dynamic PEP's in the 4.1.x releases. It is unused.
pep_resource_modified_post(*out) {
	on (uuinlist($pluginInstanceName, UUILABMAINRESOURCES) && ($KVPairs.logical_path like "/" ++ $KVPairs.client_user_zone ++ "/home/" ++ IIGROUPPREFIX ++ "*") ) {
		writeLine("serverLog", "pep_resource_modified_post:\n \$KVPairs = $KVPairs\n\$pluginInstanceName = $pluginInstanceName\n \$status = $status\n \*out = *out");
		*path = $KVPairs.logical_path;
		uuChopPath(*path, *parent, *basename);
		if (*basename like "._*") {
			# MacOS writes to ._ multiple times per put
			writeLine("serverLog", "pep_resource_modified_post: Ignore *basename for revision store. This is littering by Mac OS");
		} else {
			uuRevisionCreateAsynchronously(*path);
		}
	}
}

# \brief pep_resource_rename_post	This policy is created to support the moving, renaming and trashing of the .yoda-metadata.xml file
# \param[in,out] out			This is a required parameter for Dynamic PEP's in 4.1.x releases. It is not used by this rule.
pep_resource_rename_post(*out) {
	# run only at the top of the resource hierarchy and when a IIMETADATAXMLNAME file is found inside a research group.
	# Unfortunately the source logical_path is not amongst the available data in $KVPairs. The physical_path does include the old path, but not in a convenient format.
	# When a IIMETADATAXMLNAME file gets moved into a new directory it will be picked up by pep_resource_modified_post.
	# This rule only needs to handle the removal of user metadata when it's moved or renamed.

	on (uuinlist($pluginInstanceName, UUILABMAINRESOURCES) && ($KVPairs.physical_path like regex ".\*/home/" ++ IIGROUPPREFIX ++ "[^/]+(/.\*)\*/" ++ IIMETADATAXMLNAME ++ "$")) {
		writeLine("serverLog", "pep_resource_rename_post:\n \$KVPairs = $KVPairs\n\$pluginInstanceName = $pluginInstanceName\n \$status = $status\n \*out = *out");
		*zone =  $KVPairs.client_user_zone;
		*dst = $KVPairs.logical_path;
		iiLogicalPathFromPhysicalPath($KVPairs.physical_path, *src, *zone);
		iiMetadataXmlRenamedPost(*src, *dst, *zone);

}
}

# \brief pep_resource_unregistered_post		Policy to act upon the removal of a METADATAXMLNAME file.
# \param[in,out] out 				This is a required parameter for Dynamic PEP's in 4.1.x releases. It is not used by this rule.
pep_resource_unregistered_post(*out) {
	on (uuinlist($pluginInstanceName, UUILABMAINRESOURCES) && ($KVPairs.logical_path like regex "^/" ++ $KVPairs.client_user_zone ++ "/home/" ++ IIGROUPPREFIX ++ "[^/]+(/.\*)\*/" ++ IIMETADATAXMLNAME ++ "$")) {

		writeLine("serverLog", "pep_resource_unregistered_post:\n \$KVPairs = $KVPairs\n\$pluginInstanceName = $pluginInstanceName\n \$status = $status\n \*out = *out");
		iiMetadataXmlUnregisteredPost($KVPairs.logical_path);
		}
}

#input null
#output ruleExecOut
