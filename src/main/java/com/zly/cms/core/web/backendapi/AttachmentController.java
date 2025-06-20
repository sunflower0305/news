package com.zly.cms.core.web.backendapi;

import com.zly.cms.core.aop.annotations.OperationLog;
import com.zly.cms.core.aop.enums.OperationType;
import com.zly.cms.core.domain.Attachment;
import com.zly.cms.core.service.AttachmentService;
import com.zly.cms.core.service.args.AttachmentArgs;
import com.zly.cms.core.support.Contexts;
import com.zly.cms.core.support.UrlConstants;
import com.zly.cms.core.web.support.ValidUtils;
import com.zly.commons.web.Responses;
import com.zly.commons.web.Responses.Body;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

import static com.zly.cms.core.support.Constants.validPage;
import static com.zly.cms.core.support.Constants.validPageSize;
import static com.zly.commons.db.MyBatis.springPage;
import static com.zly.commons.query.QueryUtils.getQueryMap;

/**
 * 附件 Controller
 *
 * @author PONY
 */
@RestController("backendAttachmentController")
@RequestMapping(UrlConstants.BACKEND_API + "/core/attachment")
public class AttachmentController {
    private final AttachmentService service;

    public AttachmentController(AttachmentService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyAuthority('attachment:list','*')")
    public Object list(Integer page, Integer pageSize, HttpServletRequest request) {
        AttachmentArgs args = AttachmentArgs.of(getQueryMap(request.getQueryString()))
                .siteId(Contexts.getCurrentSiteId());
        return springPage(service.selectPage(args, validPage(page), validPageSize(pageSize)));
    }

    @GetMapping("{id}")
    @PreAuthorize("hasAnyAuthority('attachment:show','*')")
    public Object show(@PathVariable Long id) {
        Attachment bean = service.select(id);
        if (bean == null) {
            return Responses.notFound("Attachment not found. ID = " + id);
        }
        ValidUtils.dataInSite(bean.getSiteId(), Contexts.getCurrentSiteId());
        return bean;
    }

    @DeleteMapping
    @PreAuthorize("hasAnyAuthority('attachment:delete','*')")
    @OperationLog(module = "attachment", operation = "delete", type = OperationType.DELETE)
    public ResponseEntity<Body> delete(@RequestBody List<Long> ids) {
        Long siteId = Contexts.getCurrentSiteId();
        for (Long id : ids) {
            Attachment bean = service.select(id);
            if (bean == null) {
                continue;
            }
            ValidUtils.dataInSite(bean.getSiteId(), siteId);
            service.delete(bean);
        }
        return Responses.ok();
    }
}