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

import static com.zly.cms.core.web.directive.ArticleNextDirective.query;

/**
 * 文章上一篇 标签
 *
 * @author PONY
 */
public class ArticlePrevDirective implements TemplateDirectiveModel {
    @SuppressWarnings("unchecked")
    @Override
    public void execute(Environment env, Map params, TemplateModel[] loopVars, TemplateDirectiveBody body)
            throws TemplateException, IOException {
        Freemarkers.requireLoopVars(loopVars);
        Freemarkers.requireBody(body);

        boolean isDesc = Directives.getBoolean(params, ArticleNextDirective.IS_DESC, true);
        Article article = query(params, isDesc ? articleService::findPrev : articleService::findNext);

        loopVars[0] = env.getObjectWrapper().wrap(article);
        body.render(env.getOut());
    }

    private final ArticleService articleService;

    public ArticlePrevDirective(ArticleService articleService) {
        this.articleService = articleService;
    }
}
