
 The staticSearch/ directory herein is version 1.4.9 downloaded from
 the UVEPSS releases page.[1]

 However, we have made minor modifications to UVEPSS which need to be
 reflected in the copy here. So if you download a new version, after
 obtaining the desired UVEPSS installation directory (for which see
 fhttps://endings.uvic.ca/staticSearch/docs/howDoIGetIt.html), make
 the following changes:
  * In file js/ssUtilities.js change the value of
      ss.captions.get('en').strScore
    from "Score:" to " hits:". (Note that starts with U+00A0.)
  * In file xsl/captions.xsl change the values of the various "en"
    mappings from being capitalized to being all lower case, e.g.:
                'ssDoSearch': 'search',
                'ssSearching': 'Searching...',
                'ssLoading': 'Loading...',
                'ssClear': 'clear',
                'ssPoweredBy': 'Powered by',
                'ssStartTyping': 'start typing...',
                'ssSearchIn': 'search only in',
                'ssScriptRequired': 'This page requires JavaScript.'
  * Update this file to reflect the new version number and location
    from where it was obtained.
    
Notes
-----
[1] https://github.com/projectEndings/staticSearch/releases
