package com.zly.cms.core.service;

import com.github.pagehelper.page.PageMethod;
import com.zly.cms.core.domain.BlockItem;
import com.zly.cms.core.domain.base.BlockItemBase;
import com.zly.cms.core.listener.ChannelDeleteListener;
import com.zly.cms.core.listener.SiteDeleteListener;
import com.zly.cms.core.mapper.BlockItemMapper;
import com.zly.cms.core.service.args.BlockItemArgs;
import com.zly.commons.db.identifier.SnowflakeSequence;
import com.zly.commons.db.order.OrderEntityUtils;
import com.zly.commons.query.QueryInfo;
import com.zly.commons.query.QueryParser;
import org.apache.ibatis.annotations.Param;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

/**
 * 区块项 Service
 *
 * @author PONY
 */
@Service
public class BlockItemService implements SiteDeleteListener, ChannelDeleteListener {
    private final AttachmentService attachmentService;
    private final BlockItemMapper mapper;
    private final SnowflakeSequence snowflakeSequence;

    public BlockItemService(AttachmentService attachmentService, BlockItemMapper mapper,
                            SnowflakeSequence snowflakeSequence) {
        this.attachmentService = attachmentService;
        this.mapper = mapper;
        this.snowflakeSequence = snowflakeSequence;
    }

    public boolean countByBlockIdAndArticleId(@Param("blockId") Long blockId, @Param("articleId") Long articleId) {
        return PageMethod.offsetPage(0, 1, false).<Number>doSelectPage(() ->
                mapper.countByBlockIdAndArticleId(blockId, articleId)).iterator().next().intValue() > 0;
    }

    @Transactional(rollbackFor = Exception.class)
    public void insert(BlockItem bean) {
        bean.setId(snowflakeSequence.nextId());
        mapper.insert(bean);
        attachmentService.insertRefer(BlockItemBase.TABLE_NAME, bean.getId(), bean.getAttachmentUrls());
    }

    @Transactional(rollbackFor = Exception.class)
    public void update(BlockItem bean) {
        mapper.update(bean);
        attachmentService.updateRefer(BlockItemBase.TABLE_NAME, bean.getId(), bean.getAttachmentUrls());
    }

    @Transactional(rollbackFor = Exception.class)
    public void moveOrder(Long fromId, Long toId) {
        OrderEntityUtils.move(mapper, fromId, toId);
    }

    @Transactional(rollbackFor = Exception.class)
    public int delete(Long id) {
        attachmentService.deleteRefer(BlockItemBase.TABLE_NAME, id);
        return mapper.delete(id);
    }

    @Transactional(rollbackFor = Exception.class)
    public int delete(List<Long> ids) {
        return ids.stream().filter(Objects::nonNull).mapToInt(this::delete).sum();
    }

    @Nullable
    public BlockItem select(Long id) {
        return mapper.select(id);
    }

    public List<BlockItem> selectList(BlockItemArgs args) {
        QueryInfo queryInfo = QueryParser.parse(args.getQueryMap(), BlockItemBase.TABLE_NAME, "order,id");
        return mapper.selectAll(queryInfo);
    }

    public List<BlockItem> selectList(BlockItemArgs args, int offset, int limit) {
        return PageMethod.offsetPage(offset, limit, false).doSelectPage(() -> selectList(args));
    }

    public boolean existsByBlockId(Long blockId, Long notSiteId) {
        return mapper.existsByBlockId(blockId, notSiteId) > 0;
    }

    public int deleteByArticleId(Long articleId) {
        return mapper.deleteByArticleId(articleId);
    }

    @Override
    public void preChannelDelete(Long channelId) {
        mapper.deleteByChannelId(channelId);
    }

    @Override
    public void preSiteDelete(Long siteId) {
        mapper.deleteBySiteId(siteId);
    }

    @Override
    public int deleteListenerOrder() {
        // 栏目(100), 区块(200), 文章(300)、**区块项(400)**
        return 400;
    }
}