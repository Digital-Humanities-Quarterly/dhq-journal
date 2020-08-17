<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"  
    exclude-result-prefixes="tei dhq" version="1.0">
    <xsl:param name="vol"><xsl:value-of select="toc/journal[@current]/@vol"/></xsl:param>
    <xsl:param name="issue"><xsl:value-of select="toc/journal[@current]/@issue"/></xsl:param>
    <xsl:param name="staticPublishingPath">
        <xsl:value-of select="'../../articles/'"/>
    </xsl:param>
    <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    
    
    <xsl:template name="index_main_body" match="/">
        <div id="bios">
            <xsl:for-each select="toc/journal[@vol=$vol and @issue=$issue]//cluster/item">
                <xsl:apply-templates
                    select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//tei:TEI"/>
            </xsl:for-each>
            <xsl:for-each select="toc/journal[@vol=$vol and @issue=$issue]//list/item">
                <xsl:apply-templates
                    select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//tei:TEI"/>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template name="index_main_body_preview" match="/">
        <div id="bios">
            <xsl:for-each select="toc/journal[@preview]//cluster/item">
                <xsl:apply-templates
                    select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//tei:TEI"/>
            </xsl:for-each>
            <xsl:for-each select="toc/journal[@preview]//list/item">
                <xsl:apply-templates
                    select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//tei:TEI"/>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template name="index_main_body_editorial" match="/">
        <div id="bios">
            <xsl:for-each select="toc/journal[@editorial]//cluster/item">
                <xsl:apply-templates
                    select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//tei:TEI"/>
            </xsl:for-each>
            <xsl:for-each select="toc/journal[@editorial]//list/item">
                <xsl:apply-templates
                    select="document(concat($staticPublishingPath,@id,'/',@id,'.xml'))//tei:TEI"/>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:TEI">
        <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo|tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:translatorInfo">
            <xsl:apply-templates select="dhq:author_name|dhq:translator_name"/>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="dhq:author_name|dhq:translator_name">
        <div>
            <xsl:attribute name="id">
                <!-- Using lower-case of author's last name + first initial to sort [CRB] -->
                	<!-- <xsl:value-of select="translate(concat(translate(./dhq:family,' ',''),'_',substring(normalize-space(.),1,3)),$upper,$lower)"/> -->
                <!-- jawalsh: We had two authors with same first last name and same first initial, so bio didn't link correctly. Replaced commented line above, with code below. Now the full name (with spaces replaced by _ are used for ids). See also dhq2html.xsl where a similar change was made.-->
                <!-- <xsl:value-of select="translate(concat(translate(./dhq:family,' ',''),'_',translate(normalize-space(./text()),' ','_')),$upper,$lower)"/> -->
                
                <xsl:value-of
      select="lower-case(concat(
        replace(./dhq:family,'\s',''),
        '_',
        replace(normalize-space(string-join(./text(),'')),'\s','_') ) )"/>
            </xsl:attribute>
            <strong>
                <xsl:value-of select="normalize-space(.)"/>
            </strong>
            <xsl:apply-templates select="../dhq:bio"/>
        </div>
    </xsl:template>
    
    <xsl:template match="dhq:bio">
        <xsl:choose>
            <xsl:when test="tei:p">
                <xsl:for-each select="tei:p">
                    <xsl:choose>
                        <xsl:when test="position() = 1"><xsl:text> </xsl:text><xsl:apply-templates/></xsl:when>
                        <xsl:otherwise><p><xsl:apply-templates/></p></xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:title">
        <xsl:param name="defaultRend"/>
        <xsl:choose>
            <!-- Added support for rendering quotations marks for titles,
                since IE < 8 does not support CSS pseudo entities ::before,::after [CRB] -->
            <xsl:when test="@rend = 'quotes'">
                <xsl:call-template name="quotes">
                    <xsl:with-param name="contents">
                        <xsl:apply-templates/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@rend and @rend != ''">
                <span>
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="$defaultRend != ''">
                                <xsl:value-of select="concat($defaultRend,' ',@rend)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@rend"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                
                <xsl:if test="$defaultRend !=''">
                    <span>
                        <xsl:attribute name="class">
                            <xsl:value-of select="$defaultRend"/>
                        </xsl:attribute>
                        <xsl:apply-templates/>
                    </span> 
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="quotes">
        <xsl:param name="contents">
            <xsl:apply-templates/>
        </xsl:param>
        <xsl:variable name="level">
            <xsl:value-of select="count(ancestor::tei:quote[@rend='inline'] |
                ancestor::tei:called |
                ancestor::tei:q |
                ancestor::tei:title[@rend='quotes'])"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$level mod 2">
                <xsl:text>&apos;</xsl:text>
                <xsl:copy-of select="$contents"/>
                <xsl:text>&apos;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&quot;</xsl:text>
                <xsl:copy-of select="$contents"/>
                <xsl:text>&quot;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:ref">
        <xsl:variable name="target">
            <xsl:value-of select="@target"/>
        </xsl:variable>
        <!-- added by Ashwini -->
        <!-- creating string for opening a function that opens a new window -->
        <xsl:variable name="jslink1">
            <xsl:text>window.open(&apos;</xsl:text>            
        </xsl:variable>
        <xsl:variable name="jslink2">
            <xsl:text>&apos;); return false</xsl:text>
        </xsl:variable>
        <!-- end of addition by Ashwini -->
        <a>
            <xsl:call-template name="id"/>
            <xsl:call-template name="rend"/>
            <xsl:attribute name="href">
                <xsl:value-of select="$target"/>
            </xsl:attribute>
            <!-- added by Ashwini -->            
            <xsl:attribute name="onclick">
                <xsl:value-of select="concat($jslink1,$target,$jslink2)"/>
            </xsl:attribute>
            <!-- end of addition by ashwini -->
            
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <xsl:template name="id">
        <xsl:if test="@xml:id">
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
        </xsl:if>
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
