<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- Taken from 
        https://github.com/daisy-consortium/pipeline-modules-common/blob/master/file-utils/src/main/resources/xml/xslt/uri-functions.xsl 
    -->
    
    <xsl:function name="dhq:decodeURL">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:variable name="cp-base" select="string-to-codepoints('0A')" as="xs:integer+"/>
        <xsl:variable name="result">
            
            <xsl:analyze-string select="$string" regex="(%[0-9A-F]{{2}})+" flags="i">
                <xsl:matching-substring>
                    <xsl:variable name="utf8-bytes" as="xs:integer+">
                        <xsl:analyze-string select="." regex="%([0-9A-F]{{2}})" flags="i">
                            <xsl:matching-substring>
                                <xsl:variable name="nibble-pair"
                                    select="
                                    for $nibble-char in string-to-codepoints( upper-case(regex-group(1))) return
                                    if ($nibble-char ge $cp-base[2]) then
                                    $nibble-char - $cp-base[2] + 10
                                    else
                                    $nibble-char - $cp-base[1]"
                                    as="xs:integer+"/>
                                <xsl:sequence select="$nibble-pair[1] * 16 + $nibble-pair[2]"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                    <xsl:value-of select="codepoints-to-string( dhq:utf8-decode( $utf8-bytes))"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:sequence select="string($result)"/>
    </xsl:function>
    <xsl:function name="dhq:utf8-decode">
        <xsl:param name="bytes" as="xs:integer*"/>
        <xsl:choose>
            <xsl:when test="empty($bytes)"/>
            <xsl:when test="$bytes[1] eq 0">
                <!-- The null character is not valid for XML. -->
                <xsl:sequence select="dhq:utf8-decode( remove( $bytes, 1))"/>
            </xsl:when>
            <xsl:when test="$bytes[1] le 127">
                <xsl:sequence select="$bytes[1], dhq:utf8-decode( remove( $bytes, 1))"/>
            </xsl:when>
            <xsl:when test="$bytes[1] lt 224">
                <xsl:sequence select="
                    ((($bytes[1] - 192) * 64) +
                    ($bytes[2] - 128)        ),
                    dhq:utf8-decode( remove( remove( $bytes, 1), 1))"/>
            </xsl:when>
            <xsl:when test="$bytes[1] lt 240">
                <xsl:sequence
                    select="
                    ((($bytes[1] - 224) * 4096) +
                    (($bytes[2] - 128) *   64) +
                    ($bytes[3] - 128)          ),
                    dhq:utf8-decode( remove( remove( remove( $bytes, 1), 1), 1))"
                />
            </xsl:when>
            <xsl:when test="$bytes[1] lt 248">
                <xsl:sequence
                    select="
                    ((($bytes[1] - 224) * 262144) +
                    (($bytes[2] - 128) *   4096) +
                    (($bytes[3] - 128) *     64) +
                    ($bytes[4] - 128)            ),
                    dhq:utf8-decode( $bytes[position() gt 4])"
                />
            </xsl:when>
            <xsl:otherwise>
                <!-- Code-point valid for XML. -->
                <xsl:sequence select="dhq:utf8-decode( remove( $bytes, 1))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>