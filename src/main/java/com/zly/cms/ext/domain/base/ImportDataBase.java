package com.zly.cms.ext.domain.base;

import io.swagger.v3.oas.annotations.media.Schema;
import java.io.Serializable;
import javax.validation.constraints.NotNull;
import org.hibernate.validator.constraints.Length;
import org.springframework.lang.Nullable;

/**
 * This class was generated by MyBatis Generator.
 *
 * @author MyBatis Generator
 */
public class ImportDataBase implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
     * 数据库表名
     */
    public static final String TABLE_NAME = "import_data";

    /**
     * 导入数据ID
     */
    @NotNull
    @Schema(description="导入数据ID")
    private Long id = 0L;

    /**
     * 表名
     */
    @Length(max = 255)
    @NotNull
    @Schema(description="表名")
    private String tableName = "";

    /**
     * 当前主键值
     */
    @Length(max = 255)
    @NotNull
    @Schema(description="当前主键值")
    private String currentId = "";

    /**
     * 原主键值
     */
    @Length(max = 255)
    @NotNull
    @Schema(description="原主键值")
    private String origId = "";

    /**
     * 原上级主键值
     */
    @Length(max = 255)
    @Nullable
    @Schema(description="原上级主键值")
    private String origParentId;

    /**
     * 类型(1:数据迁移,2:站点导入)
     */
    @NotNull
    @Schema(description="类型(1:数据迁移,2:站点导入)")
    private Short type = 1;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTableName() {
        return tableName;
    }

    public void setTableName(String tableName) {
        this.tableName = tableName;
    }

    public String getCurrentId() {
        return currentId;
    }

    public void setCurrentId(String currentId) {
        this.currentId = currentId;
    }

    public String getOrigId() {
        return origId;
    }

    public void setOrigId(String origId) {
        this.origId = origId;
    }

    @Nullable
    public String getOrigParentId() {
        return origParentId;
    }

    public void setOrigParentId(@Nullable String origParentId) {
        this.origParentId = origParentId;
    }

    public Short getType() {
        return type;
    }

    public void setType(Short type) {
        this.type = type;
    }
}