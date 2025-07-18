package com.zly.cms.core.domain.base;

import io.swagger.v3.oas.annotations.media.Schema;
import java.io.Serializable;
import javax.validation.constraints.NotNull;
import org.springframework.lang.Nullable;

/**
 * This class was generated by MyBatis Generator.
 *
 * @author MyBatis Generator
 */
public class OrgChannelBase implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 数据库表名
     */
    public static final String TABLE_NAME = "org_channel";

    @NotNull
    private Long orgId = 0L;

    @NotNull
    private Long channelId = 0L;

    @Nullable
    private Long siteId;

    public Long getOrgId() {
        return orgId;
    }

    public void setOrgId(Long orgId) {
        this.orgId = orgId;
    }

    public Long getChannelId() {
        return channelId;
    }

    public void setChannelId(Long channelId) {
        this.channelId = channelId;
    }

    @Nullable
    public Long getSiteId() {
        return siteId;
    }

    public void setSiteId(@Nullable Long siteId) {
        this.siteId = siteId;
    }
}