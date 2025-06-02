package com.zly.cms.core.web.directive;

import com.zly.cms.core.domain.Site;
import com.zly.cms.core.service.SiteService;
import com.zly.cms.core.web.support.Directives;
import com.zly.commons.freemarker.Freemarkers;
import freemarker.core.Environment;
import freemarker.template.TemplateDirectiveBody;
import freemarker.template.TemplateDirectiveModel;
import freemarker.template.TemplateException;
import freemarker.template.TemplateModel;

import java.io.IOException;
import java.util.Map;

/**
 * 站点 标签
 *
 * @author PONY
 */
public class SiteDirective implements TemplateDirectiveModel {
    private static final String ID = "id";

    @SuppressWarnings("unchecked")
    @Override
    public void execute(Environment env, Map params, TemplateModel[] loopVars, TemplateDirectiveBody body)
            throws TemplateException, IOException {
        Freemarkers.requireLoopVars(loopVars);
        Freemarkers.requireBody(body);
        Long id = Directives.getLongRequired(params, ID);
        Site site = siteService.select(id);
        loopVars[0] = env.getObjectWrapper().wrap(site);
        body.render(env.getOut());
    }

    private final SiteService siteService;

    public SiteDirective(SiteService siteService) {
        this.siteService = siteService;
    }
}
