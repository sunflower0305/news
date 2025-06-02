package com.zly.cms.ext.web.backendapi;

import com.zly.cms.core.aop.annotations.OperationLog;
import com.zly.cms.core.aop.enums.OperationType;
import com.zly.cms.ext.domain.Example;
import com.zly.cms.ext.service.ExampleService;
import com.zly.cms.ext.service.args.ExampleArgs;
import com.zly.commons.web.Entities;
import com.zly.commons.web.Responses;
import com.zly.commons.web.Responses.Body;
import com.zly.commons.web.exception.Http404Exception;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.List;

import static com.zly.cms.core.support.Constants.validPage;
import static com.zly.cms.core.support.Constants.validPageSize;
import static com.zly.commons.db.MyBatis.springPage;
import static com.zly.commons.query.QueryUtils.getQueryMap;

/**
 * 示例 Controller
 *
 * @author PONY
 */
// @RestController("backendExampleController")
// @RequestMapping(BACKEND_API + "/ext/example")
public class ExampleController {
    private final ExampleService service;

    public ExampleController(ExampleService service) {
        this.service = service;
    }

    @GetMapping
    @PreAuthorize("hasAnyAuthority('example:list','*')")
    public Page<Example> list(@RequestParam("page") Integer page, @RequestParam("pageSize") Integer pageSize, HttpServletRequest request) {
        ExampleArgs args = ExampleArgs.of(getQueryMap(request.getQueryString()));
        return springPage(service.selectPage(args, validPage(page), validPageSize(pageSize)));
    }

    @GetMapping("{id}")
    @PreAuthorize("hasAnyAuthority('example:show','*')")
    public Example show(@PathVariable("id") Long id) {
        Example bean = service.select(id);
        if (bean == null) {
            throw new Http404Exception("Example not found. ID = " + id);
        }
        return bean;
    }

    @PostMapping
    @PreAuthorize("hasAnyAuthority('example:create','*')")
    @OperationLog(module = "example", operation = "create", type = OperationType.CREATE)
    public ResponseEntity<Body> create(@RequestBody @Valid Example bean) {
        Example example = new Example();
        Entities.copy(bean, example);
        service.insert(example);
        return Responses.ok();
    }

    @PutMapping
    @PreAuthorize("hasAnyAuthority('example:update','*')")
    @OperationLog(module = "example", operation = "update", type = OperationType.UPDATE)
    public ResponseEntity<Body> update(@RequestBody @Valid Example bean) {
        Example example = service.select(bean.getId());
        if (example == null) {
            throw new Http404Exception("Example not found. ID = " + bean.getId());
        }
        Entities.copy(bean, example);
        service.update(example);
        return Responses.ok();
    }

    @DeleteMapping
    @PreAuthorize("hasAnyAuthority('example:delete','*')")
    @OperationLog(module = "example", operation = "delete", type = OperationType.DELETE)
    public ResponseEntity<Body> delete(@RequestBody List<Long> ids) {
        service.delete(ids);
        return Responses.ok();
    }
}