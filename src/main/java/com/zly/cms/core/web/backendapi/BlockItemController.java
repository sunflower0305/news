package com.zly.cms.core.web.backendapi;

import com.zly.cms.core.aop.annotations.OperationLog;
import com.zly.cms.core.aop.enums.OperationType;
import com.zly.cms.core.domain.BlockItem;
import com.zly.cms.core.domain.Site;
import com.zly.cms.core.service.BlockItemService;
import com.zly.cms.core.service.args.BlockItemArgs;
import com.zly.cms.core.support.Contexts;
import com.zly.cms.core.web.support.ValidUtils;
import com.zly.commons.db.order.MoveOrderParams;
import com.zly.commons.web.Entities;
import com.zly.commons.web.Responses;
import com.zly.commons.web.Responses.Body;
import com.zly.commons.web.exception.Http400Exception;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.Nullable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.List;
import java.util.Optional;

import static com.zly.cms.core.domain.BlockItem.NOT_FOUND;
import static com.zly.cms.core.support.UrlConstants.BACKEND_API;
import static com.zly.commons.query.QueryUtils.getQueryMap;

/**
 * 区块项 Controller
 *
 * @author PONY
 */
@RestController("backendBlockItemController")
@RequestMapping(BACKEND_API + "/core/block-item")
public class BlockItemController {
    private final BlockItemService service;

    public BlockItemController(BlockItemService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyAuthority('blockItem:list','*')")
    public Object list(@Nullable Long blockId, HttpServletRequest request) {
        BlockItemArgs args = BlockItemArgs.of(getQueryMap(request.getQueryString()))
                .siteId(Contexts.getCurrentSiteId())
                .blockId(blockId);
        return service.selectList(args);
    }

    @GetMapping("{id}")
    @PreAuthorize("hasAnyAuthority('blockItem:show','*')")
    public Object show(@PathVariable Long id) {
        BlockItem bean = service.select(id);
        if (bean == null) {
            return Responses.notFound(BlockItem.NOT_FOUND + id);
        }
        ValidUtils.dataInSite(bean.getSiteId(), Contexts.getCurrentSiteId());
        return bean;
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('blockItem:create','*')")
    @OperationLog(module = "blockItem", operation = "create", type = OperationType.CREATE)
    public ResponseEntity<Body> create(@RequestBody @Valid BlockItem bean) {
        validateBean(bean);
        BlockItem blockItem = new BlockItem();
        Entities.copy(bean, blockItem);
        blockItem.setSiteId(Contexts.getCurrentSiteId());
        service.insert(blockItem);
        return Responses.ok();
    }

    @PutMapping
    @PreAuthorize("hasAnyAuthority('blockItem:update','*')")
    @OperationLog(module = "blockItem", operation = "update", type = OperationType.UPDATE)
    public ResponseEntity<Body> update(@RequestBody @Valid BlockItem bean) {
        BlockItem blockItem = service.select(bean.getId());
        if (blockItem == null) {
            return Responses.notFound("BlockItem not found. ID = " + bean.getId());
        }
        ValidUtils.dataInSite(bean.getSiteId(), Contexts.getCurrentSiteId());
        Entities.copy(bean, blockItem);
        service.update(blockItem);
        return Responses.ok();
    }

    @PostMapping("update-order")
    @PreAuthorize("hasAnyAuthority('blockItem:update','*')")
    @OperationLog(module = "blockItem", operation = "updateOrder", type = OperationType.UPDATE)
    public ResponseEntity<Body> updateOrder(@RequestBody @Valid MoveOrderParams params) {
        Site site = Contexts.getCurrentSite();
        BlockItem fromBean = Optional.ofNullable(service.select(params.getFromId()))
                .orElseThrow(() -> new Http400Exception(NOT_FOUND + params.getFromId()));
        BlockItem toBean = Optional.ofNullable(service.select(params.getToId()))
                .orElseThrow(() -> new Http400Exception(NOT_FOUND + params.getToId()));
        ValidUtils.dataInSite(fromBean.getSiteId(), site.getId());
        ValidUtils.dataInSite(toBean.getSiteId(), site.getId());
        service.moveOrder(fromBean.getId(), toBean.getId());
        return Responses.ok();
    }

    @DeleteMapping
    @PreAuthorize("hasAnyAuthority('blockItem:delete','*')")
    @OperationLog(module = "blockItem", operation = "delete", type = OperationType.DELETE)
    public ResponseEntity<Body> delete(@RequestBody List<Long> ids) {
        Long siteId = Contexts.getCurrentSiteId();
        for (Long id : ids) {
            BlockItem bean = service.select(id);
            if (bean == null) {
                continue;
            }
            ValidUtils.dataInSite(bean.getSiteId(), siteId);
            service.delete(id);
        }
        return Responses.ok();
    }

    private void validateBean(BlockItem bean) {
        Long articleId = bean.getArticleId();
        if (articleId != null && service.countByBlockIdAndArticleId(bean.getBlockId(), articleId)) {
            throw new Http400Exception("BlockItem duplicate: blockId=" + bean.getBlockId()
                    + ", articleId=" + bean.getArticleId());
        }
    }
}