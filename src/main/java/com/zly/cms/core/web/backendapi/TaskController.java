package com.zly.cms.core.web.backendapi;

import com.zly.cms.core.aop.annotations.OperationLog;
import com.zly.cms.core.aop.enums.OperationType;
import com.zly.cms.core.domain.Task;
import com.zly.cms.core.service.TaskService;
import com.zly.cms.core.service.args.TaskArgs;
import com.zly.cms.core.support.Contexts;
import com.zly.cms.core.web.support.ValidUtils;
import com.zly.commons.web.Entities;
import com.zly.commons.web.Responses;
import com.zly.commons.web.Responses.Body;
import com.zly.commons.web.exception.Http404Exception;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

import static com.zly.cms.core.support.Constants.validPage;
import static com.zly.cms.core.support.Constants.validPageSize;
import static com.zly.cms.core.support.UrlConstants.BACKEND_API;
import static com.zly.commons.db.MyBatis.springPage;
import static com.zly.commons.query.QueryUtils.getQueryMap;

/**
 * 任务 Controller
 *
 * @author PONY
 */
@RestController("backendTaskController")
@RequestMapping(BACKEND_API + "/core/task")
public class TaskController {
    private final TaskService service;

    public TaskController(TaskService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyAuthority('task:list','*')")
    public Page<Task> list(Integer page, Integer pageSize, HttpServletRequest request) {
        TaskArgs args = TaskArgs.of(getQueryMap(request.getQueryString())).siteId(Contexts.getCurrentSiteId());
        return springPage(service.selectPage(args, validPage(page), validPageSize(pageSize)));
    }

    @GetMapping("{id}")
    @PreAuthorize("hasAnyAuthority('task:show','*')")
    public Task show(@PathVariable Long id) {
        Task bean = service.select(id);
        if (bean == null) {
            throw new Http404Exception(Task.NOT_FOUND + id);
        }
        ValidUtils.dataInSite(bean.getSiteId(), Contexts.getCurrentSiteId());
        return bean;
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('task:create','*')")
    @OperationLog(module = "task", operation = "create", type = OperationType.CREATE)
    public ResponseEntity<Body> create(@RequestBody Task bean) {
        Task task = new Task();
        Entities.copy(bean, task, "siteId");
        task.setSiteId(Contexts.getCurrentSiteId());
        service.insert(task);
        return Responses.ok();
    }

    @PutMapping
    @PreAuthorize("hasAnyAuthority('task:update','*')")
    @OperationLog(module = "task", operation = "update", type = OperationType.UPDATE)
    public ResponseEntity<Body> update(@RequestBody Task bean) {
        Task task = service.select(bean.getId());
        if (task == null) {
            return Responses.notFound("Task not found. ID = " + bean.getId());
        }
        Entities.copy(bean, task);
        ValidUtils.dataInSite(task.getSiteId(), Contexts.getCurrentSiteId());
        service.update(task);
        return Responses.ok();
    }

    @DeleteMapping
    @PreAuthorize("hasAnyAuthority('task:delete','*')")
    @OperationLog(module = "task", operation = "delete", type = OperationType.DELETE)
    public ResponseEntity<Body> delete(@RequestBody List<Long> ids) {
        for (Long id : ids) {
            Task task = service.select(id);
            if (task == null) {
                return Responses.notFound(Task.NOT_FOUND + id);
            }
            service.delete(id);
        }
        return Responses.ok();
    }
}