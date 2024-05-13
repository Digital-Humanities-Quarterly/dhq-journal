
 There should be a directory in this directory called staticSearch/;
 however (as of this writing), there is no such directory in the
 repository itself. Thus, to get static search capability to work for
 now, you will need to create a symbolic link (or the Windows
 equivalent) named staticSearch/ which points to staticSearch-1.4.7/,
 or rename staticSearch-1.4.7/ to staticSearch/.

 This is done because we are currently experimenting with different
 releases of the University of Victoria Endings Project StaticSearch
 utility (hereafter “UVEPSS”), and it is easier to use a symlink to
 the desired specific directory than renaming things constantly. So,
 e.g., one might clone the repository, which has staticSearch-1.4.7/,
 and then install the current latest version as staticSearch-1.5.1/
 (or whatever), and then install the development version as
 staticSearch_gitHub/; then select which one to use by establishing a
 symbolic link between staticSearch/ and the desired version-specific
 directory.

 However, we have *slight* modifications to UVEPSS which need to be
 reflected in the copy here. So to install a new or different version
 of UVEPSS for DHQ, after obtaining the desired UVEPSS installation
 directory (for which see
 https://endings.uvic.ca/staticSearch/docs/howDoIGetIt.html), make the
 following changes:
  * In file js/ssUtilities.js change the value of
      ss.captions.get('en').strScore
    from "Score:" to " hits:".
