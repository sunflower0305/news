package com.zly.cms.core.web.backendapi;

import static com.zly.cms.core.support.Constants.*;
import static com.zly.cms.core.support.Constants.validLimit;
import static com.zly.cms.core.support.UrlConstants.BACKEND_API;
import static com.zly.commons.db.MyBatis.springPage;
import static com.zly.commons.query.QueryUtils.getQueryMap;

import com.zly.cms.core.aop.annotations.OperationLog;
import com.zly.cms.core.aop.enums.OperationType;
import com.zly.cms.core.domain.Site;
import com.zly.cms.core.domain.Tag;
import com.zly.cms.core.domain.User;
import com.zly.cms.core.service.TagService;
import com.zly.cms.core.service.args.TagArgs;
import com.zly.cms.core.support.Contexts;
import com.zly.cms.core.web.support.ValidUtils;
import com.zly.commons.web.Entities;
import com.zly.commons.web.Responses.Body;
import com.zly.commons.web.Responses;
import com.zly.commons.web.exception.Http404Exception;

import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.Nullable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * Tag Controller
 *
 * @author PONY
 */
@RestController("backendTagController")
@RequestMapping(BACKEND_API + "/core/tag")
public class TagController {
    private final TagService service;

    public TagController(TagService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyAuthority('tag:list','*')")
    public Page<Tag> page(@RequestParam("page") Integer page, @RequestParam("pageSize") Integer pageSize,
                          HttpServletRequest request) {
        TagArgs args = TagArgs.of(getQueryMap(request.getQueryString())).siteId(Contexts.getCurrentSiteId());
        return springPage(service.selectPage(args, validPage(page), validPageSize(pageSize)));
    }

    @GetMapping("list")
    @PreAuthorize("hasAnyAuthority('tag:list','*')")
    public List<Tag> list(@Nullable Integer offset, @Nullable Integer limit, HttpServletRequest request) {
        TagArgs args = TagArgs.of(getQueryMap(request.getQueryString())).siteId(Contexts.getCurrentSiteId());
        return service.selectList(args, validOffset(offset), validLimit(limit));
    }

    @GetMapping("{id}")
    @PreAuthorize("hasAnyAuthority('tag:show','*')")
    public Tag show(@PathVariable("id") Long id) {
        Tag bean = service.select(id);
        if (bean == null) {
            throw new Http404Exception(Tag.NOT_FOUND + id);
        }
        return bean;
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('tag:create','*')")
    @OperationLog(module = "tag", operation = "create", type = OperationType.CREATE)
    public ResponseEntity<Body> create(@RequestBody @Valid Tag bean) {
        Site site = Contexts.getCurrentSite();
        User user = Contexts.getCurrentUser();
        Tag tag = new Tag();
        Entities.copy(bean, tag, "siteId", "userId", "created", "refers");
        tag.setSiteId(site.getId());
        tag.setUserId(user.getId());
        service.insert(tag);
        return Responses.ok();
    }

    @PutMapping
    @PreAuthorize("hasAnyAuthority('tag:update','*')")
    @OperationLog(module = "tag", operation = "update", type = OperationType.UPDATE)
    public ResponseEntity<Body> update(@RequestBody @Valid Tag bean) {
        Site site = Contexts.getCurrentSite();
        Tag tag = service.select(bean.getId());
        if (tag == null) {
            throw new Http404Exception(Tag.NOT_FOUND + bean.getId());
        }
        ValidUtils.dataInSite(tag.getSiteId(), site.getId());
        Entities.copy(bean, tag, "siteId", "userId", "created", "refers");
        service.update(tag);
        return Responses.ok();
    }

    @DeleteMapping
    @PreAuthorize("hasAnyAuthority('tag:delete','*')")
    @OperationLog(module = "tag", operation = "delete", type = OperationType.DELETE)
    public ResponseEntity<Body> delete(@RequestBody List<Long> ids) {
        Site site = Contexts.getCurrentSite();
        for (Long id : ids) {
            Tag bean = service.select(id);
            if (bean == null) {
                throw new Http404Exception(Tag.NOT_FOUND + id);
            }
            ValidUtils.dataInSite(bean.getSiteId(), site.getId());
            service.delete(id);
        }
        return Responses.ok();
    }
}