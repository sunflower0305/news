package com.zly.cms.core.listener;

/**
 * 栏目删除监听器
 *
 * @author PONY
 */
public interface ChannelDeleteListener extends DeleteListenerOrder {
    /**
     * 栏目删除前回调
     *
     * @param channelId 栏目ID
     */
    void preChannelDelete(Long channelId);
}
