package com.zly.cms.core.web.frontend;

import com.zly.cms.core.domain.Article;
import com.zly.cms.core.domain.Channel;
import com.zly.cms.core.domain.Site;
import com.zly.cms.core.domain.User;
import com.zly.cms.core.domain.Tag;
import com.zly.cms.core.service.args.ChannelArgs;
import com.zly.cms.core.service.ArticleService;
import com.zly.cms.core.service.ChannelService;
import com.zly.cms.core.service.ConfigService;
import com.zly.cms.core.service.TagService;
import com.zly.cms.core.support.Contexts;
import com.zly.cms.core.support.UrlConstants;
import com.zly.cms.core.web.support.SiteResolver;
import com.zly.commons.web.exception.Http403Exception;
import com.zly.commons.web.exception.Http404Exception;
import org.apache.commons.lang3.StringUtils;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 用户发布新闻 Controller
 */
@Controller("frontendPublishNewsController")
public class PublishNewsController {
    private final ArticleService articleService;
    private final ChannelService channelService;
    private final ConfigService configService;
    private final TagService tagService;
    private final SiteResolver siteResolver;

    private static final String PUBLISH_NEWS_TEMPLATE = "publish_news";

    public PublishNewsController(ArticleService articleService, ChannelService channelService,
                                ConfigService configService, TagService tagService, SiteResolver siteResolver) {
        this.articleService = articleService;
        this.channelService = channelService;
        this.configService = configService;
        this.tagService = tagService;
        this.siteResolver = siteResolver;
    }

    /**
     * 进入发布新闻页面
     */
    @GetMapping({UrlConstants.PUBLISH_NEWS, "/{subDir:[\\w-]+}" + UrlConstants.PUBLISH_NEWS})
    public String publishNewsForm(@PathVariable(required = false) String subDir,
                                 HttpServletRequest request, Map<String, Object> modelMap) {
        Site site = siteResolver.resolve(request, subDir);
        User user = Contexts.getCurrentUser();
        
        // 检查用户是否已登录
        if (user == null) {
            return "redirect:" + site.getDynamicUrl() + "/login";
        }
        
        // 获取可用的新闻栏目
        List<Channel> allChannels = channelService.selectList(ChannelArgs.of().siteId(site.getId()));
        
        // 只保留包含"国内"或"国际"的栏目
        List<Channel> filteredChannels = allChannels.stream()
                .filter(channel -> channel.getName() != null && 
                        (channel.getName().contains("国内") || channel.getName().contains("国际")))
                .collect(Collectors.toList());
        
        modelMap.put("channels", filteredChannels);
        
        return site.assembleTemplate(PUBLISH_NEWS_TEMPLATE);
    }

    /**
     * 提交发布新闻
     */
    @PostMapping({UrlConstants.PUBLISH_NEWS, "/{subDir:[\\w-]+}" + UrlConstants.PUBLISH_NEWS})
    public String publishNews(@PathVariable(required = false) String subDir,
                              @RequestParam Long channelId,
                              @RequestParam String title,
                              @RequestParam String text,
                              @RequestParam(required = false) String tags,
                              @RequestParam(required = false) String image,
                              @RequestParam(required = false) String summary,
                              HttpServletRequest request,
                              Map<String, Object> modelMap) {
        Site site = siteResolver.resolve(request, subDir);
        User user = Contexts.getCurrentUser();
        
        // 检查用户是否已登录
        if (user == null) {
            throw new Http403Exception("请先登录");
        }
        
        // 检查必填字段
        if (StringUtils.isBlank(title)) {
            throw new Http403Exception("标题不能为空");
        }
        
        if (StringUtils.isBlank(text)) {
            throw new Http403Exception("正文内容不能为空");
        }
        
        // 获取栏目
        Channel channel = channelService.select(channelId);
        if (channel == null || !channel.getSiteId().equals(site.getId())) {
            throw new Http404Exception("栏目不存在");
        }
        
        // 创建文章
        Article article = new Article();
        article.setSiteId(site.getId());
        article.setChannelId(channelId);
        article.setUserId(user.getId());
        article.setOrgId(user.getOrgId());
        article.setTitle(title);
        article.setText(text);
        article.setInputType(Article.INPUT_TYPE_CONTRIBUTE); // 设置为投稿类型
        article.setStatus(Article.STATUS_PENDING); // 设置为待审核状态
        article.setCreated(OffsetDateTime.now());
        article.setModified(OffsetDateTime.now());
        
        // 设置可选字段
        if (StringUtils.isNotBlank(image)) {
            article.setImage(image);
        }
        
        if (StringUtils.isNotBlank(summary)) {
            article.setSeoDescription(summary);
        }
        
        // 设置作者为当前用户名称
        article.setAuthor(user.getNickname());
        
        // 处理标签
        List<String> tagList = new ArrayList<>();
        if (StringUtils.isNotBlank(tags)) {
            tagList = Arrays.stream(tags.split(","))
                    .map(String::trim)
                    .filter(StringUtils::isNotBlank)
                    .collect(Collectors.toList());
        }
        
        // 保存文章
        articleService.insert(article, user.getId(), tagList);
        
        // 将文章ID添加到模型中
        modelMap.put("articleId", article.getId());
        
        return site.assembleTemplate("publish_success");
    }
}