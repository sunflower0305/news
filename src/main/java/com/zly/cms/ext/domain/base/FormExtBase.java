package com.zly.cms.ext.domain.base;

import io.swagger.v3.oas.annotations.media.Schema;
import java.io.Serializable;
import javax.validation.constraints.NotNull;
import org.springframework.lang.Nullable;

/**
 * This class was generated by MyBatis Generator.
 *
 * @author MyBatis Generator
 */
public class FormExtBase implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 数据库表名
     */
    public static final String TABLE_NAME = "form_ext";

    /**
     * 表单扩展ID
     */
    @NotNull
    @Schema(description="表单扩展ID")
    private Long id = 0L;

    /**
     * 自定义大字段
     */
    @Nullable
    @Schema(description="自定义大字段")
    private String clobsJson;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    @Nullable
    public String getClobsJson() {
        return clobsJson;
    }

    public void setClobsJson(@Nullable String clobsJson) {
        this.clobsJson = clobsJson;
    }
}