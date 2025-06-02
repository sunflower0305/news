package com.zly.cms.ext.collector;

/**
 * 采集 Consumer
 *
 * @author PONY
 */
public interface CollectorConsumer<T> {
    void accept(T t) throws Exception;
}
