package com.zly.cms.ext.domain.base;

import io.swagger.v3.oas.annotations.media.Schema;
import java.io.Serializable;
import javax.validation.constraints.NotNull;
import org.hibernate.validator.constraints.Length;

/**
 * This class was generated by MyBatis Generator.
 *
 * @author MyBatis Generator
 */
public class VisitPageBase implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 数据库表名
     */
    public static final String TABLE_NAME = "visit_page";

    /**
     * 访问_受访页面ID
     */
    @NotNull
    @Schema(description="访问_受访页面ID")
    private Long id = 0L;

    /**
     * 站点ID
     */
    @NotNull
    @Schema(description="站点ID")
    private Long siteId = 0L;

    /**
     * 受访URL
     */
    @Length(max = 255)
    @NotNull
    @Schema(description="受访URL")
    private String url = "";

    /**
     * 访问量
     */
    @NotNull
    @Schema(description="访问量")
    private Long pvCount = 0L;

    /**
     * 访客数
     */
    @NotNull
    @Schema(description="访客数")
    private Long uvCount = 0L;

    /**
     * IP数
     */
    @NotNull
    @Schema(description="IP数")
    private Long ipCount = 0L;

    /**
     * 统计日期(yyyyMMdd)
     */
    @Length(max = 8)
    @NotNull
    @Schema(description="统计日期(yyyyMMdd)")
    private String dateString = "";

    /**
     * 类型(1:访问地址,2:入口地址)
     */
    @NotNull
    @Schema(description="类型(1:访问地址,2:入口地址)")
    private Short type = 1;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getSiteId() {
        return siteId;
    }

    public void setSiteId(Long siteId) {
        this.siteId = siteId;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public Long getPvCount() {
        return pvCount;
    }

    public void setPvCount(Long pvCount) {
        this.pvCount = pvCount;
    }

    public Long getUvCount() {
        return uvCount;
    }

    public void setUvCount(Long uvCount) {
        this.uvCount = uvCount;
    }

    public Long getIpCount() {
        return ipCount;
    }

    public void setIpCount(Long ipCount) {
        this.ipCount = ipCount;
    }

    public String getDateString() {
        return dateString;
    }

    public void setDateString(String dateString) {
        this.dateString = dateString;
    }

    public Short getType() {
        return type;
    }

    public void setType(Short type) {
        this.type = type;
    }
}