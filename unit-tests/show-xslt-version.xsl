<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:template match="/">
        <results>
            <system-property-version>
                <xsl:value-of select="system-property('xsl:version')"/>
            </system-property-version>
            <system-property-vendor>
                <xsl:value-of select="system-property('xsl:vendor')"/>
            </system-property-vendor>
            <system-property-vendor-url>
                <xsl:value-of select="system-property('xsl:vendor-url')"/>
            </system-property-vendor-url>
        </results>
    </xsl:template>
</xsl:stylesheet>
