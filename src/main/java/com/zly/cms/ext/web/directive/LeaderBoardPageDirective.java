package com.zly.cms.ext.web.directive;

import com.zly.cms.core.service.SiteService;
import com.zly.cms.ext.service.LeaderBoardService;
import freemarker.core.Environment;
import freemarker.template.TemplateDirectiveBody;
import freemarker.template.TemplateException;
import freemarker.template.TemplateModel;

import java.io.IOException;
import java.util.Map;

import static com.zly.cms.core.web.support.Directives.getBoolean;
import static com.zly.cms.core.web.support.Directives.getInteger;

/**
 * 组织文章排行榜分页 标签
 *
 * @author PONY
 */
public class LeaderBoardPageDirective extends LeaderBoardListDirective {
    @SuppressWarnings("unchecked")
    @Override
    public void execute(Environment env, Map params, TemplateModel[] loopVars, TemplateDirectiveBody body)
            throws TemplateException, IOException {
        doExecute(env, params, loopVars, body, true);
    }

    public LeaderBoardPageDirective(LeaderBoardService service, SiteService siteService) {
        super(service, siteService);
    }
}
