<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
    version     = "1.0"
    xmlns:xsl   = "http://www.w3.org/1999/XSL/Transform"
    xmlns:ltx   = "http://dlmf.nist.gov/LaTeXML"
    xmlns:func  = "http://exslt.org/functions"
    xmlns:f     = "http://dlmf.nist.gov/LaTeXML/functions"
    extension-element-prefixes="func f"
    exclude-result-prefixes = "ltx func f">

    <xsl:template match="ltx:graphics[substring(f:url(@imagesrc),string-length(@imagesrc)-2,3) = 'svg']">
    <xsl:element name="object" namespace="{$html_ns}">
      <xsl:attribute name="data"><xsl:value-of select="f:url(@imagesrc)"/></xsl:attribute>
      <xsl:call-template name="add_id"/>
      <xsl:call-template name="add_attributes">
        <xsl:with-param name="extra_style">
          <xsl:if test="@imagedepth">
            <xsl:value-of select="concat('vertical-align:-',@imagedepth,'px')"/>
          </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:if test="@imagewidth">
        <xsl:attribute name='width'>
          <xsl:value-of select="@imagewidth"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@imageheight">
        <xsl:attribute name='height'>
          <xsl:value-of select="@imageheight"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@description">
          <xsl:attribute name='alt'>
            <xsl:value-of select="@description"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="../ltx:figure/ltx:caption">
          <xsl:attribute name='alt'>
            <xsl:value-of select="../ltx:figure/ltx:caption/text()"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name='alt'></xsl:attribute> <!--required; what else? -->
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="." mode="begin"/>
      <xsl:apply-templates select="." mode="end"/>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
