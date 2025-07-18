package com.zly.cms.core.mapper;

import com.zly.cms.core.domain.ShortMessage;
import com.zly.commons.query.QueryInfo;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Repository;

/**
 * 短信 Mapper
 *
 * @author PONY
 */
@Mapper
@Repository
public interface ShortMessageMapper {
    /**
     * 插入数据
     *
     * @param bean 实体对象
     * @return 插入条数
     */
    int insert(ShortMessage bean);

    /**
     * 更新数据
     *
     * @param bean 实体对象
     * @return 更新条数
     */
    int update(ShortMessage bean);

    /**
     * 删除数据
     *
     * @param id 主键ID
     * @return 删除条数
     */
    int delete(Long id);

    /**
     * 根据主键获取数据
     *
     * @param id 主键ID
     * @return 实体对象。没有找到数据，则返回 {@code null}
     */
    @Nullable
    ShortMessage select(Long id);

    /**
     * 根据查询条件获取列表
     *
     * @param queryInfo 查询条件
     * @return 数据列表
     */
    List<ShortMessage> selectAll(@Nullable @Param("queryInfo") QueryInfo queryInfo);
}