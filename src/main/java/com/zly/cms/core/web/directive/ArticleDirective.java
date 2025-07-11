package com.zly.cms.core.web.directive;

import com.zly.cms.core.domain.Article;
import com.zly.cms.core.service.ArticleService;
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
 * 文章 标签
 *
 * @author PONY
 */
public class ArticleDirective implements TemplateDirectiveModel {
    private static final String ID = "id";

    @SuppressWarnings("unchecked")
    @Override
    public void execute(Environment env, Map params, TemplateModel[] loopVars, TemplateDirectiveBody body)
            throws TemplateException, IOException {
        Freemarkers.requireLoopVars(loopVars);
        Freemarkers.requireBody(body);
        Long id = Directives.getLongRequired(params, ID);

        Article article = articleService.select(id);
        loopVars[0] = env.getObjectWrapper().wrap(article);
        body.render(env.getOut());
    }

    private final ArticleService articleService;

    public ArticleDirective(ArticleService articleService) {
        this.articleService = articleService;
    }
}
