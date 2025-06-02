package com.zly.cms.core.web.api;

import com.zly.cms.core.domain.Config;
import com.zly.cms.core.domain.Site;
import com.zly.cms.core.service.AttachmentService;
import com.zly.cms.core.service.ConfigService;
import com.zly.cms.core.service.SiteService;
import com.zly.cms.core.support.Contexts;
import com.zly.cms.core.support.Props;
import com.zly.cms.core.web.backendapi.AbstractUploadController;
import com.zly.commons.image.ImageHandler;
import com.zly.commons.web.PathResolver;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ws.schild.jave.EncoderException;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.Map;
import java.util.Optional;

import static com.zly.cms.core.support.UrlConstants.API;
import static com.zly.cms.core.support.UrlConstants.FRONTEND_API;
import static com.zly.commons.web.Uploads.AVATAR_TYPE;

/**
 * 上传 Controller
 *
 * @author PONY
 */
@Tag(name = "上传接口")
@RestController
@RequestMapping({API + "/upload", FRONTEND_API + "/upload"})
public class UploadController extends AbstractUploadController {
    private final ConfigService configService;
    private final SiteService siteService;

    public UploadController(AttachmentService attachmentService, ImageHandler imageHandler, PathResolver pathResolver,
                            ConfigService configService, SiteService siteService, Props props) {
        super(attachmentService, imageHandler, pathResolver, props);
        this.configService = configService;
        this.siteService = siteService;
    }

    @PostMapping("avatar-upload")
    @PreAuthorize("isAuthenticated()")
    public Map<String, Object> avatarUpload(HttpServletRequest request) throws EncoderException, IOException {
        Config config = configService.getUnique();
        Site site = getDefaultSite(config.getDefaultSiteId());
        Contexts.setCurrentSite(site);
        Config.Upload upload = config.getUpload();
        return doUpload(request, upload.getImageLimitByte(), upload.getImageTypes(), AVATAR_TYPE, null);
    }

    @PostMapping("avatar-crop")
    @PreAuthorize("isAuthenticated()")
    public Map<String, Object> avatarCrop(@RequestBody CropParams params) throws IOException {
        Config config = configService.getUnique();
        Site site = getDefaultSite(config.getDefaultSiteId());
        Contexts.setCurrentSite(site);
        return doAvatarCrop(config, params);
    }

    private Site getDefaultSite(Long defaultSiteId) {
        return Optional.ofNullable(siteService.select(defaultSiteId)).orElseThrow(() ->
                new IllegalStateException("default site not found. ID: " + defaultSiteId));
    }

}
