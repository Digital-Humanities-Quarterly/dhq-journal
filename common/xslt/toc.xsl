<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="tei dhq xs" version="2.0">
  
    <xsl:param name="vol"><xsl:value-of select="toc/journal[@current]/@vol"/></xsl:param>
    <xsl:param name="issue"><xsl:value-of select="toc/journal[@current]/@issue"/></xsl:param>
    <xsl:param name="staticPublishingPath"><xsl:value-of select="'../../articles/'"/></xsl:param>
    <xsl:param name="context"/>
    <xsl:variable name="apos">'</xsl:variable>

    <xsl:template match="cluster">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="item">
        <xsl:choose>
            <xsl:when test="ancestor::journal[@preview]">
                <xsl:choose>
                    <xsl:when test="parent::cluster">
                        <div class="cluster">
                            <xsl:apply-templates
                                select="document(concat($staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml'))//tei:TEI" mode="preview"/>
                            <xsl:message>
                                <xsl:value-of select="concat('file: ',$staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml')"/>
                            </xsl:message>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates
                            select="document(concat($staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml'))//tei:TEI" mode="preview"/>
                        <xsl:message>
                            <xsl:value-of select="concat('file: ',$staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml')"/>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::journal[@editorial]">
                <xsl:choose>
                    <xsl:when test="parent::cluster">
                        <div class="cluster">
                            <xsl:apply-templates
                                select="document(concat($staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml'))//tei:TEI" mode="editorial"/>
                            <xsl:message>
                                <xsl:value-of select="concat('file: ',$staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml')"/>
                            </xsl:message>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates
                            select="document(concat($staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml'))//tei:TEI" mode="editorial"/>
                        <xsl:message>
                            <xsl:value-of select="concat('file: ',$staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml')"/>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="parent::cluster">
                        <div class="cluster">
                            <xsl:apply-templates
                                select="document(concat($staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml'))//tei:TEI"/>
                            <xsl:message>
                                <xsl:value-of select="concat('file: ',$staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml')"/>
                            </xsl:message>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates
                            select="document(concat($staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml'))//tei:TEI"/>
                        <xsl:message>
                            <xsl:value-of select="concat('file: ',$staticPublishingPath,normalize-space(@id),'/',normalize-space(@id),'.xml')"/>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="list[@id='frontmatter']">
        <xsl:choose>
            <xsl:when test="ancestor::cluster">
                <div class="cluster">
                    <h3>Front Matter</h3>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <h2>Front Matter</h2>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="list[@id='editorials']">
        <xsl:choose>
            <xsl:when test="ancestor::cluster">
                <div class="cluster">
                    <h3>Editorials</h3>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <h2>Editorials</h2>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

   <xsl:template match="list[@id='field_reports']">                                                                                       
        <xsl:choose>                                                                                                                    
            <xsl:when test="ancestor::cluster">                                                                                         
                <div class="cluster">                                                                                                   
                    <h3>Field Reports</h3>
                    <xsl:apply-templates/>                                                                                              
                </div>                                                                                                                  
            </xsl:when>                                                                                                                 
            <xsl:otherwise>                                                                                                             
                <h2>Field Reports</h2>
                <xsl:apply-templates/>                                                                                                  
            </xsl:otherwise>                                                                                                            
        </xsl:choose>                                                                                                                   
    </xsl:template>            

  <xsl:template match="list[@id='case_studies']">
    <xsl:choose>
      <xsl:when test="ancestor::cluster">
        <div class="cluster">
          <h3>Case Studies</h3>
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <h2>Case Studies</h2>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <xsl:template match="list[@id='articles']">
        <xsl:choose>
            <xsl:when test="ancestor::cluster">
                <div class="cluster">
                	<xsl:if test="not(title)">
                    <h3>Articles</h3>
                    </xsl:if>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <h2>Articles</h2>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="list[@id='issues']">
        <xsl:choose>
            <xsl:when test="ancestor::cluster">
                <div class="cluster">
                    <h3>Issues in Digital Humanities</h3>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <h2>Issues in Digital Humanities</h2>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="list[@id='reviews']">
        <xsl:choose>
            <xsl:when test="ancestor::cluster">
                <div class="cluster">
                    <h3>Reviews</h3>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <h2>Reviews</h2>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="list[@id='posters']">
        <xsl:choose>
            <xsl:when test="ancestor::cluster">
                <div class="cluster">
                    <h3>Posters</h3>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <h2>Posters</h2>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="specialTitle">
        <h1>
            <xsl:apply-templates/>
        </h1>
    </xsl:template>

    <xsl:template match="title">
        <xsl:choose>
        	<xsl:when test="parent::list[@id='articles'] and ancestor::cluster">
        		<h3>
        			<xsl:apply-templates/>
        		</h3>
			</xsl:when>
            <xsl:when test="ancestor::cluster">
                <h2>
                    <xsl:apply-templates/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h1>
                    <xsl:apply-templates/>
                    <xsl:choose>
                        <xsl:when test="ancestor::journal[@preview]">
                            <xsl:value-of select="concat(' ',ancestor::journal[@preview]/@vol,'.',ancestor::journal[@preview]/@issue)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(' ',$vol,'.',$issue)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h1>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="editors">
        <xsl:choose>
            <xsl:when test="ancestor::cluster">
                <div class="cluster">
                    <h3>
                        <xsl:choose><xsl:when test="@n='1'">Editor: </xsl:when><xsl:otherwise>Editors: </xsl:otherwise></xsl:choose>
                        <xsl:apply-templates/>
                    </h3>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <h2>
                    <xsl:choose><xsl:when test="@n='1'">Editor: </xsl:when><xsl:otherwise>Editors: </xsl:otherwise></xsl:choose>
                    <xsl:apply-templates/>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="index_main_body">
        <div id="toc">
            <xsl:apply-templates select="toc/journal[@vol=$vol and @issue=$issue]"/>

            <h2>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/vol/',$vol,'/',$issue,'/','bios.html')"/>
                    </xsl:attribute>
                    <xsl:value-of select="'Author Biographies'"/>
                </a>
            </h2>

        </div>
    </xsl:template>

    <xsl:template name="index_main_body_preview">
        <div id="toc">
            <xsl:apply-templates select="toc/journal[@preview]"/>

            <h2>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/preview/bios.html')"/>
                    </xsl:attribute>
                    <xsl:value-of select="'Author Biographies'"/>
                </a>
            </h2>

        </div>
    </xsl:template>

    <xsl:template name="index_main_body_editorial">
        <div id="toc">
            <xsl:apply-templates select="toc/journal[@editorial]"/>

            <h2>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/editorial/bios.html')"/>
                    </xsl:attribute>
                    <xsl:value-of select="'Author Biographies'"/>
                </a>
            </h2>

        </div>
    </xsl:template>

    <xsl:template match="tei:TEI">
        <xsl:param name="id">
            <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id'])"/>
        </xsl:param>
        <div class="articleInfo" style="margin:0 0 1em 0;">
	        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
                <xsl:if test="position() > 1"><br/></xsl:if>
                <xsl:choose>
                    <xsl:when test="not(@xml:lang) or @xml:lang='en' or string-length(@xml:lang)=0">
						<!--
                        <xsl:if test="//tei:title/@xml:lang != 'en'">
                        <span class="monospace">[en]&#160;</span>
                        </xsl:if>
                        -->

                        <span class="monospace">[en]&#160;</span>

                    </xsl:when>
                    <xsl:otherwise>
                        <span class="monospace">[<xsl:value-of select="@xml:lang"/>]&#160;</span>
                    </xsl:otherwise>
                </xsl:choose>
		        <xsl:element name="a">
		            <xsl:attribute name="href">
		                <xsl:value-of select="concat('/',$context,'/vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/>
		            </xsl:attribute>
                    <xsl:if test="//tei:title/@xml:lang != 'en'">
                        <xsl:attribute name="onclick">
                            <xsl:value-of select="concat('localStorage.setItem(', $apos, 'pagelang', $apos, ', ', $apos, @xml:lang, $apos, ');')"/>
                        </xsl:attribute>
                    </xsl:if>
		            <xsl:apply-templates select="."/>
		        </xsl:element>
            </xsl:for-each>

          <div style="padding-left:1em; margin:0;text-indent:-1em;">
	        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
	            <xsl:value-of select="normalize-space(dhq:author_name)"/>
	            <xsl:if test="dhq:affiliation">
	                <xsl:value-of select="', '"/>
	            </xsl:if>
	            <xsl:value-of select="normalize-space(dhq:affiliation)"/>
	            <xsl:if test="not(position() = last())">
	                <xsl:value-of select="'; '"/>
	            </xsl:if>
	        </xsl:for-each>
        </div>
        <xsl:if test="//dhq:abstract/child::tei:p != ''">
            <span class="viewAbstract">Abstract
                <xsl:for-each select="//dhq:abstract">
                    <xsl:variable name="lang">
                        <xsl:value-of select="../../@xml:lang"/>
                    </xsl:variable>
                    <span class="viewAbstract monospace" style="display:inline">
                        <xsl:attribute name="id">
                            <xsl:value-of select="concat('abstractExpanderabstract',$id,$lang)"/>
                        </xsl:attribute>
                        <a title="View Abstract" class="expandCollapse monospace">
                            <xsl:choose>
                                <xsl:when test="$lang='en' or string-length($lang)=0">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('javascript:expandAbstract(',$apos,'abstract',$id,$lang,$apos,')')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="'[en]'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('javascript:expandAbstract(',$apos,'abstract',$id,$lang,$apos,')')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="concat('[', $lang, ']')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </span>
                </xsl:for-each>
                <xsl:for-each select="//dhq:abstract">
                    <xsl:variable name="lang">
                        <xsl:value-of select="../../@xml:lang"/>
                    </xsl:variable>
                    <span style="display:none" class="abstract">
                        <xsl:attribute name="id">
                            <xsl:value-of select="concat('abstract',$id,$lang)"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="."/>
                    </span>
                </xsl:for-each>
            </span>
        </xsl:if>
        <xsl:call-template name="coins"/> <!-- added by Saeed -->
      </div>
    </xsl:template>
    <!--Coins generation templates start here. Added by Saeed -->

    <xsl:template name="coins">
        <xsl:element name="span">
            <xsl:attribute name="class">Z3988</xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>url_ver=Z39.88-2004&amp;ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&amp;rfr_id=info%3Asid%2Fzotero.org%3A2&amp;rft.genre=article&amp;</xsl:text>
                <xsl:apply-templates mode="coins-data" select="//tei:fileDesc"/>
            </xsl:attribute>
            <xsl:text> </xsl:text>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:fileDesc" mode="coins-data">
        <xsl:param name="tei_title">
            <xsl:call-template name="clean_string">
                <xsl:with-param name="string" select="normalize-space(tei:titleStmt/tei:title[1])"/>
            </xsl:call-template>
        </xsl:param>
        <xsl:text>rft.atitle=</xsl:text>
        <xsl:value-of select="$tei_title"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.jtitle=Digital%20Humanities%20Quarterly&amp;rft.stitle=DHQ&amp;rft.issn=1938-4122&amp;</xsl:text>
        <xsl:text>rft.date=</xsl:text>
        <xsl:value-of select="tei:publicationStmt/tei:date/@when"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.volume=</xsl:text>
        <xsl:value-of select="tei:publicationStmt/tei:idno[@type='volume']"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.issue=</xsl:text>
        <xsl:value-of select="tei:publicationStmt/tei:idno[@type='issue']"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.aulast=</xsl:text>
        <!-- First author's last name http://ocoins.info/cobg.html -->
        <xsl:value-of
            select="normalize-space(tei:titleStmt/dhq:authorInfo[1]/dhq:author_name/dhq:family)"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:text>rft.aufirst=</xsl:text>
        <!-- First author's first name  -->
        <xsl:value-of
            select="normalize-space(tei:titleStmt/dhq:authorInfo[1]/dhq:author_name/text()[1])"/>
        <xsl:text>&amp;</xsl:text>
        <xsl:for-each select="tei:titleStmt/dhq:authorInfo">
            <!-- All Authors' names -->
            <xsl:text>rft.au=</xsl:text>
	<!-- line below breaks if there is are two text nodes in dhq:author_name, for instance from white space after dhq:family. So I added [1] after text() -->
            <xsl:value-of select="normalize-space(dhq:author_name/text()[1])"/>%20<xsl:value-of
                select="normalize-space(dhq:author_name/dhq:family)"/>
            <xsl:if test="not(position() = last())">
                <xsl:text>&amp;</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!-- The search and replace code is borrowed from O'Reilly's XSLT cookbook -->
    <xsl:template name="search_and_replace">
        <xsl:param name="input"/>
        <xsl:param name="search-string"/>
        <xsl:param name="replace-string"/>
        <xsl:choose>
            <xsl:when test="$search-string and
                contains($input,$search-string)">
                <xsl:value-of select="substring-before($input,$search-string)"/>
                <xsl:value-of select="$replace-string"/>
                <xsl:call-template name="search_and_replace">
                    <xsl:with-param name="input" select="substring-after($input,$search-string)"/>
                    <xsl:with-param name="search-string" select="$search-string"/>
                    <xsl:with-param name="replace-string" select="$replace-string"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="clean_string">
        <xsl:param name="string"/>
        <xsl:choose>
            <xsl:when test="contains($string,' ')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="' '"/>
                            <xsl:with-param name="replace-string" select="'%20'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,':')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="':'"/>
                            <xsl:with-param name="replace-string" select="'%3A'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'’')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'’'"/>
                            <xsl:with-param name="replace-string" select="'%E2%80%99'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'#')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'#'"/>
                            <xsl:with-param name="replace-string" select="'%23'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="contains($string,'&amp;')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'&amp;'"/>
                            <xsl:with-param name="replace-string" select="'%26'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'+')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'+'"/>
                            <xsl:with-param name="replace-string" select="'%2B'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'/')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'/'"/>
                            <xsl:with-param name="replace-string" select="'%2F'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'&lt;')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'&lt;'"/>
                            <xsl:with-param name="replace-string" select="'%3C'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'=')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'='"/>
                            <xsl:with-param name="replace-string" select="'%3D'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'&gt;')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'&gt;'"/>
                            <xsl:with-param name="replace-string" select="'%3E'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($string,'?')">
                <xsl:call-template name="clean_string">
                    <xsl:with-param name="string">
                        <xsl:call-template name="search_and_replace">
                            <xsl:with-param name="input" select="$string"/>
                            <xsl:with-param name="search-string" select="'?'"/>
                            <xsl:with-param name="replace-string" select="'%3F'"/>
                        </xsl:call-template>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Coins generation templates end here. By Saeed-->

    <xsl:template match="tei:TEI" mode="preview">
        <xsl:param name="vol">
            <xsl:value-of select="document('../../toc/toc.xml')//journal[@preview]/@vol"/>
        </xsl:param>
        <xsl:param name="issue">
            <xsl:value-of select="document('../../toc/toc.xml')//journal[@preview]/@issue"/>
        </xsl:param>
        <xsl:param name="id">
            <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id'])"/>
        </xsl:param>
        <div class="authorInfo" style="margin:0 0 1em 0;">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
                <xsl:if test="position() > 1"><br/></xsl:if>
                <xsl:choose>
                    <xsl:when test="@xml:lang='en' or string-length(@xml:lang)=0">

                        <xsl:if test="//tei:title/@xml:lang != 'en'">
                        <span class="monospace">[en]&#160;</span>
                        </xsl:if>
                        <!--
                        <span class="monospace">[en]</span>
                        -->
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="monospace">[<xsl:value-of select="@xml:lang"/>]&#160;</span>
                    </xsl:otherwise>
                </xsl:choose>
		        <xsl:element name="a">
                <xsl:choose>
                    <xsl:when test="$vol">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/vol/',$vol,'/',$issue,'/',$id,'/',$id,'.html')"/>
                        </xsl:attribute>
                        <xsl:if test="//tei:title/@xml:lang != 'en'">
                        <xsl:attribute name="onclick">
                            <xsl:value-of select="concat('localStorage.setItem(', $apos, 'pagelang', $apos, ', ', $apos, @xml:lang, $apos, ');')"/>
                        </xsl:attribute>
                    </xsl:if>
                        <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/preview/',$id,'.html')"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
            </xsl:for-each>

            <div style="padding-left:1em; margin:0;text-indent:-1em;">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                <xsl:value-of select="normalize-space(dhq:author_name)"/>
                <xsl:if test="child::dhq:affiliation">
                    <xsl:value-of select="', '"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(dhq:affiliation)"/>
                <xsl:if test="not(position() = last())">
                    <xsl:value-of select="'; '"/>
                </xsl:if>
            </xsl:for-each>
          </div>
        <xsl:if test="//dhq:abstract/child::tei:p != ''">
            <span class="viewAbstract">Abstract&#160;
                <xsl:for-each select="//dhq:abstract">
                    <xsl:variable name="lang">
                        <xsl:value-of select="../../@xml:lang"/>
                    </xsl:variable>
                    <span class="viewAbstract monospace" style="display:inline">
                        <xsl:attribute name="id">
                            <xsl:value-of select="concat('abstractExpanderabstract',$id,$lang)"/>
                        </xsl:attribute>
                        <span class="monospace"><a title="View Abstract" class="expandCollapse monospace">
                            <xsl:choose>
                                <xsl:when test="$lang='en' or string-length($lang)=0">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('javascript:expandAbstract(',$apos,'abstract',$id,$lang,$apos,')')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="'[en]'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('javascript:expandAbstract(',$apos,'abstract',$id,$lang,$apos,')')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="concat('[', $lang, ']')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a></span>
                    </span>
                </xsl:for-each>
                <xsl:for-each select="//dhq:abstract">
                    <xsl:variable name="lang">
                        <xsl:value-of select="../../@xml:lang"/>
                    </xsl:variable>
                    <span style="display:none" class="abstract">
                        <xsl:attribute name="id">
                            <xsl:value-of select="concat('abstract',$id,$lang)"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="."/>
                    </span>
                </xsl:for-each>
            </span>
        </xsl:if>
        <xsl:call-template name="coins"/> <!-- added by Saeed -->
      </div>
    </xsl:template>

    <xsl:template match="tei:TEI" mode="editorial">

        <xsl:param name="id">
            <xsl:value-of select="normalize-space(tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='DHQarticle-id'])"/>
        </xsl:param>
        <div class="articleInfo" style="margin:0 0 1em 0;">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
                <xsl:if test="position() > 1"><br/></xsl:if>
                <xsl:choose>
                    <xsl:when test="@xml:lang='en' or string-length(@xml:lang)=0">

                        <xsl:if test="//tei:title/@xml:lang != 'en'">
                        <span class="monospace">[en]&#160;</span>
                        </xsl:if>
                        <!--
                        <span class="monospace">[en]</span>
                        -->
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="monospace">[<xsl:value-of select="@xml:lang"/>]&#160;</span>
                    </xsl:otherwise>
                </xsl:choose>
		        <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('/',$context,'/editorial/',$id,'/',$id,'.html')"/>
                    </xsl:attribute>
                    <xsl:if test="//tei:title/@xml:lang != 'en'">
                        <xsl:attribute name="onclick">
                            <xsl:value-of select="concat('localStorage.setItem(', $apos, 'pagelang', $apos, ', ', $apos, @xml:lang, $apos, ');')"/>
                        </xsl:attribute>
                    </xsl:if>
		            <xsl:apply-templates select="."/>
		        </xsl:element>
            </xsl:for-each>
            <div style="padding-left:1em; margin:0;text-indent:-1em;">
            <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
                <xsl:value-of select="normalize-space(dhq:author_name)"/>
                <xsl:if test="child::dhq:affiliation">
                    <xsl:value-of select="', '"/>
                </xsl:if>
                <xsl:value-of select="normalize-space(dhq:affiliation)"/>
                <xsl:if test="not(position() = last())">
                    <xsl:value-of select="'; '"/>
                </xsl:if>
            </xsl:for-each>
          </div>
        <xsl:if test="//dhq:abstract/child::tei:p != ''">
            <span class="viewAbstract">Abstract
            <xsl:for-each select="//dhq:abstract">
                <xsl:variable name="lang">
                    <xsl:value-of select="../../@xml:lang"/>
                </xsl:variable>
                <span class="viewAbstract monospace" style="display:inline">
                    <xsl:attribute name="id">
                        <xsl:value-of select="concat('abstractExpanderabstract',$id,$lang)"/>
                    </xsl:attribute>
                    <span class="monospace"><a title="View Abstract" class="expandCollapse monospace">
                        <xsl:choose>
                            <xsl:when test="$lang='en' or string-length($lang)=0">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat('javascript:expandAbstract(',$apos,'abstract',$id,$lang,$apos,')')"/>
                                </xsl:attribute>
                                <xsl:value-of select="'[en]'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat('javascript:expandAbstract(',$apos,'abstract',$id,$lang,$apos,')')"/>
                                </xsl:attribute>
                                <xsl:value-of select="concat('[', $lang, ']')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a></span>
                </span>
            </xsl:for-each>
            <xsl:for-each select="//dhq:abstract">
                <xsl:variable name="lang">
                    <xsl:value-of select="../../@xml:lang"/>
                </xsl:variable>
                <span style="display:none" class="abstract">
                    <xsl:attribute name="id">
                        <xsl:value-of select="concat('abstract',$id,$lang)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="."/>
                </span>
            </xsl:for-each>
            </span>
        </xsl:if>
        <xsl:call-template name="coins"/> <!-- added by Saeed -->
      </div>
   </xsl:template>

    <xsl:template match="dhq:note"/>

    <xsl:template match="dhq:authorInfo/dhq:author_name">
        <xsl:apply-templates/>
        <xsl:if test="following-sibling::dhq:affiliation">
            <xsl:value-of select="', '"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="dhq:authorInfo/dhq:affiliation">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <xsl:template match="dhq:authorInfo/dhq:address|dhq:authorInfo/tei:email|tei:teiHeader/tei:fileDesc/tei:publicationStmt"/>

    <!-- Templates added from dhq2html to support rend-ing (e.g. italics, quotes) [CRB] -->

    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:title">
        <cite>
            <xsl:call-template name="rend"/>
            <xsl:apply-templates/>
        </cite>
    </xsl:template>

    <xsl:template match="tei:quote[@rend = 'inline']|tei:called|tei:title[@rend = 'quotes']|tei:q|tei:said|tei:soCalled">
      <xsl:call-template name="quotes"/>
    </xsl:template>
  
    <!-- Copied verbatim from dhq2html.xsl -->
    <!-- returns a pair of quote marks appropriate to the language and nesting level -->
    <xsl:function name="dhq:quotes" as="xs:string+">
      <xsl:param name="who" as="node()"/>
      <!-- $langspec is either $who's nearest ancestor w/ xml:lang, or the root element if no @xml:lang is found.
       The point of $langspec is *only* to determine the scope of counting levels. -->
      <xsl:variable name="langspec" select="$who/ancestor-or-self::*[exists(@xml:lang)][last()]"/>
      <!-- $nominal-lang is the value of xml:lang given ('fr','de','jp' etc etc.) or 'en' if none is found (with deference) -->
      <xsl:variable name="nominal-lang" select="if (exists($langspec)) then ($langspec/@xml:lang) else 'en'"/>
      
      <!-- $levels are counted among (inline) ancestors that 'toggle' quotes. -->
      <!-- An intervening $langspec has the effect of turning levels off. So a French quote inside an English
           quote restarts with guillemets, while an English quote inside French restarts with double quote. -->
      <!-- Note in this implementation, we exploit the overlapping requirement between French and English to optimize.
           More languages may require more logic. -->
      
      <!--tei:quote[@rend = 'inline']|tei:called|tei:title[@rend = 'quotes']|tei:q|tei:said|tei:soCalled-->
      <xsl:variable name="scope" select="($langspec | $who/ancestor-or-self::tei:note)[last()]"/>
      <xsl:variable name="levels" select="$who/(ancestor::tei:quote[@rend='inline'] |
        ancestor::tei:called | ancestor::soCalled |
        ancestor::tei:q | ancestor::said |
        ancestor::tei:title[@rend='quotes'])[ancestor-or-self::* intersect $scope]"/>
      <!-- $level-count is 0 for an outermost quote; we increment it unless the language is French -->
      <xsl:variable name="level-count" select="count($levels) + (if (starts-with($nominal-lang,'fr')) then 0 else 1) "/>
      <!-- Now level 0 gets guillemet, while odd-numbered levels get double quotes -->
      <xsl:choose>
        <!-- Note we emit pairs of xsl:text b/c we actually want discrete strings, returning a pair -->
        <xsl:when test="$level-count = 0">
          <xsl:text>«</xsl:text>
          <xsl:text>»</xsl:text>
        </xsl:when>
        <xsl:when test="$level-count mod 2 (: odds :)">
          <xsl:text>“</xsl:text>
          <xsl:text>”</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>‘</xsl:text>
          <xsl:text>’</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:function>
    
    
    <xsl:template name="quotes">
      <xsl:param name="contents">
        <xsl:apply-templates/>
      </xsl:param>
      <xsl:variable name="quote-marks" select="dhq:quotes(.)"/>
      <xsl:sequence select="$quote-marks[1]"/>
      <xsl:copy-of select="$contents"/>
      <xsl:sequence select="$quote-marks[2]"/>
    </xsl:template>
    
    <xsl:template name="rend">
        <xsl:param name="defaultRend"/>
        <xsl:choose>
            <xsl:when test="@rend and @rend != ''">
                <xsl:attribute name="class">
                    <xsl:choose>
                        <xsl:when test="$defaultRend != '' and @rend != 'none'">
                            <xsl:value-of select="concat($defaultRend,' ',@rend)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@rend"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>

                <xsl:if test="$defaultRend !=''">
                    <xsl:attribute name="class">
                        <xsl:value-of select="$defaultRend"/>
                    </xsl:attribute>

                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
