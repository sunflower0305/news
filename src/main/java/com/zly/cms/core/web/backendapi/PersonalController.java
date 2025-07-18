package com.zly.cms.core.web.backendapi;

import com.zly.cms.core.aop.annotations.OperationLog;
import com.zly.cms.core.aop.enums.OperationType;
import com.zly.cms.core.component.PasswordService;
import com.zly.cms.core.domain.Config;
import com.zly.cms.core.domain.User;
import com.zly.cms.core.service.ConfigService;
import com.zly.cms.core.support.Contexts;
import com.zly.commons.web.Responses;
import com.zly.commons.web.Servlets;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.validation.constraints.NotBlank;

import static com.zly.cms.core.support.UrlConstants.BACKEND_API;

/**
 * 个人设置 Controller
 *
 * @author PONY
 */
@RestController("backendPersonalController")
@RequestMapping(BACKEND_API + "/core/personal")
public class PersonalController {
    private final ConfigService configService;
    private final PasswordService passwordService;

    public PersonalController(ConfigService configService, PasswordService passwordService) {
        this.configService = configService;
        this.passwordService = passwordService;
    }

    @PutMapping("password")
    @PreAuthorize("hasAnyAuthority('password:update','*')")
    @OperationLog(module = "personal", operation = "updatePassword", type = OperationType.UPDATE)
    public ResponseEntity<Responses.Body> updatePassword(
            @RequestBody UpdatePasswordParams params, HttpServletRequest request) {
        String ip = Servlets.getRemoteAddr(request);
        Config.Security security = configService.getUnique().getSecurity();
        User currentUser = Contexts.getCurrentUser();
        return passwordService.updatePassword(currentUser, params.password, params.newPassword, ip,
                security, request);
    }

    public static class UpdatePasswordParams {
        @NotBlank
        public String password;
        @NotBlank
        public String newPassword;
    }
}
