<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="tei dhq xdoc" version="1.0">
    <xsl:import href="comments.xsl"/>
    <xsl:import href="commentscount.xsl"/>
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/> 
    <xsl:import href="dhq2html.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    <xdoc:doc type="stylesheet">
        <xdoc:author>John A. Walsh</xdoc:author>
        <xdoc:copyright>Copyright 2006 John A. Walsh</xdoc:copyright>
        <xdoc:short>XSLT stylesheet to transform DHQauthor documents to XHTML.</xdoc:short>
    </xdoc:doc>
    <xsl:param name="context"/>
    <!-- $vol, $issue, and $id are parameters set in dhq2html.xsl . -->
    <xsl:param name="fpath" select="concat('vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/>
    <xsl:param name="error"/>
    <!-- When $doProofing is true(), no check is made to ensure that the article exists in the TOC. -->
    <xsl:param name="doProofing" select="false()"/>
    <xsl:param name="staticPublishingPath">
        <xsl:value-of select="'../../articles/'"/>
    </xsl:param>
    
    <xsl:template match="/">
        <!-- Check to see if article exists [CRB] -->
      <xsl:param name="cleanId">
        <!-- Introduced $cleanId to deal with archived articles XXXXXX_XX.xml -->
        <xsl:choose>
          <xsl:when test="contains($id,'_')">
            <xsl:value-of select="substring-before($id,'_')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:param>
        <xsl:choose>
            <xsl:when test="$doProofing 
              or document('../../toc/toc.xml')//journal[@vol=$vol_no_zeroes 
                                                    and @issue=$issue 
                                                    and descendant::item/attribute::id=$cleanId 
                                                    and not(@editorial)]">
                <xsl:apply-templates select="tei:TEI"/>
            </xsl:when>
            <xsl:when test="$error">
                <html>
                    <xsl:call-template name="head">
                        <xsl:with-param name="title" select="'Error'"/>
                    </xsl:call-template>
		    <body>
                        <xsl:call-template name="topnavigation"/>
                        <div id="main">
                            <div id="leftsidebar">
                                <xsl:call-template name="sidenavigation"/>
                            </div>
                            <div id="mainContent">
                                <xsl:call-template name="sitetitle"/>
                                <h1>An error occurred.</h1>
                                <p>We're sorry, but your request resulted in a processing error.</p>
                                <h2>Contact Information</h2>
                                <h3>Email</h3>
                                <p>General Information: <a href="mailto:dhqinfo@digitalhumanities.org">dhqinfo@digitalhumanities.org</a></p>
                                <xsl:call-template name="footer">
                                    <xsl:with-param name="docurl" select="'contact/error.html'"/>
                                </xsl:call-template>
                            </div>
                        </div>
		        <xsl:call-template name="body-end-scripts"/>
                    </body>
                </html>
            </xsl:when>
            <xsl:otherwise>
                <html>
                    <xsl:call-template name="head">
                        <xsl:with-param name="title" select="'Resource Not Found'"/>
                    </xsl:call-template>
                    <body>
                        <xsl:call-template name="topnavigation"/>
                        <div id="main">
                            <div id="leftsidebar">
                                <xsl:call-template name="sidenavigation"/>
                            </div>
                            <div id="mainContent">
                                <xsl:call-template name="sitetitle"/>
                                <h1>Resource not found.</h1>
                                <p>The resource you requested<!-- 
                                  2024-05-17: Ash commented out the instruction below, since the static 
                                  site will not be able to construct a 404 response including the 
                                  requested resource path.
                                    (/<xsl:value-of select="concat($context,'/',$fpath)"/>)
                                  --> does not exist.</p>
                                <h2>Contact Information</h2>
                                <h3>Email</h3>
                                <p>General Information: <a href="mailto:dhqinfo@digitalhumanities.org">dhqinfo@digitalhumanities.org</a></p>
                                <xsl:call-template name="footer">
                                    <xsl:with-param name="docurl" select="'contact/notfound.html'"/>
                                </xsl:call-template>
                            </div>
                        </div>
                        <xsl:call-template name="body-end-scripts"/>
                    </body>
                </html>                    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="body-end-scripts">
        <script>hljs.highlightAll();</script>
    </xsl:template>
        
    
    <xsl:template match="tei:TEI">
        <html>
            <!-- code to retrieve document title from the html file and pass it to the template -->
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
            </xsl:call-template>
            <body>
                <xsl:call-template name="topnavigation"/>
                <div id="main">
                    <div id="leftsidebar">
                        <xsl:call-template name="sidenavigation"/>
                    </div>
                    <div id="mainContent">
                        <xsl:call-template name="sitetitle"/>
                        <!-- Rest of the document/article is coverd in this template - this is a call to dhq2html.xsl -->
                        <xsl:call-template name="article_main_body"> 
				<xsl:with-param name="docurl" select="$fpath"/>
				<xsl:with-param name="id" select="$id"/>
			</xsl:call-template>
		<!--	
			<xsl:call-template name="commentscount">
			</xsl:call-template>

			<xsl:call-template name="comments">
			   <xsl:with-param name="docurl" select="$fpath"/>
   	                   <xsl:with-param name="id" select="$id"/>
                        </xsl:call-template>
-->
			
                        <!-- Use the URL generated to pass to the footer -->
                        <xsl:call-template name="footer">
                            <xsl:with-param name="docurl" select="$fpath"/>
                        </xsl:call-template>
                    </div>
                </div>
                <xsl:call-template name="customBody"/>
                <xsl:call-template name="body-end-scripts"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- customBody template (below) may be overridden in article-specific XSLT (in articles/XXXXXX/resources/xslt/XXXXXX.xsl) to include additional stuff at end of the HTML <body>. See 000151. -->
    <xsl:template name="customBody"/>
    
</xsl:stylesheet>
