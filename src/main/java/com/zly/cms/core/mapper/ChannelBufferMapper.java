package com.zly.cms.core.mapper;

import com.zly.cms.core.domain.ChannelBuffer;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 栏目缓冲 Mapper
 *
 * @author PONY
 */
@Mapper
@Repository
public interface ChannelBufferMapper {
    /**
     * 更新数据
     *
     * @param bean 实体对象
     * @return 更新条数
     */
    int update(ChannelBuffer bean);

    /**
     * 根据主键获取数据
     *
     * @param id 主键ID
     * @return 实体对象。没有找到数据，则返回 {@code null}
     */
    @Nullable
    ChannelBuffer select(Integer id);

    /**
     * 批量更新浏览次数
     *
     * @param list 待更新列表
     * @return 更新条数
     */
    int updateBatch(List<ChannelBuffer> list);
}