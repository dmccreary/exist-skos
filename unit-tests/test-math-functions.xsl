<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:math="http://exslt.org/math"
    version="1.0">
    <xsl:template match="/">
        <results>
            <log1><xsl:value-of select="math:log(1)"/></log1>
            <sin1><xsl:value-of select="math:sin(1)"/></sin1>
            <cos1><xsl:value-of select="math:cos(1)"/></cos1>
        </results>
    </xsl:template>
</xsl:stylesheet>