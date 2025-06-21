<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml" version="1.0">
  <!-- This file is currently unused. —Syd, 2025-06-20 -->
  <xsl:template name="comments">
    <xsl:param name="id"/>
    <xsl:param name="docurl"/>
    <xsl:param name="baseurl" select="'http://www.digitalhumanities.org/dhq/'"/>
    <div id="comments">
      <div id="disqus_thread"></div>
      <script type="text/javascript">
    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
    var disqus_shortname = 'dhquarterly'; // required: replace example with your forum shortname

    // The following are highly recommended additional parameters. Remove the slashes in front to use.
    var disqus_identifier = '<xsl:value-of select="$id"/>';
    var disqus_url = '<xsl:value-of select="concat($baseurl,$docurl)"/>';

    /* * * DON'T EDIT BELOW THIS LINE * * */
    (function() {
        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
        dsq.src = 'http://' + disqus_shortname + '.disqus.com/embed.js';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
    })();
      </script>
      <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
    </div>
  </xsl:template>
</xsl:stylesheet>
